//! lyrics-fetcher — fetch song lyrics (plain and synced/LRC) by artist and title.
//!
//! Sources (tried in order, first success wins):
//!   1. LRCLIB       — free, no API key. Only source that provides synced (LRC)
//!                      lyrics; usually also has plain lyrics alongside them.
//!   2. lyrics.ovh   — free, no API key. Plain lyrics only.
//!   3. Genius       — better coverage/accuracy, requires GENIUS_ACCESS_TOKEN
//!                      (free token: https://genius.com/api-clients). Plain only.

use std::fs;
use std::io::Write;
use std::path::PathBuf;
use std::process::{Command, Stdio};
use std::time::{SystemTime, UNIX_EPOCH};

use anyhow::{Context, Result};
use clap::Parser;
use once_cell::sync::Lazy;
use regex::Regex;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};

const GENIUS_TOKEN_ENV: &str = "GENIUS_ACCESS_TOKEN";
const CACHE_TTL_SECONDS: u64 = 60 * 60 * 24 * 30; // 30 days
const LRCLIB_BASE: &str = "https://lrclib.net/api";
const USER_AGENT: &str = "lyrics-fetcher/0.2 (personal CLI; https://github.com/Boing-Git)";
// lrclib first — it's the only source that can ever return synced lyrics.
const SOURCE_ORDER: [&str; 3] = ["lrclib", "ovh", "genius"];

/// Fetch song lyrics (plain and synced) by artist and title.
#[derive(Parser, Debug)]
#[command(name = "lyrics-fetch", version, about)]
struct Cli {
    /// Artist name
    artist: Option<String>,

    /// Song title
    title: Option<String>,

    /// Don't strip (Live)/(Remastered)/feat. noise from the title
    #[arg(long = "no-clean")]
    no_clean: bool,

    /// Skip cache, force a fresh fetch
    #[arg(long = "no-cache")]
    no_cache: bool,

    /// Copy plain lyrics to clipboard
    #[arg(short = 'c', long = "copy")]
    copy: bool,

    /// Copy synced (LRC) lyrics to clipboard
    #[arg(long = "copy-lrc")]
    copy_lrc: bool,

    /// Save plain lyrics to a file
    #[arg(short = 's', long = "save")]
    save: Option<PathBuf>,

    /// Save synced (.lrc) lyrics to a file
    #[arg(long = "save-lrc")]
    save_lrc: Option<PathBuf>,

    /// Force a specific source: lrclib | ovh | genius
    #[arg(long = "source")]
    source: Option<String>,

    /// Clear the local lyrics cache and exit
    #[arg(long = "clear-cache")]
    clear_cache: bool,

    /// Output raw lyrics to stdout (prefers synced if available)
    #[arg(long = "raw")]
    raw: bool,
}

#[derive(Debug, Clone, Default)]
struct LyricsResult {
    plain: Option<String>,
    synced: Option<String>,
    source: String,
}

#[derive(Serialize, Deserialize)]
struct CacheEntry {
    artist: String,
    title: String,
    source: String,
    plain: Option<String>,
    synced: Option<String>,
    cached_at: u64,
}

// --------------------------------------------------------------------------- //
// Title cleanup
// --------------------------------------------------------------------------- //

static TITLE_NOISE_PATTERNS: Lazy<Vec<Regex>> = Lazy::new(|| {
    let patterns = [
        r"(?i)\s*\(feat\..*?\)",
        r"(?i)\s*\[feat\..*?\]",
        r"(?i)\s*-\s*remaster(ed)?.*$",
        r"(?i)\s*\(remaster(ed)?.*?\)",
        r"(?i)\s*-\s*live.*$",
        r"(?i)\s*\(live.*?\)",
        r"(?i)\s*-\s*single version$",
        r"(?i)\s*\(single version\)",
        r"(?i)\s*-\s*\d{4}\s*(remaster|mix|version).*$",
    ];
    patterns.iter().map(|p| Regex::new(p).unwrap()).collect()
});

fn clean_title(title: &str) -> String {
    let mut cleaned = title.to_string();
    for pattern in TITLE_NOISE_PATTERNS.iter() {
        cleaned = pattern.replace_all(&cleaned, "").to_string();
    }
    cleaned.trim().to_string()
}

// --------------------------------------------------------------------------- //
// Cache
// --------------------------------------------------------------------------- //

fn cache_dir() -> Result<PathBuf> {
    let dir = dirs::cache_dir()
        .context("could not determine cache directory")?
        .join("lyrics-fetcher");
    fs::create_dir_all(&dir)?;
    Ok(dir)
}

fn cache_key(artist: &str, title: &str) -> String {
    let raw = format!("{}::{}", artist.to_lowercase().trim(), title.to_lowercase().trim());
    let mut hasher = Sha256::new();
    hasher.update(raw.as_bytes());
    let digest = hasher.finalize();
    digest.iter().map(|b| format!("{:02x}", b)).collect()
}

fn cache_path(artist: &str, title: &str) -> Result<PathBuf> {
    Ok(cache_dir()?.join(format!("{}.json", cache_key(artist, title))))
}

fn cache_get(artist: &str, title: &str) -> Option<CacheEntry> {
    let path = cache_path(artist, title).ok()?;
    let data = fs::read_to_string(&path).ok()?;
    let entry: CacheEntry = serde_json::from_str(&data).ok()?;
    let now = SystemTime::now().duration_since(UNIX_EPOCH).ok()?.as_secs();
    if now.saturating_sub(entry.cached_at) > CACHE_TTL_SECONDS {
        return None;
    }
    Some(entry)
}

fn cache_set(artist: &str, title: &str, result: &LyricsResult) -> Result<()> {
    let path = cache_path(artist, title)?;
    let now = SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs();
    let entry = CacheEntry {
        artist: artist.to_string(),
        title: title.to_string(),
        source: result.source.clone(),
        plain: result.plain.clone(),
        synced: result.synced.clone(),
        cached_at: now,
    };
    fs::write(path, serde_json::to_string(&entry)?)?;
    Ok(())
}

fn clear_cache() -> Result<()> {
    let dir = cache_dir()?;
    let mut count = 0;
    for entry in fs::read_dir(&dir)? {
        let entry = entry?;
        if entry.path().extension().and_then(|e| e.to_str()) == Some("json") {
            fs::remove_file(entry.path())?;
            count += 1;
        }
    }
    println!("Cleared {} cached entries.", count);
    Ok(())
}

// --------------------------------------------------------------------------- //
// HTTP client
// --------------------------------------------------------------------------- //

fn http_client() -> Result<reqwest::blocking::Client> {
    Ok(reqwest::blocking::Client::builder()
        .user_agent(USER_AGENT)
        .timeout(std::time::Duration::from_secs(10))
        .build()?)
}

// --------------------------------------------------------------------------- //
// Source: LRCLIB — only source with synced (LRC) lyrics
// --------------------------------------------------------------------------- //

#[derive(Deserialize)]
struct LrclibEntry {
    #[serde(rename = "artistName")]
    artist_name: Option<String>,
    #[serde(rename = "plainLyrics")]
    plain_lyrics: Option<String>,
    #[serde(rename = "syncedLyrics")]
    synced_lyrics: Option<String>,
}

fn fetch_lyrics_lrclib(client: &reqwest::blocking::Client, artist: &str, title: &str) -> Option<LyricsResult> {
    let resp = client
        .get(format!("{}/search", LRCLIB_BASE))
        .query(&[("artist_name", artist), ("track_name", title)])
        .send()
        .ok()?;
    if !resp.status().is_success() {
        return None;
    }
    let results: Vec<LrclibEntry> = resp.json().ok()?;
    if results.is_empty() {
        return None;
    }

    let has_lyrics = |e: &LrclibEntry| e.plain_lyrics.is_some() || e.synced_lyrics.is_some();
    let artist_lower = artist.to_lowercase();

    let best = results
        .iter()
        .find(|e| {
            e.artist_name
                .as_deref()
                .map(|n| n.to_lowercase() == artist_lower)
                .unwrap_or(false)
                && has_lyrics(e)
        })
        .or_else(|| results.iter().find(|e| has_lyrics(e)))?;

    let plain = best.plain_lyrics.as_deref().map(str::trim).filter(|s| !s.is_empty()).map(String::from);
    let synced = best.synced_lyrics.as_deref().map(str::trim).filter(|s| !s.is_empty()).map(String::from);

    if plain.is_none() && synced.is_none() {
        return None;
    }
    Some(LyricsResult { plain, synced, source: "LRCLIB".to_string() })
}

// --------------------------------------------------------------------------- //
// Source: lyrics.ovh (plain only)
// --------------------------------------------------------------------------- //

#[derive(Deserialize)]
struct OvhResponse {
    lyrics: Option<String>,
}

fn fetch_lyrics_ovh(client: &reqwest::blocking::Client, artist: &str, title: &str) -> Option<LyricsResult> {
    let url = format!(
        "https://api.lyrics.ovh/v1/{}/{}",
        urlencoding::encode(artist),
        urlencoding::encode(title)
    );
    let resp = client.get(&url).send().ok()?;
    if !resp.status().is_success() {
        return None;
    }
    let data: OvhResponse = resp.json().ok()?;
    let lyrics = data.lyrics?.trim().to_string();
    if lyrics.is_empty() {
        return None;
    }
    Some(LyricsResult { plain: Some(lyrics), synced: None, source: "lyrics.ovh".to_string() })
}

// --------------------------------------------------------------------------- //
// Source: Genius (plain only — search via API, lyrics via page scrape since
// Genius's public API only returns metadata/annotations, not lyrics text)
// --------------------------------------------------------------------------- //

#[derive(Deserialize)]
struct GeniusSearchResponse {
    response: GeniusSearchInner,
}
#[derive(Deserialize)]
struct GeniusSearchInner {
    hits: Vec<GeniusHit>,
}
#[derive(Deserialize)]
struct GeniusHit {
    result: GeniusSongResult,
}
#[derive(Deserialize)]
struct GeniusSongResult {
    url: String,
    primary_artist: GeniusArtist,
}
#[derive(Deserialize)]
struct GeniusArtist {
    name: String,
}

fn extract_text_with_breaks(element: scraper::ElementRef) -> String {
    let mut out = String::new();
    for child in element.children() {
        match child.value() {
            scraper::Node::Text(text) => out.push_str(text),
            scraper::Node::Element(el) => {
                if el.name() == "br" {
                    out.push('\n');
                } else if let Some(child_el) = scraper::ElementRef::wrap(child) {
                    out.push_str(&extract_text_with_breaks(child_el));
                }
            }
            _ => {}
        }
    }
    out
}

fn fetch_lyrics_genius(client: &reqwest::blocking::Client, artist: &str, title: &str) -> Option<LyricsResult> {
    let token = std::env::var(GENIUS_TOKEN_ENV).ok()?;
    if token.is_empty() {
        return None;
    }

    let query = format!("{} {}", artist, title);
    let resp = client
        .get("https://api.genius.com/search")
        .bearer_auth(&token)
        .query(&[("q", query.as_str())])
        .send()
        .ok()?;
    if !resp.status().is_success() {
        return None;
    }
    let search: GeniusSearchResponse = resp.json().ok()?;

    let artist_lower = artist.to_lowercase();
    let best = search
        .response
        .hits
        .iter()
        .find(|h| h.result.primary_artist.name.to_lowercase().contains(&artist_lower))
        .or_else(|| search.response.hits.first())?;

    let page = client.get(&best.result.url).send().ok()?;
    if !page.status().is_success() {
        return None;
    }
    let html = page.text().ok()?;
    let document = scraper::Html::parse_document(&html);
    let selector = scraper::Selector::parse(r#"div[data-lyrics-container="true"]"#).ok()?;

    let sections: Vec<String> = document
        .select(&selector)
        .map(extract_text_with_breaks)
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty())
        .collect();

    if sections.is_empty() {
        return None;
    }
    Some(LyricsResult {
        plain: Some(sections.join("\n\n")),
        synced: None,
        source: "Genius".to_string(),
    })
}

fn dispatch_source(
    name: &str,
    client: &reqwest::blocking::Client,
    artist: &str,
    title: &str,
) -> Option<LyricsResult> {
    match name {
        "lrclib" => fetch_lyrics_lrclib(client, artist, title),
        "ovh" => fetch_lyrics_ovh(client, artist, title),
        "genius" => fetch_lyrics_genius(client, artist, title),
        _ => None,
    }
}

// --------------------------------------------------------------------------- //
// Clipboard
// --------------------------------------------------------------------------- //

fn copy_to_clipboard(text: &str) -> bool {
    for (cmd, args) in [("wl-copy", vec![]), ("xclip", vec!["-selection", "clipboard"])] {
        let child = Command::new(cmd)
            .args(&args)
            .stdin(Stdio::piped())
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .spawn();
        if let Ok(mut child) = child {
            if let Some(stdin) = child.stdin.as_mut() {
                if stdin.write_all(text.as_bytes()).is_ok() {
                    drop(child.stdin.take());
                    if let Ok(status) = child.wait() {
                        if status.success() {
                            return true;
                        }
                    }
                }
            }
        }
    }
    false
}

// --------------------------------------------------------------------------- //
// Output
// --------------------------------------------------------------------------- //

fn print_panel(header: &str, subtitle: &str, body: &str) {
    let width = header
        .chars()
        .count()
        .max(body.lines().map(|l| l.chars().count()).max().unwrap_or(0))
        + 4;
    let bar = "─".repeat(width);
    println!("┌{}┐", bar);
    println!("│ {:<width$} │", header, width = width - 2);
    println!("├{}┤", bar);
    for line in body.lines() {
        println!("│ {:<width$} │", line, width = width - 2);
    }
    println!("└{}┘", bar);
    println!("  {}", subtitle);
}

fn render(artist: &str, title: &str, plain: &Option<String>, synced: &Option<String>, source: &str) {
    let header = format!("{} — {}", title, artist);

    if let Some(p) = plain {
        print_panel(&header, &format!("plain lyrics — source: {}", source), p);
    }
    if let Some(s) = synced {
        println!();
        print_panel(&header, &format!("synced (LRC) — source: {}", source), s);
    } else if plain.is_some() {
        println!("  No synced (LRC) lyrics available for this track — only LRCLIB provides those.");
    }
}

fn maybe_copy_save(
    plain: &Option<String>,
    synced: &Option<String>,
    copy: bool,
    copy_lrc: bool,
    save: &Option<PathBuf>,
    save_lrc: &Option<PathBuf>,
) -> Result<()> {
    if copy {
        match plain {
            None => println!("Nothing to copy — no plain lyrics found."),
            Some(p) => {
                if copy_to_clipboard(p) {
                    println!("Copied plain lyrics to clipboard.");
                } else {
                    println!("Couldn't find wl-copy or xclip.");
                }
            }
        }
    }
    if copy_lrc {
        match synced {
            None => println!("Nothing to copy — no synced lyrics found."),
            Some(s) => {
                if copy_to_clipboard(s) {
                    println!("Copied synced lyrics to clipboard.");
                } else {
                    println!("Couldn't find wl-copy or xclip.");
                }
            }
        }
    }
    if let Some(path) = save {
        match plain {
            None => println!("No plain lyrics to save."),
            Some(p) => {
                fs::write(path, p)?;
                println!("Saved plain lyrics to {}", path.display());
            }
        }
    }
    if let Some(path) = save_lrc {
        match synced {
            None => println!("No synced lyrics to save."),
            Some(s) => {
                fs::write(path, s)?;
                println!("Saved synced lyrics to {}", path.display());
            }
        }
    }
    Ok(())
}

// --------------------------------------------------------------------------- //
// Main
// --------------------------------------------------------------------------- //

fn main() -> Result<()> {
    let cli = Cli::parse();

    if cli.clear_cache {
        clear_cache()?;
        return Ok(());
    }

    let (artist, title) = match (&cli.artist, &cli.title) {
        (Some(a), Some(t)) => (a.clone(), t.clone()),
        _ => {
            eprintln!("Both ARTIST and TITLE are required (unless using --clear-cache).");
            std::process::exit(1);
        }
    };

    if let Some(source) = &cli.source {
        if !SOURCE_ORDER.contains(&source.as_str()) {
            eprintln!("Unknown source '{}'. Choose from: {}", source, SOURCE_ORDER.join(", "));
            std::process::exit(1);
        }
    }

    let query_title = if cli.no_clean { title.clone() } else { clean_title(&title) };

    if !cli.no_cache {
        if let Some(cached) = cache_get(&artist, &query_title) {
            if cli.raw {
                if let Some(s) = &cached.synced {
                    println!("{}", s);
                } else if let Some(p) = &cached.plain {
                    println!("{}", p);
                }
            } else {
                render(&artist, &title, &cached.plain, &cached.synced, &format!("{} (cached)", cached.source));
            }
            maybe_copy_save(&cached.plain, &cached.synced, cli.copy, cli.copy_lrc, &cli.save, &cli.save_lrc)?;
            return Ok(());
        }
    }

    let client = http_client()?;
    let order: Vec<&str> = match &cli.source {
        Some(s) => vec![s.as_str()],
        None => SOURCE_ORDER.to_vec(),
    };

    let mut result: Option<LyricsResult> = None;
    for name in order {
        result = dispatch_source(name, &client, &artist, &query_title);
        if result.is_none() && query_title != title {
            result = dispatch_source(name, &client, &artist, &title);
        }
        if result.is_some() {
            break;
        }
    }

    let result = match result {
        Some(r) => r,
        None => {
            eprintln!("No lyrics found for '{}' by {}.", title, artist);
            if std::env::var(GENIUS_TOKEN_ENV).is_err() {
                eprintln!(
                    "Tip: set GENIUS_ACCESS_TOKEN to enable the Genius fallback \
                     (free token at genius.com/api-clients)."
                );
            }
            std::process::exit(1);
        }
    };

    cache_set(&artist, &query_title, &result)?;
    if cli.raw {
        if let Some(s) = &result.synced {
            println!("{}", s);
        } else if let Some(p) = &result.plain {
            println!("{}", p);
        }
    } else {
        render(&artist, &title, &result.plain, &result.synced, &result.source);
    }
    maybe_copy_save(&result.plain, &result.synced, cli.copy, cli.copy_lrc, &cli.save, &cli.save_lrc)?;

    Ok(())
}
