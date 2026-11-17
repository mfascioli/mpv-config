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

## Audio profiles

Four profiles on `1`–`4`, handled by `scripts/audio-norm.lua`. Playback starts
in **Off**; each key replaces the chain instead of stacking filters. Bindings
call named script bindings (`audio_norm/off|soft|balanced|night`), so keys can
be remapped without touching the Lua.

| Key | Profile | `loudnorm` | LRA | TP | `alimiter` | Extra |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| `1` | Off | — | — | — | — | none |
| `2` | Soft | −23 LUFS | 18 | −1 | 0.8913 | none |
| `3` | Balanced | −18 LUFS | 15 | −2 | 0.7943 | none |
| `4` | Night | −16 LUFS | 7 | −3 | 0.7079 | `acompressor` 4:1 at −18 dB |

- `linear=false` on every processed profile (single-pass dynamic mode).
- Night compressor: threshold `0.125` (≈ −18 dBFS), ratio `4:1`, attack `20 ms`,
  release `250 ms`, knee `2.5`, unity makeup.
- `alimiter` runs with `level=0`; its limit is the sample-peak ceiling
  (`20·log10(limit)`), while `loudnorm`'s `TP` is the true-peak target.
- The chain is reasserted on `file-loaded`, and `watch-later-options-remove`
  drops `af`, `volume` and `mute` from resume files.

**Why these targets.** Soft keeps the EBU R128 reference and gentle dynamics
for quiet listening; Balanced is the −18 LUFS normalization most material is
mixed around; Night pushes to −16 LUFS with compression so dialogue stays
intelligible at low volume. The ladder is 5 LU, then 2 LU. Do not change these
numbers silently: the user explicitly prefers them over the earlier
−22/−20/−18 experiment and wants deviations justified first.

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
Horizontal `9`/`0`, `/`, `*`, mouse wheel and the media volume keys stay
unbound. `volume-max=100` remains. uosc's volume slider is enabled
(`volume=right` in the local `uosc.conf`).

## Subtitles

- Merriweather Bold 700 from `fonts/`, loaded via `~~/fonts`; no installation.
- Amber `#FCBE11`, outline `#1F1F1F` at 1.5, size 40, spacing 0.5, shadow
  `#33000000` at 1 px. Styling is forced over every track, including ASS signs.
- `blend-subtitles=no` is required so subtitles can enter the letterbox bars;
  `sub-use-margins=yes` and `sub-ass-force-margins=yes` are already set.
  `sub-pos` runs 0–150; 100 is normal, ~100–106 reaches the bottom bar.
- `scripts/subtitle-size.lua` writes every `sub-font-size` change to
  `subtitle-size.txt` (gitignored) and restores it on startup. Delete the file
  to reset to 40.

## Keys and closing

- `q`/`w`: subtitles up/down. `a`/`s`: subtitle delay. `z`/`Shift+z`: zoom.
  `b`/`v`: deband / output levels. `C`/`Ctrl+d`: autocrop / autodeint.
- `PrintScreen` / `Ctrl+PrintScreen`: screenshot without / with subtitles;
  `F10` / `Ctrl+F10` are fallbacks.
- `Esc`: leaves fullscreen first, quits on the next press (no save).
  `Shift+Esc`: quit and save position. `q` does not quit. `Ctrl+c` force-quits.
- `←`/`→` seek ±5 s, `↑`/`↓` ±60 s, `[`/`]` speed, `Backspace` 1×; these flash
  uosc's indicators.
- Only `1`–`4` are horizontal number keys. Keep `r`, `t`, `e`, `x`, `Shift+q`,
  `5`–`8`, `9`, `0`, `/`, `*`, wheel, `S`, `Ctrl+s`, `Alt+s`, `Ctrl+w` and the
  volume media keys unbound.

## Docs style

- Concise and scannable: short sections, tables over prose, bold lead-ins.
  The README should stay around 12–13 KB, not 20.
- At most a handful of emojis, only as section markers (audio, subtitles,
  installation, updating, uninstalling, design). No emoji in body text.
- No marketing tone and no repetition between the summary and the dedicated
  sections. Keep the existing anchors working.
- CHANGELOG: one entry per release, grouped by feature, in English.
- Screenshots live in `assets/`; the interface shot is `assets/interface.jpg`.

## Images

- The keyboard map is `assets/keys.png`, embedded under **Keys** in the README.
- It is generated deterministically by `assets/keys.ps1` (PowerShell +
  System.Drawing), not by an image model: exact labels, no gibberish. Run
  `powershell -ExecutionPolicy Bypass -File assets/keys.ps1` after changing
  bindings.
- Style: SQUAD-like tactical HUD, charcoal background, faint grid, amber
  `#FCBE11` glow on active keys, condensed sans labels, 1920×1080.
- Labels are English and describe the bindings exactly. Modifier actions are
  written as combinations (`SHIFT+Z`, `CTRL+PRINT`, `SHIFT+ESC`); never put a
  combo action on the bare modifier key alone.
- For any other text-heavy image, draw it instead of generating it: exact
  text matters more than style.

## Git

- Conventional Commits: `feat:`, `fix:`, `docs:`, `chore:`, `release:`.
  Imperative subject, body explaining what and why, no emoji.
- Do not commit, tag or push unless the user asks. Report uncommitted changes.
- Keep `AGENTS.md` current when a preference changes.

## Testing checklist

- Startup: Off, empty `af`, volume 100, subtitle size 40.
- `1`–`4`: correct chain applied and replaced, no filter stacking.
- Numpad: `0`→0, `5`→55.56, `9`→100, `/`→−2, `*`→+2; `+`/`-` change size.
- Subtitle size restored after restart.
- Bars: with a 21:9 clip, `sub-pos` ≈105 places subtitles inside the bottom bar.
- Screenshots: video-only has no subtitles; the with-subtitles mode includes them.
- `Esc` in fullscreen leaves fullscreen, next press quits without saving;
  `Shift+Esc` writes `start=` only.

## File map

| Path | Purpose |
| --- | --- |
| `mpv.conf` | playback, scaling, subtitles, volume, resume |
| `input.conf` | bindings and freed keys |
| `scripts/audio-norm.lua` | four audio profiles |
| `scripts/subtitle-size.lua` | subtitle-size persistence |
| `scripts/esc-quit.lua` | two-step Esc close |
| `assets/keys.ps1` | generator for the keyboard map |
| `assets/keys.png` | keyboard map used by the README |
| `README.md` | user-facing documentation |
| `CHANGELOG.md` | release notes |
