#!/usr/bin/env python3
"""
lyrics-fetcher — fetch song lyrics (plain and synced/LRC) by artist and title.

Sources (tried in order, first success wins):
  1. LRCLIB       — free, no API key. Only source that provides synced (LRC)
                     lyrics; usually also has plain lyrics alongside them.
  2. lyrics.ovh   — free, no API key. Plain lyrics only.
  3. Genius       — better coverage/accuracy, requires GENIUS_ACCESS_TOKEN
                     (free token: https://genius.com/api-clients). Plain only.

Usage:
  lyrics_fetcher.py "Radiohead" "Karma Police"
  lyrics_fetcher.py "Daft Punk" "One More Time" --copy
  lyrics_fetcher.py "Bon Iver" "Holocene" --save holocene.txt --save-lrc holocene.lrc
  lyrics_fetcher.py --clear-cache
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Optional
from urllib.parse import quote

import httpx
import typer
from rich.console import Console
from rich.panel import Panel

app = typer.Typer(add_completion=False, help="Fetch song lyrics (plain and synced) by artist and title.")
console = Console()

CACHE_DIR = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "lyrics-fetcher"
CACHE_DIR.mkdir(parents=True, exist_ok=True)
CACHE_TTL_SECONDS = 60 * 60 * 24 * 30  # 30 days

GENIUS_TOKEN_ENV = "GENIUS_ACCESS_TOKEN"
LRCLIB_BASE = "https://lrclib.net/api"
USER_AGENT = "lyrics-fetcher/0.2 (personal CLI; https://github.com/Boing-Git)"

TITLE_NOISE_PATTERNS = [
    r"\s*\(feat\..*?\)", r"\s*\[feat\..*?\]",
    r"\s*-\s*remaster(ed)?.*$", r"\s*\(remaster(ed)?.*?\)",
    r"\s*-\s*live.*$", r"\s*\(live.*?\)",
    r"\s*-\s*single version$", r"\s*\(single version\)",
    r"\s*-\s*\d{4}\s*(remaster|mix|version).*$",
]


# --------------------------------------------------------------------------- #
# Cache
# --------------------------------------------------------------------------- #

def _cache_key(artist: str, title: str) -> str:
    raw = f"{artist.lower().strip()}::{title.lower().strip()}"
    return hashlib.sha256(raw.encode()).hexdigest()


def _cache_path(artist: str, title: str) -> Path:
    return CACHE_DIR / f"{_cache_key(artist, title)}.json"


def _cache_get(artist: str, title: str) -> Optional[dict]:
    path = _cache_path(artist, title)
    if not path.exists():
        return None
    try:
        data = json.loads(path.read_text())
    except (json.JSONDecodeError, OSError):
        return None
    if time.time() - data.get("cached_at", 0) > CACHE_TTL_SECONDS:
        return None
    return data


def _cache_set(artist: str, title: str, plain: Optional[str], synced: Optional[str], source: str) -> None:
    path = _cache_path(artist, title)
    path.write_text(json.dumps({
        "artist": artist,
        "title": title,
        "source": source,
        "plain": plain,
        "synced": synced,
        "cached_at": time.time(),
    }))


def _clear_cache() -> None:
    count = 0
    for f in CACHE_DIR.glob("*.json"):
        f.unlink()
        count += 1
    console.print(f"[green]Cleared {count} cached entries.[/green]")


# --------------------------------------------------------------------------- #
# Title cleanup
# --------------------------------------------------------------------------- #

def clean_title(title: str) -> str:
    """Strip common noise like '(Remastered 2011)', '- Live', 'feat. X'."""
    cleaned = title
    for pattern in TITLE_NOISE_PATTERNS:
        cleaned = re.sub(pattern, "", cleaned, flags=re.IGNORECASE)
    return cleaned.strip()


# --------------------------------------------------------------------------- #
# Sources
# --------------------------------------------------------------------------- #

@dataclass
class LyricsResult:
    plain: Optional[str]
    synced: Optional[str]  # LRC-format text, e.g. "[00:12.34]line one"
    source: str


def fetch_lyrics_lrclib(artist: str, title: str) -> Optional[LyricsResult]:
    """LRCLIB is the only source here that can return synced (LRC) lyrics."""
    try:
        resp = httpx.get(
            f"{LRCLIB_BASE}/search",
            params={"artist_name": artist, "track_name": title},
            headers={"User-Agent": USER_AGENT},
            timeout=10,
        )
    except httpx.RequestError:
        return None
    if resp.status_code != 200:
        return None
    try:
        results = resp.json()
    except json.JSONDecodeError:
        return None
    if not results:
        return None

    def has_lyrics(r: dict) -> bool:
        return bool(r.get("plainLyrics") or r.get("syncedLyrics"))

    artist_lower = artist.lower().strip()
    best = next(
        (r for r in results if r.get("artistName", "").lower().strip() == artist_lower and has_lyrics(r)),
        None,
    )
    if not best:
        best = next((r for r in results if has_lyrics(r)), None)
    if not best:
        return None

    plain = (best.get("plainLyrics") or "").strip() or None
    synced = (best.get("syncedLyrics") or "").strip() or None
    if not plain and not synced:
        return None
    return LyricsResult(plain=plain, synced=synced, source="LRCLIB")


def fetch_lyrics_ovh(artist: str, title: str) -> Optional[LyricsResult]:
    url = f"https://api.lyrics.ovh/v1/{quote(artist)}/{quote(title)}"
    try:
        resp = httpx.get(url, timeout=10)
    except httpx.RequestError:
        return None
    if resp.status_code != 200:
        return None
    try:
        data = resp.json()
    except json.JSONDecodeError:
        return None
    lyrics = (data.get("lyrics") or "").strip()
    if not lyrics:
        return None
    return LyricsResult(plain=lyrics, synced=None, source="lyrics.ovh")


def fetch_lyrics_genius(artist: str, title: str) -> Optional[LyricsResult]:
    token = os.environ.get(GENIUS_TOKEN_ENV)
    if not token:
        return None
    try:
        import lyricsgenius
    except ImportError:
        console.print(
            "[yellow]lyricsgenius not installed — run: "
            "pip install 'lyrics-fetcher[genius]'[/yellow]"
        )
        return None
    genius = lyricsgenius.Genius(
        token,
        verbose=False,
        remove_section_headers=False,
        skip_non_songs=True,
    )
    try:
        song = genius.search_song(title, artist)
    except Exception:
        return None
    if not song or not song.lyrics:
        return None
    return LyricsResult(plain=song.lyrics.strip(), synced=None, source="Genius")


SOURCES: dict[str, Callable[[str, str], Optional[LyricsResult]]] = {
    "lrclib": fetch_lyrics_lrclib,
    "ovh": fetch_lyrics_ovh,
    "genius": fetch_lyrics_genius,
}
# lrclib first — it's the only one that can ever return synced lyrics.
SOURCE_ORDER = ["lrclib", "ovh", "genius"]


# --------------------------------------------------------------------------- #
# Clipboard
# --------------------------------------------------------------------------- #

def copy_to_clipboard(text: str) -> bool:
    for cmd in (["wl-copy"], ["xclip", "-selection", "clipboard"]):
        try:
            subprocess.run(cmd, input=text.encode(), check=True)
            return True
        except (FileNotFoundError, subprocess.CalledProcessError):
            continue
    return False


# --------------------------------------------------------------------------- #
# Output
# --------------------------------------------------------------------------- #

def _render(artist: str, title: str, plain: Optional[str], synced: Optional[str], source: str) -> None:
    header = f"[bold]{title}[/bold] — {artist}"

    if plain:
        console.print(Panel(
            plain,
            title=header,
            subtitle=f"[dim]plain lyrics — source: {source}[/dim]",
            border_style="cyan",
            expand=False,
        ))
    if synced:
        console.print(Panel(
            synced,
            title=header,
            subtitle=f"[dim]synced (LRC) — source: {source}[/dim]",
            border_style="magenta",
            expand=False,
        ))
    elif plain:
        console.print("[dim]No synced (LRC) lyrics available for this track — only LRCLIB provides those.[/dim]")


def _maybe_copy_save(
    plain: Optional[str],
    synced: Optional[str],
    copy_plain: bool,
    copy_lrc: bool,
    save_plain: Optional[Path],
    save_lrc: Optional[Path],
) -> None:
    if copy_plain:
        if not plain:
            console.print("[yellow]Nothing to copy — no plain lyrics found.[/yellow]")
        elif copy_to_clipboard(plain):
            console.print("[green]Copied plain lyrics to clipboard.[/green]")
        else:
            console.print("[yellow]Couldn't find wl-copy or xclip.[/yellow]")

    if copy_lrc:
        if not synced:
            console.print("[yellow]Nothing to copy — no synced lyrics found.[/yellow]")
        elif copy_to_clipboard(synced):
            console.print("[green]Copied synced lyrics to clipboard.[/green]")
        else:
            console.print("[yellow]Couldn't find wl-copy or xclip.[/yellow]")

    if save_plain:
        if plain:
            save_plain.write_text(plain)
            console.print(f"[green]Saved plain lyrics to {save_plain}[/green]")
        else:
            console.print("[yellow]No plain lyrics to save.[/yellow]")

    if save_lrc:
        if synced:
            save_lrc.write_text(synced)
            console.print(f"[green]Saved synced lyrics to {save_lrc}[/green]")
        else:
            console.print("[yellow]No synced lyrics to save.[/yellow]")


# --------------------------------------------------------------------------- #
# CLI
# --------------------------------------------------------------------------- #

@app.command()
def main(
    artist: Optional[str] = typer.Argument(None, help="Artist name"),
    title: Optional[str] = typer.Argument(None, help="Song title"),
    no_clean: bool = typer.Option(
        False, "--no-clean", help="Don't strip (Live)/(Remastered)/feat. noise from the title"
    ),
    no_cache: bool = typer.Option(False, "--no-cache", help="Skip cache, force a fresh fetch"),
    copy: bool = typer.Option(False, "--copy", "-c", help="Copy plain lyrics to clipboard"),
    copy_lrc: bool = typer.Option(False, "--copy-lrc", help="Copy synced (LRC) lyrics to clipboard"),
    save: Optional[Path] = typer.Option(None, "--save", "-s", help="Save plain lyrics to a file"),
    save_lrc: Optional[Path] = typer.Option(None, "--save-lrc", help="Save synced (.lrc) lyrics to a file"),
    source: Optional[str] = typer.Option(
        None, "--source", help=f"Force a specific source: {' | '.join(SOURCE_ORDER)}"
    ),
    clear_cache: bool = typer.Option(
        False, "--clear-cache", help="Clear the local lyrics cache and exit"
    ),
) -> None:
    """Fetch plain and synced lyrics for TITLE by ARTIST."""
    if clear_cache:
        _clear_cache()
        raise typer.Exit()

    if not artist or not title:
        console.print("[red]Both ARTIST and TITLE are required (unless using --clear-cache).[/red]")
        raise typer.Exit(code=1)

    if source and source not in SOURCES:
        console.print(f"[red]Unknown source '{source}'. Choose from: {', '.join(SOURCE_ORDER)}[/red]")
        raise typer.Exit(code=1)

    query_title = title if no_clean else clean_title(title)

    if not no_cache:
        cached = _cache_get(artist, query_title)
        if cached:
            _render(artist, title, cached.get("plain"), cached.get("synced"), f"{cached['source']} (cached)")
            _maybe_copy_save(cached.get("plain"), cached.get("synced"), copy, copy_lrc, save, save_lrc)
            return

    order = [source] if source else SOURCE_ORDER
    result: Optional[LyricsResult] = None

    with console.status(f"[cyan]Searching for '{title}' by {artist}..."):
        for name in order:
            fetch = SOURCES[name]
            result = fetch(artist, query_title)
            if not result and query_title != title:
                result = fetch(artist, title)
            if result:
                break

    if not result:
        console.print(f"[red]No lyrics found for '{title}' by {artist}.[/red]")
        if not os.environ.get(GENIUS_TOKEN_ENV):
            console.print(
                "[dim]Tip: set GENIUS_ACCESS_TOKEN to enable the Genius fallback "
                "(free token at genius.com/api-clients).[/dim]"
            )
        raise typer.Exit(code=1)

    _cache_set(artist, query_title, result.plain, result.synced, result.source)
    _render(artist, title, result.plain, result.synced, result.source)
    _maybe_copy_save(result.plain, result.synced, copy, copy_lrc, save, save_lrc)


if __name__ == "__main__":
    app()
