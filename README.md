# mpv config

[![release badge]][release]

![MPV CONFIG banner: amber title over a charcoal HUD grid with tags for SDR/HDR, GPU-NEXT, letterbox bars and four audio profiles](assets/banner.png)

Clean scaling on any screen — SDR, HDR, standard or high DPI — amber subtitles, four audio profiles and a handful of small scripts. Based on [wopian/mpv-config](https://github.com/wopian/mpv-config).

![mpv with uosc: timeline, thumbfast preview and Merriweather subtitles in amber](assets/interface.jpg)
<sub>Wicked City | 1987 — Yoshiaki Kawajiri. Spoiler: it did not go smoothly at all.</sub>

## 🎨 Design

**Amber, not white.** `#FCBE11` is the subtitle yellow I remember from the cinema and from TV at home: warm, familiar, a little nostalgic. On dark scenes it is easier on the eyes than pure white, with less glare over a two-hour film.

**Merriweather Bold.** A screen serif with a tall x-height and low stroke contrast, so lowercase stays solid at subtitle size and survives ClearType. Bold 700 carries a *thin* outline instead of the usual fat black border and keeps its shape over busy footage, where airier serifs such as Source Serif or IBM Plex Serif lose detail. [More on the font](https://fontfyi.com/blog/source-serif-vs-merriweather/).

![Subtitle specimen: amber Merriweather over charcoal, with fill, outline, shadow and type tokens](assets/design.png)

Subtitle style: fill `#FCBE11` · outline `#1F1F1F` at 1.5 · size 40 · spacing 0.5 · shadow `#33000000` at 1 px.

## What's inside

- **Video** — windowed at most 90 % of the screen, borderless. The `high-quality` profile is on by default: EWA Lanczos with antiringing, sigmoid upscaling, correct downscaling, temporal dither, full-range output and HDR peak computation. Motion interpolation and hardware decoding are off; debanding is off too (`b` toggles it).
- **Subtitles** — Merriweather Bold 700, bundled in [`fonts/`](fonts/) and loaded from `~~/fonts`, so nothing needs installing. Styling is forced over every track (ASS/fansub signs included); external subs autoload fuzzily; margins, MKV preroll and embedded fonts are enabled. They stay on their own layer (`blend-subtitles=no`) so `w` can drop them into the horizontal black bars of any letterboxed source, whatever its aspect ratio. Size chosen with numpad `+` / `-` survives restarts.
- **Audio** — stereo downmix, pitch correction when changing speed, fuzzy external audio. Four profiles on `1`–`4`, starting in Off; see [Audio profiles](#-audio-profiles).
- **Languages** — subtitles English (SDH shares the `en` tag) then Spanish; audio English then Spanish; forwarded to yt-dlp.
- **Streaming** — 100 s cache, desktop Firefox user agent, maximum HLS bitrate, looping GIF/WebM.
- **Scripts** — `audio-norm` (profiles), `subtitle-size` (persistence), `esc-quit` (two-step close), `autocrop` (`C`), `autodeint` (`Ctrl+d`), `autoload` (queue the folder), `oled-screensaver` (black overlay after 60 s idle), `thumbfast` (timeline previews).
- **Interface** (optional) — [uosc](https://github.com/tomasklaen/uosc) installed from its latest release by the per-system installer ([step 3](#-installation)): proximity timeline, control bar, searchable menus for tracks, OpenSubtitles search, playlist, chapters, file browser and keybind lookup, all with thumbfast previews. It follows `osd-font` and the subtitle-language order; the volume slider mirrors the numpad keys (set `volume=none` in `script-opts/uosc.conf` to hide it). Without uosc the minimal OSC in `script-opts/osc.conf` takes over.
- **Thumbnails** — [thumbfast](https://github.com/po5/thumbfast) (MPL-2.0) ships in `scripts/` and renders previews by running mpv from `PATH`. If mpv is not in `PATH` (common on Windows), point to it in `script-opts/thumbfast.conf` (gitignored):

  ```ini
  mpv_path=C:\Program Files\mpv\mpv.exe
  ```

## Keys

![Keyboard map: amber keys mark every binding; the numpad sets volume and subtitle size](assets/keys.png)

| Key | Action |
| --- | --- |
| `1` / `2` / `3` / `4` | Audio profile: Off / Soft / Balanced / Night |
| `m` | Mute † |
| `q` / `w` | Subtitles up / down (past 100 % they enter the black bars) |
| `a` / `s` | Subtitle delay −100 ms / +100 ms |
| `z` / `Shift+z` | Zoom (panscan) more / less |
| `PrintScreen` / `Ctrl+PrintScreen` | Screenshot without / with subtitles |
| `F10` / `Ctrl+F10` | Same, when the OS captures PrintScreen |
| `Esc` | Leave fullscreen; when windowed, quit (a uosc menu closes first) |
| `Shift+Esc` | Quit and save the position |
| `b` / `v` | Toggle deband / cycle video output levels |
| `←` / `→` | Seek −5 s / +5 s † |
| `↑` / `↓` | Seek +60 s / −60 s † |
| `[` / `]` | Speed down / up (×0.91 / ×1.1) † |
| `Backspace` | Speed back to 1× † |
| numpad `0`–`9` | Volume 0 %, 11.1 %, …, 88.9 %, 100 % † |
| numpad `+` / `-` | Subtitle size ±2 (saved between runs) |
| `C` / `Ctrl+d` | Autocrop / autodeint |

† Flashes uosc's own timeline, volume or speed indicator instead of the built-in OSD bar.

`f`, `Space`, double-click fullscreen and the usual track/playlist keys are mpv defaults. Deliberately unbound: `r`, `t`, `e`, `x`, `Shift+q`, `5`–`8`, horizontal `9`/`0`, `/`, `*`, wheel up/down, `S`, `Ctrl+s`, `Alt+s`, `Ctrl+w` and the volume media keys. Only `1`–`4` are horizontal number keys; the numpad digits set volume. `q` no longer quits: `Esc` and `Shift+Esc` are the quit keys (`Ctrl+c` still force-quits).

**Closing** is two-step on purpose. In fullscreen, `Esc` leaves fullscreen and only the next press quits. `Shift+Esc` always quits and saves the position; the window close button also saves (`save-position-on-quit`). Resume keeps the position, not the audio profile — the script reasserts the selected profile on load.

**Screenshots** — `PrintScreen` captures the frame, `Ctrl+PrintScreen` adds subtitles; `F10`/`Ctrl+F10` do the same where the OS reserves PrintScreen. On Windows 11 disable *Settings → Accessibility → Keyboard → Use the Print Screen key to open Snipping Tool* if it never reaches mpv. PNG output; with `blend-subtitles=no` neither mode includes the letterbox bars. The old `s`/`S`/`Ctrl+s`/`Alt+s` bindings are gone so `s` can adjust subtitle delay.

## 🎚 Audio profiles

![Audio banner: FOUR PROFILES — Off, Soft, Balanced, Night](assets/audio.png)

`scripts/audio-norm.lua` owns the filter chain. Each key **replaces** it, and playback starts in **1 — Off**. Bindings call named script bindings, so they can be remapped without touching the Lua.

| Key | Profile | Target | Peak | Character |
| --- | --- | ---: | ---: | --- |
| `1` | Off (default) | — | — | original mix |
| `2` | Soft | −23 LUFS | −1 dBTP | wide, natural |
| `3` | Balanced | −18 LUFS | −2 dBTP | controlled |
| `4` | Night | −16 LUFS | −3 dBTP | dialogue lifted |

| Key | Processing | I (LUFS) | LRA | TP (dBTP) | `alimiter` |
| --- | --- | ---: | ---: | ---: | ---: |
| `1` | none | — | — | — | — |
| `2` | `loudnorm` | −23 | 18 | −1 | −1 dBFS |
| `3` | `loudnorm` | −18 | 15 | −2 | −2 dBFS |
| `4` | `acompressor` 4:1 at −18 dB → `loudnorm` | −16 | 7 | −3 | −3 dBFS |

Soft, Balanced and Night use `loudnorm` in single-pass dynamic mode (`linear=false`): gain follows the target live, no pre-scan. Night adds one compressor stage — threshold `0.125` (≈ −18 dBFS), ratio `4:1`, attack `20 ms`, release `250 ms`, knee `2.5`, unity makeup. Every processed profile ends in `alimiter` (`level=0`, 5 ms attack / 50 ms release): `loudnorm`'s TP is the true-peak target, `alimiter` the sample-peak safety net.

- **LUFS** — perceived loudness; `loudnorm` drives gain to the target and constrains LRA and TP.
- **Loudness ≠ volume** — loudness belongs to the recording; volume to the player, OS, DAC or speakers.
- **Dynamic normalization** — adjusts as it plays; no pre-scan, so results depend on the source.
- **Compression** — `acompressor` turns down what exceeds its threshold, shrinking the gap between dialogue and effects.
- **LRA** — the quiet-to-loud span; a lower target compresses it more. Labels describe the intended result, not a measurement of every soundtrack.

**Volume** starts at 100. Numpad `0`–`9` sets 0 %, 11.1 %, …, 88.9 %, 100 % (0 is silent, 9 is full scale); `/` and `*` adjust ±2; `m` and the mute key mute. `volume-max=100` blocks gain above 100 %, and the horizontal volume keys, wheel and media keys stay unbound.

**Resume** restores position only: `watch-later-options-remove` drops `af`, `volume` and `mute` from new watch-later files, and the profile is reasserted on every load. Old watch-later files may still carry a volume; deleting them clears it.

## 💬 Subtitles: bars and size

![Subtitles banner: AMBER & MERRIWEATHER — bars, size and delay](assets/subtitles.png)

`blend-subtitles=no` keeps subtitles on the OSD layer, outside the video image — that is what lets them reach the letterbox bars of any source, whatever its aspect ratio. `sub-use-margins=yes` and `sub-ass-force-margins=yes` allow the text there. `sub-pos` runs 0–150; 100 is the normal spot just above the bottom edge, and `w` (or ~100–106) moves the text into the bottom bar. Much higher approaches the window edge and can clip, especially with two lines. A 21:9 film on a 16:9 screen is the common case; a 4:3 film on a 16:9 screen works the same way, with wider bars.

Numpad `+` / `-` (or `G` / `F`) change the size; `scripts/subtitle-size.lua` writes every change to `subtitle-size.txt` and restores it at startup. The file is gitignored — delete it to fall back to `sub-font-size=40`.

## 📥 Installation

![Installation banner: ONE CLONE — mpv 0.40+, uosc optional](assets/installation.png)

Requires **mpv 0.40+** (`gpu-next`; tested on 0.41 and 0.42). The repository *is* the config folder, so installing is one clone. **Already using this config?** Do not clone again — go to [Updating](#-updating).

**1 — Clone.** Pick your system; the rename keeps an old config as `mpv.backup` and does nothing when there is none. Git is the only tool needed — on Windows, install [git-scm.com](https://git-scm.com/downloads) first.

Windows (PowerShell):

```console
if (Test-Path "$env:APPDATA\mpv") { Move-Item "$env:APPDATA\mpv" "$env:APPDATA\mpv.backup" }
git clone https://github.com/mfascioli/mpv-config.git "$env:APPDATA\mpv"
```

Linux / macOS:

```console
mv ~/.config/mpv ~/.config/mpv.backup 2>/dev/null
git clone https://github.com/mfascioli/mpv-config.git ~/.config/mpv
```

**2 — Start mpv.** Settings, keys, scripts, the Merriweather font and a minimal OSC are ready. mpv finds the folder by itself — no flags, no network.

**3 — Optional: uosc.** The timeline, control bar, menus and search. Run one command; skip it to keep the minimal OSC:

```console
powershell -ExecutionPolicy Bypass -File "$env:APPDATA\mpv\install-uosc.ps1"   # Windows 10/11
bash ~/.config/mpv/install-uosc-ubuntu.sh                                      # Ubuntu / Debian
bash ~/.config/mpv/install-uosc-cachyos.sh                                     # CachyOS / Arch
bash ~/.config/mpv/install-uosc-macos.sh                                       # macOS
```

The installer is native to each system, fetches the latest uosc release over HTTPS, verifies GitHub's SHA-256 and keeps an existing `script-opts/uosc.conf`. Linux needs `curl`/`wget` plus `unzip`/`bsdtar` and asks before installing a missing package (`--yes` / `-y` skips the question); `--no-verify` skips the checksum. Everything it installs is gitignored, so updates never overwrite uosc, and each Linux installer refuses to run on the wrong distro. Config folder somewhere else? Append `-ConfigDir <path>` / `--config-dir <path>`.

### 🔄 Updating

Two independent pieces — update them separately.

**The config.** One command, no need to open the folder:

```console
git -C "$env:APPDATA\mpv" pull --ff-only   # Windows
git -C ~/.config/mpv pull --ff-only        # Linux / macOS
```

Files you added and the gitignored `script-opts/*.conf` are left alone. Your own edits to tracked files block the pull: move them aside or `git stash` first.

**uosc.** Rerun its installer, the same command as step 3. It replaces uosc only and keeps `uosc.conf`.

uosc's **Utils → Update uosc** also works, but pipes the latest `master` installer into a shell (`irm … | iex`, `source <(curl …)`); the installer above downloads a release and validates its layout first.

### 🗑 Uninstalling uosc

```console
powershell -ExecutionPolicy Bypass -File "$env:APPDATA\mpv\uninstall-uosc.ps1"   # Windows
bash ~/.config/mpv/uninstall-uosc.sh                                            # Linux / macOS
```

Removes `scripts/uosc/`, the two `fonts/uosc_*` files and `script-opts/uosc.conf`, leaving the rest intact; `-KeepConf` / `--keep-conf` keeps your preferences. The built-in OSC takes over immediately. To remove the config itself, delete its folder — your old files are still in `mpv.backup`.

See [CHANGELOG.md](CHANGELOG.md) for release notes.

## Credits

Interface by [uosc](https://github.com/tomasklaen/uosc) (LGPL-2.1); thumbnails by [thumbfast](https://github.com/po5/thumbfast) (MPL-2.0); Merriweather under the SIL OFL (see [`Merriweather-OFL.txt`](Merriweather-OFL.txt)).

[release]:https://github.com/mfascioli/mpv-config/releases
[release badge]:https://flat.badgen.net/github/release/mfascioli/mpv-config
