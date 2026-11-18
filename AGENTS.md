# AGENTS.md

Project context and standing preferences for this mpv config. Read this before
editing; it is the source of truth when the request and the existing files
disagree.

## Scope

Personal mpv setup in `mpv.conf`, `input.conf` and `scripts/`, forked from
[wopian/mpv-config](https://github.com/wopian/mpv-config). Targets mpv 0.40+
(`gpu-next`), verified on 0.41 and 0.42. uosc is installed from its official
release by the per-system installers and is not vendored.

Machine-specific notes — working copy, packaging, syncing — live in
`AGENTS.local.md`, which is gitignored and never shipped.

## Language

Everything that ships stays in **English**: README, CHANGELOG, code comments,
OSD messages, commit messages, image labels, filenames. Never reintroduce
Spanish aliases such as *Cine*, *Películas*, *Estándar* or *Noche*, and check
for leftovers before calling a task done.

The one exception is `README.es.md`, a full Spanish mirror linked from a
language button at the top of both files:

```markdown
[![release badge]][release] [![Español](https://img.shields.io/badge/Espa%C3%B1ol-FCBE11?style=flat-square)](README.es.md)   <!-- README.md -->
[![release badge]][release] [![English](https://img.shields.io/badge/English-FCBE11?style=flat-square)](README.md)         <!-- README.es.md -->
```

The button sits on the same line as the release badge, in the banner amber
(`FCBE11`, `flat-square`). Do not use the flag emoji: Windows and GitHub do not
render it reliably, so the coloured badge carries the attention instead.

- Keep both files in step: same sections, same order, same images, same
  commands. Translate the prose and the section headings, not the interface.
- Untranslated on purpose: **keybindings** (the term, and its heading),
  profile names (`No Processing`, `Cinematic`, `Balanced`, `Night Mode`),
  filter names, key names, option values and file paths.
- The images stay English; do not build a second set of Spanish banners.
- Spanish anchors are accented (`#-perfiles-de-audio`,
  `#-privacidad-búsqueda-de-subtítulos-de-uosc`); update every internal link
  when a heading changes.

## Terminology

Use **keybindings** (English) for the assignments, everywhere: README, image
labels, comments, CHANGELOG. Do not alternate with *hotkeys*, *keys* or
*bindings* when referring to assignments. *Keys* is only acceptable for the
physical keyboard (`numpad keys`, `arrow keys`).

## Hardware decoding

`hwdec=auto-copy` in `mpv.conf`. It cuts CPU load and can lower power draw, and
copy-back is required because lavfi filters (`idet` for `Ctrl+d`, `cropdetect`
for autocrop) fail on direct hwdec interop. `auto-safe` is only an alias of
`auto` in mpv 0.40+, so it is not a safer choice and it breaks those filters.
Autocrop disables hwdec for its detection window; `autodeint` does not, which is
why copy-back is the configured default.

## Video display

`[default]` applies `[high-quality]`, so every file gets this chain. `gpu-next`
is the default VO in mpv 0.40+, and the scaler path only runs when the frame and
the window differ (`scaler-resizes-only`).

| Stage | Setting |
| --- | --- |
| Output | `gpu-next`, `gpu-context=auto`, Vulkan async compute/transfer, one queue |
| Decode | `hwdec=auto-copy` |
| Upscale | `scale=ewa_lanczossharp`, `scale-radius=2`, `scale-antiring=1` |
| Downscale | `dscale=ewa_lanczossharp`, `correct-downscaling` |
| Chroma | `cscale=ewa_lanczos`, `cscale-antiring=1` |
| Policy | `scaler-resizes-only` |
| Light | `sigmoid-upscaling` |
| Dither | `temporal-dither`, `dither-depth=auto` |
| Range | `video-output-levels=full` |
| HDR | `hdr-compute-peak=yes`, `target-colorspace-hint=yes` |
| Deband | `deband=no`, tuned values behind `b` |
| Timing | `video-sync=audio`, `opengl-swapinterval=1` |
| Window | `autofit-larger=90%x90%`, `no-border` |

- `correct-downscaling` and `sigmoid-upscaling` filter in linear light on
  purpose; do not remove them to "sharpen" the image.
- `cscale` stays `ewa_lanczos`: `ewa_lanczossoft` only exists in `vo=gpu`.
- Debanding stays off by default (GPU cost, smears grain); `b` toggles it.
- No motion interpolation: `video-sync=audio` is the intended behaviour.
- The README table (`### How video is displayed`, `### Cómo se muestra el
  vídeo`) mirrors these rows. Update both when `mpv.conf` changes.

## Audio profiles

Four profiles on `1`–`4`, handled by `scripts/audio-norm.lua`. Playback starts
in **No Processing**; each key replaces the chain instead of stacking filters.
Bindings call named script bindings
(`audio_norm/no_processing|cinematic|balanced|night_mode`), so keys can be
remapped without touching the Lua.

| Key | Profile | `loudnorm` | LRA | TP | `alimiter` | Extra |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| `1` | No Processing | — | — | — | — | none |
| `2` | Cinematic | −23 LUFS | 18 | −1 | 0.8913 | none |
| `3` | Balanced | −18 LUFS | 15 | −2 | 0.7943 | none |
| `4` | Night Mode | −16 LUFS | 7 | −3 | 0.7079 | `acompressor` 4:1 at −18 dB |

- `linear=false` on every processed profile (single-pass dynamic mode).
- Night Mode compressor: threshold `0.125` (≈ −18 dBFS), ratio `4:1`, attack
  `20 ms`, release `250 ms`, knee `2.5`, unity makeup.
- `alimiter` runs with `level=0`; its limit is the sample-peak ceiling
  (`20·log10(limit)`), while `loudnorm`'s `TP` is the true-peak target.
- The chain is reasserted on `file-loaded`, and `watch-later-options-remove`
  drops `af`, `volume` and `mute` from resume files.

**Why these targets.** Cinematic keeps the EBU R128 reference and gentle
dynamics for quiet listening; Balanced is the −18 LUFS normalization most
material is mixed around; Night Mode pushes to −16 LUFS with compression so
dialogue stays intelligible at low volume. The ladder is 5 LU, then 2 LU. Do
not change these numbers silently: the user explicitly prefers them over the
earlier −22/−20/−18 experiment and wants deviations justified first.

Do not reintroduce `scripts/neutral-volume.lua`, `dynaudnorm`, or a policy that
pins `volume` to 100. `volume=100` is only the startup level.

## Volume and numpad

| Keys | Action |
| --- | --- |
| numpad `0`–`9` | set volume 0 %, 11.1 %, …, 88.9 %, 100 % |
| numpad `/` / `*` | volume −2 / +2 |
| numpad `+` / `-` | subtitle size ±2 (persisted) |
| `m`, `MUTE` | mute |

Every volume binding uses `no-osd ... ; script-binding uosc/flash-volume`.
Horizontal `9`/`0`, `/`, `*`, the plain wheel and the media volume keys stay
unbound; `Ctrl`+wheel is zoom. `volume-max=100` remains. uosc's volume slider
is enabled (`volume=right` in the local `uosc.conf`).

## Subtitles

- Merriweather Bold 700 from `fonts/`, loaded via `~~/fonts`; no installation.
- Amber `#FCBE11`, outline `#1F1F1F` at 1.5, size 40, spacing 0.5, shadow
  `#33000000` (ARGB, 20 % black) at 1 px. Styling is forced over every track, including ASS signs.
- `blend-subtitles=no` is required so subtitles can enter the letterbox bars;
  `sub-use-margins=yes` and `sub-ass-force-margins=yes` are already set.
  `sub-pos` runs 0–150; 100 is normal, ~100–106 reaches the bottom bar.
- Describe the bars as subtitle behaviour, never as a letterbox feature:
  subtitles follow the window, stay sharp, never stretch with the picture and
  adapt to any aspect ratio (21:9 or 4:3 alike).
- `scripts/subtitle-size.lua` writes every `sub-font-size` change to
  `subtitle-size.txt` (gitignored) and restores it on startup. Delete the file
  to reset to 40.

## Keybindings and closing

- `q`/`w`: subtitles up/down. `a`/`s`: subtitle delay. `b`: deband.
- `Ctrl`+wheel: `video-zoom` in/out with an OSD value; `Alt+Backspace` resets
  zoom, pan and alignment. `z`/`Shift+z` stay free.
- `Ctrl`+drag pans the zoomed image; right click opens the context menu; left
  click belongs to uosc.
- `F10` / `Shift+F10`: screenshot without / with subtitles. `PrintScreen` is
  not used.
- `C`: autocrop now; it also runs 10 s after playback starts
  (`script-opts-append=autocrop-auto_delay=10`). `Ctrl+d`: autodeint. Both stay.
- `Esc`: leaves fullscreen first, quits on the next press (no save).
  `Shift+Esc`: quit and save position. `q` does not quit. `Ctrl+c` force-quits.
- `←`/`→` seek ±5 s, `↑`/`↓` ±60 s, `[`/`]` speed, `Backspace` 1×; these flash
  uosc's indicators.
- Only `1`–`4` are horizontal number keys. Keep `r`, `t`, `e`, `x`, `z`,
  `Shift+z`, `v`, `Shift+q`, `5`–`8`, `9`, `0`, `/`, `*`, wheel up/down/left/
  right, `S`, `Ctrl+s`, `Alt+s`, `Ctrl+w`, `u`, `V`, `A`, `F`, `G`, `E`,
  `PrintScreen` and the volume media keys unbound.

## Docs style

- Concise and scannable: short sections, tables over prose, bold lead-ins.
  Keep the English README under about 18 KB and the Spanish mirror under about
  20 KB; Spanish runs longer for the same content, not because it may say more.
- At most a handful of emojis, only as section markers (audio, subtitles,
  installation, updating, uninstalling, design, privacy). No emoji in body text.
- No marketing tone and no repetition between the summary and the dedicated
  sections. Keep the existing anchors working.
- CHANGELOG: one entry per release, grouped by feature, in English.
- Screenshots live in `assets/`; the interface shot is `assets/interface.jpg`.

## Images

- The keyboard map is `assets/keys.png`, embedded under **Keybindings** in the
  README.
- It is generated deterministically by `assets/keys.ps1` (PowerShell +
  System.Drawing), not by an image model: exact labels, no gibberish. Run
  `powershell -ExecutionPolicy Bypass -File assets/keys.ps1` after changing
  keybindings.
- Style: SQUAD-like tactical HUD, charcoal background, faint grid, amber
  `#FCBE11` glow on active keys, condensed sans labels, 1600×900.
- The right side carries a mouse panel: wheel highlighted for
  `CTRL+WHEEL = ZOOM`, plus `ALT+BACKSPACE = RESET ZOOM`, `CTRL+DRAG = PAN`,
  `RIGHT CLICK = MENU` and `LEFT CLICK = UI`.
- Labels are English and describe the keybindings exactly. Modifier actions are
  written as combinations (`SHIFT+F10`, `CTRL+WHEEL`, `SHIFT+ESC`); never put a
  combo action on the bare modifier key alone. Spell out `BACKSPACE`; `BS` is
  only mpv's internal key name.
- The keyboard uses a 15-column ortholinear grid: `Tab`, `Caps` and `Shift`
  start on whole columns (`2U`, `2U`, `2U`/`3U`), so `Q`, `A` and `Z` share a
  column, and the bottom row uses whole units. The function row fills all 15
  columns (the dim `PRINT` and `SCROLL` keys have no bindings) and the numpad
  continues the same grid to the right, sharing the top edge. Do not
  reintroduce half-unit offsets or a staggered QWERTY silhouette.
- For any other text-heavy image, draw it instead of generating it: exact
  text matters more than style.
- The README banners — `banner.png`, `specimen.png`, `inside.png`,
  `audio.png`, `subtitles.png`, `installation.png`, `updating.png`,
  `uninstalling.png`, `credits.png`, `privacy.png` — come from
  `assets/banner.py` (Python + Pillow) using the bundled Fira Sans Condensed in
  `assets/fonts/` (SIL OFL), with the same palette, grid and HUD frame as the
  keyboard map. `--version` sets the chip on the two large images
  (`banner.png`, `specimen.png`); rerun `python3 assets/banner.py` after
  changing text or releasing. The audio strip lists the four profile names.
  The specimen is the only image in **Design**: it already carries the
  `DESIGN` / `AMBER, NOT WHITE` header, so do not add a strip there.
  Keep the canvases short so the page does not fill with images: the hero is
  1600×470, the specimen 1200×400 and the strips 1200×158, all at the same type
  sizes as before. Enlarge the type or shrink the canvas instead of adding
  width.
- `banner.png` and `specimen.png` carry the version chip. Both READMEs link
  them with `?v=<version>`; bump that query on every release so GitHub's image
  proxy fetches the new file instead of serving its cached copy. The strips
  have no chip and need no query.

## Privacy notice

- The README ends with **Privacy: uosc subtitle search**, and the section says
  only what was verified: OpenSubtitles receives the file name, the file hash
  when available, the requested languages and page, and the client IP;
  downloads send the subtitle id; the requests come from `ziggy`.
- No claim that it caused anything else, no accusations. The audit result is
  limited to the inspected files (`menus.lua`, `main.lua`, `subtitles.go`,
  `utils.go`, `http.go`) and the limitations and the opt-out are stated.
- Keep it short. Do not add the full Spanish draft back: it repeats the same
  facts and names analytics vendors that were not found.

## Security

`SECURITY.md` is the user-facing summary: trust model, provenance, installer
guarantees, fixes and limits. Keep it in step with the code.

- **Trust model.** An mpv config is executable: `scripts/*.lua` runs with user
  rights at startup. Do not add a script or keybinding that downloads and runs
  code, and do not tell users to run one.
- **Our scripts stay local.** `audio-norm`, `subtitle-size`, `esc-quit` and
  `oled-screensaver` use no network, no subprocesses and no `loadstring`. The
  only file they write is `subtitle-size.txt` (gitignored).
- **`thumbfast.lua` is the only subprocess caller.** It runs mpv from `PATH`
  (or `mpv_path`) to render thumbnails. Do not extend it.
- **Installers** download over HTTPS only, cap at 50 MB, verify the SHA-256 that
  GitHub publishes for the release, check the archive layout before deleting
  the old uosc, refuse a filesystem root, and only remove `scripts/uosc`,
  `fonts/uosc_*` and optionally `script-opts/uosc.conf`. Keep those properties.
- **Provenance.** `mpv.conf`, `input.conf`, the four scripts above and the
  installers are ours; `thumbfast.lua` is po5/thumbfast (MPL-2.0);
  `autocrop.lua`, `autodeint.lua` and `autoload.lua` are upstream mpv
  `TOOLS/lua` with hardening patches; uosc is installed from its release and
  never vendored.
- **Audit baseline (2026-11-18).** No malware or privilege escalation found in
  the reviewed files; four files were hardened: `subtitle-size` range check, nil
  guards in `autocrop` and `autodeint`, and the `oled-screensaver` fixes. If a
  change touches network, process execution, installers or persisted files,
  update `SECURITY.md` and re-check with
  `rg -n "os\.execute|io\.popen|loadstring|dofile|subprocess" scripts`
  (`Select-String -Path scripts\*.lua` on Windows).

## Git

- Conventional Commits: `feat:`, `fix:`, `docs:`, `chore:`, `release:`.
  Imperative subject, body explaining what and why, no emoji.
- Do not commit, tag or push unless the user asks. Report uncommitted changes.
- Keep `AGENTS.md` current when a preference changes.

## Testing checklist

- Startup: No Processing, empty `af`, volume 100, subtitle size 40.
- `1`–`4`: correct chain applied and replaced, no filter stacking.
- Numpad: `0`→0, `5`→55.56, `9`→100, `/`→−2, `*`→+2; `+`/`-` change size.
- Subtitle size restored after restart.
- Corrupt `subtitle-size.txt` (`0`, `-3`, `1e9`, text) is ignored and the size
  stays at 40; a valid number such as `64` is restored.
- Idle: paused and fullscreen for 60 s shows the black overlay; any input
  clears it.
- Zoom: `Ctrl`+wheel changes `video-zoom` and shows the value; `z`/`Shift+z`
  do nothing; `Alt+Backspace` resets.
- Defaults freed: `u`, `V`, `A`, `F`, `G`, `E`, `v` and horizontal wheel do
  nothing.
- Screenshots: `F10` has no subtitles; `Shift+F10` includes them; `PrintScreen`
  does nothing in mpv.
- Autocrop: with a letterboxed file, the crop happens about 10 s in and `C`
  applies or undoes it.
- Bars: with a letterboxed clip (21:9 on 16:9, or 4:3 on 16:9), `sub-pos` ≈105 places subtitles inside the bottom bar.
- Seeks: `←`/`→` move exactly 5 s on a file whose keyframes are 10 s apart (without `exact`, mpv would land 8 s away); `↑`/`↓` do 60 s.
- `Esc` in fullscreen leaves fullscreen, next press quits without saving;
  `Shift+Esc` writes `start=` only.

## File map

| Path | Purpose |
| --- | --- |
| `mpv.conf` | playback, scaling, subtitles, volume, resume |
| `input.conf` | bindings and freed keys |
| `scripts/audio-norm.lua` | four audio profiles |
| `scripts/subtitle-size.lua` | subtitle-size persistence (8–200, default 40) |
| `scripts/esc-quit.lua` | two-step Esc close |
| `scripts/oled-screensaver.lua` | black overlay after idle, paused and fullscreen |
| `scripts/autocrop.lua` | upstream mpv, 10 s auto crop and `C` |
| `scripts/autodeint.lua` | upstream mpv, `Ctrl+d` detection |
| `scripts/autoload.lua` | upstream mpv, queue the folder |
| `scripts/thumbfast.lua` | po5/thumbfast (MPL-2.0), timeline previews |
| `install-uosc.ps1` `install-uosc-ubuntu.sh` `install-uosc-cachyos.sh` `install-uosc-macos.sh` | uosc release installers |
| `uninstall-uosc.ps1` `uninstall-uosc.sh` | remove uosc, keep everything else |
| `assets/keys.ps1` | generator for the keyboard map |
| `assets/keys.png` | keyboard map used by the README |
| `assets/banner.py` | generator for the README banners |
| `assets/banner.png` | hero banner (carries the version chip) |
| `assets/specimen.png` | subtitle specimen and the only image in **Design** (carries the version chip) |
| `assets/inside.png` | strip for **What's inside** |
| `assets/audio.png` `subtitles.png` `installation.png` `updating.png` `uninstalling.png` `credits.png` `privacy.png` | section strips |
| `assets/fonts/` | Fira Sans Condensed used by the banner generator (OFL) |
| `README.md` | user-facing documentation (English) |
| `README.es.md` | the same documentation in Spanish |
| `SECURITY.md` | audit summary, provenance, installer guarantees, limits |
| `CHANGELOG.md` | release notes |
