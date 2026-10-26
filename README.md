# mpv config

[![release badge]][release]

A personal mpv setup meant to look right on any screen — SDR or HDR, standard or high DPI — and for any viewer: clean scaling, subtitles in the amber tone of classic cinema/TV, stereo-normalised audio and a few small quality-of-life scripts.

![mpv with uosc: the timeline, a thumbfast preview and Merriweather subtitles in amber](assets/interface.jpg)

## What's inside

**Video** — starts windowed, capped at 90 % of the screen, borderless with rounded corners. The `high-quality` profile is on by default: EWA Lanczos scaling with antiringing, sigmoid upscaling, correct downscaling, temporal dither, full-range output and HDR peak computation. Motion interpolation and hardware decoding are off by default; debanding is off too (`b` toggles it).

**Subtitles** — Merriweather Bold (700), bundled in [`fonts/`](fonts/) and loaded from `~~/fonts`, so nothing has to be installed. Styling is forced over every track (including ASS/fansub signs); external subs autoload fuzzily, and margins, MKV preroll, embedded fonts and subtitle blending are enabled, so screenshots include them.

| Property | Value |
| --- | --- |
| Fill | `#FCBE11` (amber) |
| Outline | `#1F1F1F`, 1.5 (thin) |
| Size | 40 |
| Spacing | 0.5 |
| Shadow | `#33000000`, 1 px |

**Audio** — stereo downmix with `dynaudnorm`, pitch correction when changing speed, fuzzy external audio.

**Languages** — subtitles English (SDH tracks share the same `en` tag) and then Spanish; audio English first, Spanish second. Subtitle languages are forwarded to yt-dlp.

**Streaming** — 100 s cache and a desktop Firefox user agent over HTTP/HTTPS, maximum HLS bitrate, GIFs and WebM loop.

**Keys** — the extra bindings this config adds:

| Key | Action |
| --- | --- |
| `b` | Toggle deband |
| `v` | Cycle video output levels |
| `s` | Screenshot (PNG) |
| numpad `+` / `-` | Subtitle size ±2 |
| `←` / `→` | Seek −5 s / +5 s † |
| `↑` / `↓` | Seek +60 s / −60 s † |
| `9` / `0` | Volume −2 / +2 † |
| `m` | Mute † |
| `[` / `]` | Speed down / up (×0.91 / ×1.1) † |
| `Backspace` | Speed back to 1× † |

† Flashes uosc's own timeline, volume or speed indicator instead of the built-in OSD bar.

**Scripts** — `autocrop` (black bars, `C` manual), `autodeint` (`Ctrl+d`), `autoload` (queue the folder), `oled-screensaver` (black overlay after 60 s idle), `thumbfast` (timeline thumbnails for uosc).

**Interface** — [uosc](https://github.com/tomasklaen/uosc), installed from its latest official release by the per-system installer (`install-uosc.ps1` on Windows, `install-uosc-ubuntu.sh`, `install-uosc-cachyos.sh` or `install-uosc-macos.sh`): a proximity-based timeline and control bar plus searchable menus for audio/subtitle tracks, subtitle search on OpenSubtitles, playlist, chapters, file browser and keybind lookup, with live timeline thumbnails from [thumbfast](https://github.com/po5/thumbfast). It follows `osd-font` (the system sans-serif) and the `slang` order above. The built-in OSD bar is off and the config is borderless, so uosc draws its own border, window controls and progress indicators. The old minimal OSC (`script-opts/osc.conf`) stays as a fallback if uosc is removed.

**Thumbnails** — [thumbfast](https://github.com/po5/thumbfast) (MPL-2.0) ships in `scripts/`, so hovering uosc's timeline shows a live preview with nothing else to install. It renders them by running mpv in the background, which it looks up in `PATH`. If mpv is not in `PATH` (common on Windows), tell it where mpv is in `script-opts/thumbfast.conf`:

```ini
# script-opts/thumbfast.conf — only needed when mpv is not in PATH
mpv_path=C:\Program Files\mpv\mpv.exe
```

That file is listed in `.gitignore`, so the absolute path stays local. Without uosc, thumbfast simply does nothing.

## Installation

Requires **mpv 0.40 or newer** (the config targets `gpu-next`, the default video output since 0.40; tested on 0.41). Both options start by cloning this repo into your mpv config directory — `%APPDATA%\mpv` on Windows, `~/.config/mpv` on Linux/macOS:

```console
# Windows
cd $HOME/AppData/Roaming/mpv && git init . && git remote add -t \* -f origin https://github.com/mfascioli/mpv-config && git checkout master

# Linux / macOS
cd ~/.config/mpv && git init . && git remote add -t \* -f origin https://github.com/mfascioli/mpv-config && git checkout master
```

### Option 1 — config only

Nothing else to do: player settings, keybinds, Lua scripts, the bundled Merriweather and the minimal bottom-bar OSC in `script-opts/osc.conf`. Launch mpv and it just works, with no network access after cloning.

### Option 2 — config + uosc

Run the installer **after** cloning, from the config directory:

```console
# Windows 10/11 (PowerShell 5.1+)
powershell -ExecutionPolicy Bypass -File .\install-uosc.ps1

# Ubuntu / Debian
bash install-uosc-ubuntu.sh

# CachyOS / Arch
bash install-uosc-cachyos.sh

# macOS
bash install-uosc-macos.sh
```

Each script is native to its system and uses only what is already there:

| System | Downloads with | Extracts with | If a tool is missing |
| --- | --- | --- | --- |
| Windows | `Invoke-WebRequest` | `Expand-Archive` | nothing to install (PowerShell only) |
| Ubuntu / Debian | `curl`, else `wget` | `unzip` | asks, then `sudo apt-get install` of that package only; `--yes` skips the question |
| CachyOS / Arch | `curl` (in base) | `bsdtar` (libarchive, in base) | asks, then `yay` / `paru` / `pacman -S --needed` of that package only; `--yes` skips the question |
| macOS | `curl` (built in) | `unzip` (built in) | stops and says what is missing; installs nothing |

The two Linux scripts refuse to run on the wrong distribution and point to the right one, so nothing is ever installed just to satisfy the wrong OS.

uosc is **not vendored in this repo**: the script downloads it straight from the latest official release at the moment you run it, so you always get the current version instead of a copy frozen in a tag. Option 2 is Option 1 plus the interface; nothing else changes.

What the script does:

- Downloads `uosc.zip` at run time from `github.com/tomasklaen/uosc/releases/latest` over HTTPS — nothing is copied from this repo. Downloads are HTTPS-only, with timeouts and a size cap.
- Verifies the SHA-256 that GitHub publishes for `uosc.zip` (and for `uosc.conf` when it installs one) before extracting or replacing anything — it catches a corrupted download or a tampered CDN, not a compromised upstream release. If the API is unreachable or rate-limited, it stops instead of installing unverified code; `-NoVerify` / `--no-verify` skips the check.
- Checks the archive layout **before** removing an existing uosc, so a broken release cannot leave you without an interface.
- Installs `scripts/uosc/` and its icon font (`fonts/uosc_icons.otf`, `fonts/uosc_textures.ttf`), plus the LGPL-2.1 license next to the code.
- Downloads `script-opts/uosc.conf` (all options with their defaults) **only if you do not have one**; existing settings are kept.
- Leaves `mpv.conf`, `input.conf`, the other scripts and Merriweather untouched.
- Accepts `-ConfigDir <path>` / `--config-dir <path>` to install into another config directory, `-Force` / `--force` to replace `uosc.conf` with the defaults, `-NoVerify` / `--no-verify` to skip the SHA-256 check, and `-y` / `--yes` to install a missing tool without asking. The config directory must already exist; the installers do not create it.

Those paths are listed in `.gitignore`, so `git pull` never overwrites the installed uosc or its config, and an accidental `git add -A` will not commit the 17 MB of binaries.

### Updating

```console
# config
git -C <config dir> pull

# uosc — run the installer again; it keeps your script-opts/uosc.conf and verifies the checksum
# Windows
powershell -ExecutionPolicy Bypass -File .\install-uosc.ps1

# Ubuntu / Debian
bash install-uosc-ubuntu.sh

# CachyOS / Arch
bash install-uosc-cachyos.sh

# macOS
bash install-uosc-macos.sh
```

uosc also has its own **Utils → Update uosc**, which pipes the latest `master` installer straight into a shell (`irm … | iex` on Windows, `source <(curl …)` on Linux/macOS). It works, but it runs unreviewed code; the installers above download a release archive and check its layout instead.

### Uninstalling uosc

```console
# Windows
powershell -ExecutionPolicy Bypass -File .\uninstall-uosc.ps1

# Linux / macOS
bash uninstall-uosc.sh
```

It deletes `scripts/uosc/`, the two `fonts/uosc_*` files and `script-opts/uosc.conf`, leaving everything else intact. Add `-KeepConf` / `--keep-conf` to keep your uosc preferences for a later reinstall. The built-in OSC takes over immediately, no config change needed.

See [CHANGELOG.md](CHANGELOG.md) for release notes.

## Why this look?

**Amber instead of white.** `#FCBE11` is the subtitle yellow I remember from the cinema and from TV at home: warm, familiar, a little nostalgic. On dark scenes it is easier on the eyes than pure white, with less glare over a two-hour film.

**Merriweather Bold.** A screen serif with a tall x-height and low stroke contrast, so lowercase stays solid at subtitle size and survives ClearType without thin strokes glowing. Bold 700 carries a *thin* outline instead of the usual fat black border and keeps its shape over busy footage, where airier book serifs such as Source Serif or IBM Plex Serif lose detail. [More on the font](https://fontfyi.com/blog/source-serif-vs-merriweather/).

Based on [wopian/mpv-config](https://github.com/wopian/mpv-config). Interface by [uosc](https://github.com/tomasklaen/uosc) (LGPL-2.1); timeline thumbnails by [thumbfast](https://github.com/po5/thumbfast) (MPL-2.0); Merriweather under the SIL OFL (see [`Merriweather-OFL.txt`](Merriweather-OFL.txt)).

[release]:https://github.com/mfascioli/mpv-config/releases
[release badge]:https://flat.badgen.net/github/release/mfascioli/mpv-config
