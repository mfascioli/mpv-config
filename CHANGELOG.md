# Changelog

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
