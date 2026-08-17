# lyrics-fetcher (Rust)

Same tool as the Python version, ported to Rust: fetches both plain and
synced (LRC) lyrics by artist + title, tries LRCLIB then lyrics.ovh then
Genius, caches results, can copy to clipboard or save to a file.

Only **LRCLIB** returns synced lyrics — lyrics.ovh and Genius are plain
text only, so it's tried first.

## Build

```bash
cargo build --release
./target/release/lyrics-fetcher "Radiohead" "Karma Police"
```

### On NixOS

```bash
nix-shell -p cargo rustc pkg-config
cargo build --release
```

No OpenSSL dependency needed — it's built with `rustls` (pure Rust TLS), so
no `openssl.dev` fiddling on NixOS.

### Install to PATH

```bash
cargo install --path .
lyrics-fetcher "Radiohead" "Karma Police"
```

## Usage

```bash
lyrics-fetcher "Daft Punk" "One More Time"                        # shows plain + synced if available
lyrics-fetcher "Bon Iver" "Holocene" --copy                       # copies plain lyrics
lyrics-fetcher "Bon Iver" "Holocene" --copy-lrc                   # copies synced (LRC) lyrics
lyrics-fetcher "Bon Iver" "Holocene" --save song.txt --save-lrc song.lrc
lyrics-fetcher "Artist" "Song (Live)"                              # noisy suffixes auto-stripped
lyrics-fetcher "Artist" "Song" --no-clean
lyrics-fetcher "Artist" "Song" --source lrclib
lyrics-fetcher "Artist" "Song" --no-cache
lyrics-fetcher --clear-cache
```

## Genius fallback (optional, recommended)

1. Get a free token: https://genius.com/api-clients
2. `export GENIUS_ACCESS_TOKEN="your-token-here"`

Genius's public API only returns metadata/annotations, not full lyrics
text, so this fetches the song's Genius page and extracts the lyrics
container directly, same approach the `lyricsgenius` Python library uses.

## Notes on dependency versions

`Cargo.toml` pins fairly conservative crate versions (e.g. `clap 4.4`,
`reqwest 0.11`) because they were built and tested against Rust 1.75. If
your machine has a newer Rust toolchain, feel free to relax the pins and
run `cargo update` to pick up newer releases — nothing in the code relies
on old-version-specific behavior. `Cargo.lock` is included for a
known-working, reproducible build.

Cache lives at `~/.cache/lyrics-fetcher/`, 30-day TTL, same as the Python
version — the two aren't cache-compatible with each other since the Rust
version doesn't share that directory structure with the Python one, but
they won't collide either.
