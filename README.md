# mpv config

[![release badge]][release]

A personal mpv setup focused on subtitled anime and series: clean scaling, subtitles that stay readable over any scene, stereo-normalised audio, and a handful of small quality-of-life scripts.

![Subtitles rendered in Merriweather Bold: amber fill (#FCBE11) with a thin near-black outline](assets/subtitles.jpg)

## What's inside

### Video

- Starts **windowed and paused** (`fs=yes` is intentionally commented out); press `f` for fullscreen.
- Window capped at 90 % of the screen (`autofit-larger=90%x90%`), borderless, rounded corners.
- `high-quality` profile enabled by default: EWA Lanczos scaling (`ewa_lanczossharp` / `ewa_lanczossoft`), antiringing on luma and chroma, sigmoid upscaling, correct downscaling, temporal dither, full-range output and HDR peak computation.
- **Motion interpolation is deliberately off** (`video-sync=audio`): no frame interpolation, no `tscale` tuning.
- Debanding off by default (`b` toggles it); parameters are pre-tuned for when it is enabled.
- Hardware decoding is disabled by default (`hwdec=auto` is commented out).

### Subtitles

- **Font:** Merriweather Bold (700), bundled in [`fonts/`](fonts/) and loaded through `sub-fonts-dir=~~/fonts`, so **no system installation is needed**. Licensed under the SIL OFL (see [`Merriweather-OFL.txt`](Merriweather-OFL.txt)).
- **Styling:** forced over every track (`sub-ass-override=force`), including styled ASS/fansub signs.
- External subtitles autoload fuzzily, searching `ass`, `srt`, `sub`, `subs` and `subtitles` subdirectories; embedded MKV subtitles are prerolled while seeking and embedded fonts are used for ASS tracks.
- Margins are respected and subtitles are blended into the video, so screenshots include them.
- Numpad `+` / `-` resize subtitles on the fly, with an on-screen readout.
- The OSD uses Alte Haas Grotesk Regular (system font), 14 px, translucent white.

| Property | Value |
| --- | --- |
| Fill colour | `#FCBE11` (amber) |
| Outline colour | `#1F1F1F` (near-black) |
| Outline width | `1.5` (thin) |
| Font size | `40` |
| Letter spacing | `0.5` |
| Shadow | `#33000000`, 1 px offset |

### Audio

- Downmix to stereo with `dynaudnorm` loudness normalisation.
- Pitch correction enabled when changing playback speed.
- External audio tracks autoload fuzzily.

### Language preferences

- Subtitles: `enGB, en-GB, en, eng, enUS, en-US, unknown`.
- Audio: Japanese first, then English.
- Subtitle languages are also forwarded to yt-dlp.

### Streaming

- 100 s of cache and a desktop Firefox user agent for HTTP/HTTPS.
- Maximum HLS bitrate for streams; GIFs and WebM loop and start unpaused.

### Keybindings

Beyond the mpv defaults:

| Key | Action |
| --- | --- |
| `b` | Toggle debanding |
| `v` | Toggle full / limited video output levels |
| `s` | Screenshot (saved as PNG) |
| Numpad `+` | Subtitles bigger (+2) |
| Numpad `-` | Subtitles smaller (−2) |

### Scripts

- `autocrop.lua` — auto-crops black bars at the start of playback (`C` to crop manually).
- `autodeint.lua` — detects interlaced or telecined content and applies the right deinterlacer (`Ctrl+d` to run it).
- `autoload.lua` — queues the rest of the folder automatically.
- `oled-screensaver.lua` — fades a black overlay over the screen after 60 s of inactivity (optional rainbow drift) to protect OLED panels.

### Shaders (optional, not loaded by default)

- `antiring.hook` — antiringing for luma and chroma.
- `noise_static_luma.hook` / `noise_static_chroma.hook` — static noise to mask banding.

### Extras

- `script-opts/osc.conf` — minimal bottom bar, no dead zone or fade, title shows the filename.
- `encoding-profiles.conf` — stock mpv encoding profiles (MP4, WebM, AVI, DVD, etc.).

## Why Merriweather?

Because subtitles are read at a glance, over moving footage, often for two hours straight — not typeset in a book:

- **Screen-native serif with a very tall x-height** (~76–77 % of cap height), so lowercase letters stay substantial even at subtitle sizes.
- **Low stroke contrast and sturdy serifs**, which survive Windows/ClearType at standard DPI without the thin strokes smearing or glowing (halation) against dark scenes.
- **Compact, dense texture**: it sits solidly over busy backgrounds and reads instantly, where airier book serifs such as Source Serif 4 or IBM Plex Serif lose their finer details at this size and viewing distance.
- **Bold 700** gives enough weight to work with a *thin* outline instead of the usual fat black border.

For a fuller comparison of the screen-serif trade-offs, see [Source Serif vs Merriweather: Screen Serif Showdown](https://fontfyi.com/blog/source-serif-vs-merriweather/).

## Usage

Requires the following font to be installed on the system: `Alte Haas Grotesk Regular` (used by the OSD only).

Subtitles use Merriweather Bold, bundled in [`fonts/`](fonts/) and loaded automatically from mpv's `~~/fonts` directory, so no system installation is needed. The font is licensed under the SIL Open Font License (see [`Merriweather-OFL.txt`](Merriweather-OFL.txt)).

### Windows

#### Install

```console
cd $HOME/AppData/Roaming/mpv
git init .
git remote add -t \* -f origin https://github.com/wopian/mpv-config
git checkout master
```

#### Update

```console
git -C $HOME/AppData/Roaming/mpv pull
```

### BSD, Linux & MacOS

#### Install

```console
cd ~/.config/mpv
git init .
git remote add -t \* -f origin https://github.com/wopian/mpv-config
git checkout master
```

#### Update

```console
git -C ~/.config/mpv pull
```

## Example

[diff.pics comparison](http://diff.pics/UasGxbWi3k4W/1)

### Config

![](https://i.imgur.com/qamsvtC.jpg)

### Default (0.24.0)

![](https://i.imgur.com/UTUPumd.jpg)

[release]:https://github.com/wopian/mpv-config/releases
[release badge]:https://flat.badgen.net/github/release/wopian/mpv-config
