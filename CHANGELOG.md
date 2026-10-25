# Changelog

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
