# Security notes

What this repository runs, what it does not, and how to check it yourself.
Last reviewed: **2026-11-18**, against `1.3.0`.

## Trust model

An mpv config is executable code, not a data file. Every `scripts/*.lua` file
in the config directory runs with your user rights as soon as mpv starts, and
`input.conf` can bind keys to shell commands. Treat a config directory like a
program: only run one you trust, and read the diff before pulling.

This repository ships **no compiled binaries**. The only non-text files are
PNG/JPEG images and TTF fonts.

## Provenance

| File | Origin |
| --- | --- |
| `mpv.conf`, `input.conf`, `scripts/audio-norm.lua`, `subtitle-size.lua`, `esc-quit.lua`, `oled-screensaver.lua` | this repository |
| `install-uosc*.{ps1,sh}`, `uninstall-uosc.ps1` | this repository |
| `assets/banner.py`, `assets/keys.ps1` | this repository (documentation images) |
| `scripts/thumbfast.lua` | [po5/thumbfast](https://github.com/po5/thumbfast), MPL-2.0 |
| `scripts/autocrop.lua`, `autodeint.lua`, `autoload.lua` | upstream mpv `TOOLS/lua`, with local patches |
| `fonts/Merriweather-Bold.ttf` | Merriweather, SIL OFL (`Merriweather-OFL.txt`) |
| `assets/wiz-ambilight.png` | cropped screenshot from `mfascioli/wiz-ambilight`, MIT |
| `assets/banner-fonts/*.ttf` | Fira Sans Condensed, SIL OFL (`assets/banner-fonts/OFL.txt`); used only by `assets/banner.py` |
| `scripts/uosc/` | not shipped; installed from the official uosc release |

Local patches to the upstream scripts are limited to hardening: a nil guard in
`autocrop.lua`, metadata checks in `autodeint.lua`, and the fixes below. They do
not add network access or process execution.

## Network and process use

- **Our scripts make no network requests.** `audio-norm`, `subtitle-size`,
  `esc-quit` and `oled-screensaver` do not open sockets or spawn processes.
  `subtitle-size` only writes `subtitle-size.txt` inside the config directory.
- **`thumbfast.lua` is the only script that spawns processes.** It runs the mpv
  binary from `PATH` to render timeline thumbnails, and on Linux uses a pipe
  and a temporary path under `/tmp`. If `mpv_path` is not set it searches
  `PATH`; set it explicitly in `script-opts/thumbfast.conf`.
- **uosc's subtitle search is the only third-party request**, and it is
  documented in the README's privacy section: OpenSubtitles receives the file
  name, hash, requested languages, page and your IP.
- **The installers download only over HTTPS** from
  `github.com/tomasklaen/uosc` and `api.github.com`, cap the download at 50 MB,
  check SHA-256 before replacing anything, and refuse a config directory that
  is a filesystem root.

## What was fixed in this pass

These are correctness and robustness bugs, not malware or privilege
escalation. All four were reachable only through local files or local state.

| File | Problem | Fix |
| --- | --- | --- |
| `scripts/subtitle-size.lua` | Restored any number from `subtitle-size.txt`, including `0`, negatives or huge values | Only accepts 8–200; anything else is ignored and `sub-font-size=40` applies |
| `scripts/autocrop.lua` | `hwdec-current` can be nil, and `:find` on nil aborts detection | Nil guard; detection continues without touching hwdec |
| `scripts/autodeint.lua` | Missing `vf-metadata` caused arithmetic on nil and a false "interlaced" verdict | Missing or incomplete metadata aborts detection and leaves the picture untouched |
| `scripts/oled-screensaver.lua` | Global `ass` leak, malformed `{\bord0}` tag, fractional alpha and colour values passed to `%02x` (LuaJIT truncates, other runtimes need not), `or` instead of `and` in mouse detection | Local variable, valid tag, explicit `math.floor`, correct comparison; the colour option is validated as six hex digits |

## Limits of this review

- It is a **static review** of the shipped text files, not a sandbox run of
  uosc or `ziggy`. Third-party code was read at source level, not rebuilt.
- The SHA-256 the installers check comes from **the same GitHub release** the
  archive comes from. It proves the download is intact, not that the release is
  trustworthy; TLS to GitHub is the authenticity anchor.
- `powershell -ExecutionPolicy Bypass` is required because the scripts are
  unsigned local files. It is not a privilege escalation, but it is a common
  false-positive trigger in sandbox and AV heuristics.
- The Windows installer relies on `Expand-Archive`; on PowerShell 5.1 the
  script does not validate archive entry paths itself. The archive comes from
  the checked release and is extracted into a fresh temporary directory.
- The Linux installers replace `scripts/uosc` by removing it and copying the
  new tree. An interruption mid-way leaves uosc missing until it is reinstalled;
  it does not touch your config, resume files or fonts.
- On Linux, `thumbfast.lua` builds an `sh -c` pipeline to reach its socket. The
  socket name comes from `script-opts/thumbfast.conf`, which is local config,
  not media metadata; anyone who can edit it can already run code through mpv.
- mpv itself, the GPU drivers and the operating system are outside this
  review.

## Check it yourself

```console
git log --oneline
git diff <last-tag>..HEAD -- scripts input.conf mpv.conf
```

Look for process or network primitives in the Lua:

```console
rg -n "os\.execute|io\.popen|loadstring|dofile|subprocess|require" scripts
```

On Windows without ripgrep, use
`Select-String -Path scripts\*.lua -Pattern 'os\.execute|io\.popen|loadstring|dofile|subprocess|require'`.

Only `thumbfast.lua` should show process calls; `require` of `mp.*` modules is
normal. Compare the bundled thumbfast with upstream:

```console
curl -L https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua -o thumbfast.upstream.lua
sha256sum scripts/thumbfast.lua thumbfast.upstream.lua
```

On Windows, use `Get-FileHash -Algorithm SHA256`. A difference is not
automatically malicious, but it should be explainable.

Verify the installers instead of reading them: they print the release they
fetch and the checksum they compare. `-NoVerify` / `--no-verify` exists for
offline debugging and should not be used on a machine you care about.
