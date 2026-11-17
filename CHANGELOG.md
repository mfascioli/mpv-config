# Changelog

## Unreleased

- **Docs:** shorter banners with the same type sizes — hero 1600×470, specimen 1200×400, strips 1200×158 — so the page no longer fills with images, and the credits section gains its own strip.
- **Docs (Spanish):** `README.es.md` mirrors the README in Spanish, reachable from a language button at the top of both files.

## 1.2.8 — 2026-11-17

- **Video:** `hwdec=auto-copy` is on. GPU decoding cuts CPU load and can lower power draw, and copy-back keeps the lavfi filters working — `auto`/`auto-safe` broke `idet` (`Ctrl+d`) and would break `cropdetect`. `auto-safe` is only an alias of `auto` in mpv 0.40+.
- **Docs:** the README is denser on phones. The hero is 1600×600, the specimen 1200×470 and the strips 1200×180 with larger type, and the keyboard map uses a 15-column ortholinear grid without gaps. **Updating** and **Uninstalling uosc** gain strips, and the README ends with a **Privacy: uosc subtitle search** section: what OpenSubtitles receives, what the source audit covered and what it cannot prove.

## 1.2.7 — 2026-11-17

- **Audio profiles:** `Off` is now **No Processing** and the other profiles are **Cinematic** (−23 LUFS), **Balanced** (−18 LUFS) and **Night Mode** (−16 LUFS). The script ids and bindings follow the names (`audio_norm/no_processing|cinematic|balanced|night_mode`), so `input.conf`, the OSD and the docs use one vocabulary. Targets and filter chains are unchanged.
- **Zoom:** `Ctrl`+wheel now moves `video-zoom` with an on-screen value; `z` and `Shift+z` are freed and no longer touch the image. `Alt+Backspace` still resets zoom, pan and alignment.
- **Screenshots:** `F10` captures without subtitles and `Shift+F10` with them. `PrintScreen`, `Ctrl+PrintScreen` and `Ctrl+F10` are gone; the print key stays with the system.
- **Keybindings:** freed mpv defaults that could fight the config — `u` (ASS override), `V` (ASS video data), `A` (forced aspect), `F`/`G` (subtitle scale), `E` (editions), `v` (output levels) and horizontal wheel seeking. `d` and `Ctrl+d` remain for deinterlacing.
- **Autocrop:** the automatic crop now waits 10 s after playback starts (`autocrop-auto_delay=10`), so fades and title cards do not skew detection; `C` still applies or undoes it.
- **Docs:** the README section is **Keybindings**, and the same term is used across docs, comments and images. The keyboard map gains a mouse panel (`CTRL+WHEEL`, `ALT+BACKSPACE`, `CTRL+DRAG`, right click, left click), the new profile names and the new screenshot keys, and the banners are regenerated for 1.2.7 with the audio strip listing the four profile names.

## 1.2.6 — 2026-11-17

- **Docs (design):** the specimen line in `assets/design.png` now reads "Anyway, I hope everything goes smoothly." instead of "The city never looked this quiet." Same size, colour, outline and position; the banners are regenerated for 1.2.6.

## 1.2.5 — 2026-11-16

- **Fixed:** the arrow keys seek exactly. `←`/`→` move 5 s and `↑`/`↓` 60 s instead of landing on the nearest keyframe, which made a 5 s seek jump 8 s or more on sparse-keyframe files.

## 1.2.4 — 2026-11-16

- **Docs (subtitles):** the black bars are now described as subtitle behaviour instead of a letterbox feature. The hero chip reads `ADAPTIVE SUBTITLES`, the subtitles strip reads `ADAPTIVE PLACEMENT`, and the README explains that subtitles follow the window, stay sharp at any size and never stretch with the picture, whatever the aspect ratio.

## 1.2.3 — 2026-11-16

- **Docs (accuracy):** subtitles reach the black bars of any letterboxed source, not only 21:9 content. The hero chip now reads `LETTERBOX BARS`, the README explains the behaviour without assuming an aspect ratio, and the 1.2.0 entry says so too.

## 1.2.2 — 2026-11-16

- **Docs (design):** the README opens with a HUD banner and moves "Why this look?" into a **Design** section, next to the palette, the Merriweather rationale and the subtitle-style tokens. Audio, subtitles and installation gain matching section banners; the subtitle specimen renders the bundled Merriweather at the real colours and outline.
- **Images:** `assets/banner.py` (Python + Pillow) draws the five banners deterministically from the bundled Fira Sans Condensed in `assets/fonts/` (SIL OFL, subset to latin). `assets/keys.ps1` still draws the keyboard map.
- **AGENTS.md:** the public file keeps the portable guidance; the vault path, packaging and sync steps moved to a gitignored `AGENTS.local.md`, and mpv 0.42 is recorded as a tested target.

## 1.2.1 — 2026-11-16

- **Fixed:** `window-corners=round` removed from `mpv.conf`. mpv 0.42 dropped the option, so every launch logged `Error parsing option window-corners` and ignored it. The window stays borderless; the rounding only applied on Windows and macOS.
- **Docs (installation):** the install and update sections were rewritten around a single `git clone` instead of `git init` plus a remote and a checkout. One short block per system backs up an existing config as `mpv.backup` and does nothing when there is none; uosc is a separate optional step; updating is split into two copy-paste commands (`git -C … pull --ff-only` for the config, rerun the installer for uosc) with no placeholder paths. Adds a "do not clone again" pointer for existing installs, absolute-path installer and uninstaller commands, and a note on `git stash` when tracked files were edited locally.

## 1.2.0 — 2026-11-16

- **Audio profiles:** new `scripts/audio-norm.lua` with four profiles on `1`–`4`: Off (no filters), Soft (−23 LUFS, `loudnorm` only, −1 dBTP), Balanced (−18 LUFS, `loudnorm` only, −2 dBTP) and Night (−16 LUFS, 4:1 compression at −18 dB before `loudnorm`, −3 dBTP). Playback starts in Off (1), so files play untouched until a profile is chosen. Soft, Balanced and Night force `loudnorm`'s dynamic mode with `linear=false`; `alimiter` with `level=0` is the final sample-peak stage. Replaces the old always-on `dynaudnorm`.
- **Volume:** `volume=100` is now only the startup level. Numpad `0`–`9` sets 0 %, 11.1 %, …, 88.9 %, 100 %, numpad `/` and `*` adjust ±2, and the uosc volume indicator flashes. `volume-max=100` still blocks gain above 100 %. `scripts/neutral-volume.lua` was removed, so mpv's volume is no longer held at unity. `m` and the keyboard's mute key still mute.
- **Keys:** `q`/`w` move subtitles up/down, `a`/`s` change subtitle delay, `z`/`Shift+z` zoom (panscan), `PrintScreen`/`Ctrl+PrintScreen` screenshot without/with subtitles (`F10`/`Ctrl+F10` fallback), numpad `+`/`-` change subtitle size. `r`, `t`, `e`, `x`, `Shift+q`, `5`–`8`, horizontal `9`/`0`, `/`, `*`, mouse wheel up/down, `S`, `Ctrl+s`, `Alt+s`, `Ctrl+w` and the volume-up/down media keys are unbound. Only `1`–`4` remain horizontal number bindings; the numpad digits control volume.
- **Subtitles:** `blend-subtitles=no` keeps subtitles on the OSD layer instead of embedding them in the video, which is what allows them to sit in the letterbox bars (21:9 content on a 16:9 screen, for example) with `sub-pos` up to 150. The new `scripts/subtitle-size.lua` saves the size chosen with numpad `+`/`-` to `subtitle-size.txt` (gitignored) and restores it on the next launch; delete the file to return to `sub-font-size=40`.
- **Closing:** new `scripts/esc-quit.lua`. `Esc` leaves fullscreen first and quits on the next press; `Shift+Esc` quits and saves the position. `q` no longer quits. `save-position-on-quit` still covers the window close button.
- **Resume:** `watch-later-options-remove` drops `af`, `volume` and `mute` from new resume files, and the audio script reasserts the selected profile whenever a file loads. Old watch-later files may still carry `af` or a volume; the profile is reasserted on load.
- **Docs:** README now documents the full key map, the four profiles (LUFS, LRA, compressor, true peak, limiter), the loudness concepts and best uses, numpad volume, subtitles in the black bars, subtitle-size persistence, the scripts and the two screenshot modes. Adds `assets/keys.png`, a SQUAD-style keyboard map with every binding, and `AGENTS.md`, which records the project's preferences and style for future edits.

## 1.1.0

- **Interface (optional):** [uosc](https://github.com/tomasklaen/uosc) installed from its latest official release (`install-uosc.ps1` on Windows, `install-uosc-ubuntu.sh` / `install-uosc-cachyos.sh` / `install-uosc-macos.sh` elsewhere), not vendored. Without it the config uses the minimal OSC in `script-opts/osc.conf`. Includes proximity-based timeline and control bar, searchable track/subtitle menus, OpenSubtitles search, playlist, chapters and file browser; respects `osd-font` and `slang`.
- **Installers:** one native script per system, using only its own tools — Windows (`install-uosc.ps1`, PowerShell), Ubuntu/Debian (`install-uosc-ubuntu.sh`, `curl`/`wget` + `unzip` with apt), CachyOS/Arch (`install-uosc-cachyos.sh`, `curl` + `bsdtar` with yay/paru/pacman) and macOS (`install-uosc-macos.sh`, built-in `curl` + `unzip`). A missing tool is installed only after asking, one package at a time. `uninstall-uosc.ps1` / `uninstall-uosc.sh` remove uosc again, keeping `uosc.conf` with `-KeepConf` / `--keep-conf`.
- **Integration:** `osd-bar` disabled; seeks, volume and speed flash uosc's own timeline/volume/speed indicators (the window was already borderless, so uosc draws the border and window controls).
- **Fixed:** `cscale=ewa_lanczossoft` only exists in the `gpu` output; with `gpu-next` (mpv's default since 0.40) mpv logged an error and fell back to a default chroma scaler. Now uses `ewa_lanczos`.
- **Thumbnails:** [thumbfast](https://github.com/po5/thumbfast) bundled in `scripts/` (MPL-2.0), so uosc shows live previews while hovering the timeline. It runs mpv in the background instead of ffmpeg; `script-opts/thumbfast.conf` with `mpv_path=` is only needed when mpv is not in `PATH` (typical on Windows), and that file is gitignored.
- **Licensing:** uosc is LGPL-2.1 (see `scripts/uosc/LICENSE.LGPL`); thumbfast is MPL-2.0 (notice in `scripts/thumbfast.lua`).

## 1.0.1

- OSD now uses the system default sans-serif instead of Alte Haas Grotesk, so no system font is required.

## 1.0.0

First stable release.

- **Video:** `high-quality` profile by default (EWA Lanczos, antiringing, sigmoid upscaling, correct downscaling, temporal dither, full-range output, HDR peak computation); windowed start at most 90 % of the screen; motion interpolation and hardware decoding disabled.
- **Subtitles:** Merriweather Bold 700 bundled in `fonts/` (no install), amber fill `#FCBE11`, near-black outline `#1F1F1F`, size 40, thin 1.5 outline, optional soft shadow; forced over ASS tracks; fuzzy external subs, MKV preroll, embedded fonts and subtitle blending.
- **Audio:** stereo downmix with `dynaudnorm`, pitch correction, fuzzy external audio.
- **Languages:** English then Spanish for audio and subtitles (SDH shares the English tag); subtitle languages forwarded to yt-dlp.
- **Network:** 100 s cache, desktop user agent, maximum HLS bitrate, GIF/WebM looping.
- **Keys:** `b` deband, `v` output levels, `s` screenshot, numpad `+`/`-` subtitle size.
- **Scripts:** autocrop, autodeint, autoload, OLED screensaver.
- **Removed:** motion interpolation and its `tscale` tuning, fullscreen-on-start, pause-on-start, unused fork metadata (Renovate config, funding metadata, editor settings) and stock files mpv never used (encoding profiles, shaders).
