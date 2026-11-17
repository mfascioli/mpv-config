#!/usr/bin/env python3
"""Generate the HUD-style banners used by the README.

Same visual language as assets/keys.ps1: charcoal gradient, faint grid, amber
#FCBE11 glow, corner brackets and condensed sans type. Everything is drawn
deterministically with Pillow and the bundled Fira Sans Condensed (SIL OFL),
so the text is exact and the output is reproducible.

    python3 assets/banner.py            # writes banner.png and design.png next to it
    python3 assets/banner.py --out DIR  # write somewhere else

Requires Pillow and numpy.
"""

import argparse
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
FONT_DIR = HERE / "fonts"

AMBER = (252, 190, 17)
AMBER_DIM = (201, 154, 38)
WARM_WHITE = (242, 232, 206)
GREY = (107, 107, 114)
BG_TOP = (11, 11, 12)
BG_BOTTOM = (22, 19, 16)

FONT_FILES = {
    "regular": "FiraSansCondensed-Regular.ttf",
    "semibold": "FiraSansCondensed-SemiBold.ttf",
    "heavy": "FiraSansCondensed-Heavy.ttf",
}


def font(weight, size):
    return ImageFont.truetype(str(FONT_DIR / FONT_FILES[weight]), size)


def vertical_gradient(w, h, top, bottom):
    ramp = np.linspace(0.0, 1.0, h, dtype=np.float32)[:, None, None]
    rows = np.array(top, dtype=np.float32)[None, None, :] * (1 - ramp) + np.array(
        bottom, dtype=np.float32
    )[None, None, :] * ramp
    return Image.fromarray(np.repeat(rows.astype(np.uint8), w, axis=1), "RGB").convert("RGBA")


def add_glow(img, cx, cy, rx, ry, strength):
    w, h = img.size
    yy, xx = np.mgrid[0:h, 0:w]
    dist = np.sqrt(((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2)
    alpha = (np.clip(1.0 - dist, 0.0, 1.0) ** 2 * strength).astype(np.uint8)
    layer = np.zeros((h, w, 4), dtype=np.uint8)
    layer[..., 0:3] = AMBER
    layer[..., 3] = alpha
    return Image.alpha_composite(img, Image.fromarray(layer, "RGBA"))


def add_grid(img, step=64, alpha=9):
    w, h = img.size
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for x in range(0, w, step):
        d.line([(x, 0), (x, h)], fill=(255, 216, 107, alpha))
    for y in range(0, h, step):
        d.line([(0, y), (w, y)], fill=(255, 216, 107, alpha))
    return Image.alpha_composite(img, layer)


def add_frame(img, inset=26, arm=104, width=4):
    w, h = img.size
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.rectangle([inset, inset, w - inset - 1, h - inset - 1], outline=(252, 190, 17, 40), width=1)
    for x, y, dx, dy in (
        (inset, inset, 1, 1),
        (w - inset - 1, inset, -1, 1),
        (inset, h - inset - 1, 1, -1),
        (w - inset - 1, h - inset - 1, -1, -1),
    ):
        d.line([(x, y), (x + dx * arm, y)], fill=(252, 190, 17, 210), width=width)
        d.line([(x, y), (x, y + dy * arm)], fill=(252, 190, 17, 210), width=width)
    return Image.alpha_composite(img, layer)


def canvas(w, h, glow, inset=26, arm=104):
    img = vertical_gradient(w, h, BG_TOP, BG_BOTTOM)
    img = add_glow(img, *glow)
    img = add_grid(img)
    return add_frame(img, inset=inset, arm=arm)


def text_width(d, text, f, tracking=0):
    if not text:
        return 0
    return sum(d.textlength(c, font=f) for c in text) + tracking * (len(text) - 1)


def draw_tracked(d, xy, text, f, fill, tracking=0):
    x, y = xy
    for c in text:
        d.text((x, y), c, font=f, fill=fill)
        x += d.textlength(c, font=f) + tracking


def draw_right(d, x_right, y, text, f, fill, tracking=0):
    draw_tracked(d, (x_right - text_width(d, text, f, tracking), y), text, f, fill, tracking)


def hero(path, version):
    w, h = 1920, 600
    img = canvas(w, h, (620, 300, 760, 330, 24))
    ov = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    o = ImageDraw.Draw(ov)

    o.line([(140, 376), (1780, 376)], fill=(252, 190, 17, 60), width=1)

    chips = ("SDR \u00b7 HDR", "GPU-NEXT", "ADAPTIVE SUBTITLES", "FOUR PROFILES")
    chip_font = font("semibold", 18)
    boxes = []
    x = 140
    for label in chips:
        tw = text_width(o, label, chip_font, 3)
        box = [x, 404, x + tw + 40, 448]
        o.rounded_rectangle(box, radius=5, fill=(252, 190, 17, 14), outline=(252, 190, 17, 85), width=1)
        boxes.append((box, label))
        x = box[2] + 16

    rows = (
        ("SCALING", "EWA LANCZOS"),
        ("SUBTITLES", "MERRIWEATHER \u00b7 AMBER"),
        ("AUDIO", "FOUR PROFILES"),
        ("INTERFACE", "uosc \u00b7 OPTIONAL"),
    )
    y = 236
    for _label, _value in rows:
        o.line([(1210, y + 40), (1780, y + 40)], fill=(255, 216, 107, 26), width=1)
        y += 52

    img = Image.alpha_composite(img, ov)
    d = ImageDraw.Draw(img)

    draw_tracked(d, (140, 92), "PERSONAL MPV CONFIG", font("semibold", 20), AMBER_DIM, 6)
    d.text((136, 124), "MPV CONFIG", font=font("heavy", 132), fill=AMBER)
    d.text((144, 302), "Clean scaling \u00b7 Amber subtitles \u00b7 Four audio profiles",
           font=font("regular", 30), fill=WARM_WHITE)

    for box, label in boxes:
        draw_tracked(d, (box[0] + 20, 414), label, chip_font, AMBER, 3)

    y = 236
    for label, value in rows:
        draw_tracked(d, (1210, y + 4), label, font("semibold", 15), GREY, 4)
        draw_right(d, 1780, y, value, font("semibold", 22), WARM_WHITE, 1)
        y += 52

    d.text((140, 516), "mpv 0.40+  \u00b7  gpu-next  \u00b7  Windows \u00b7 Linux \u00b7 macOS",
           font=font("regular", 18), fill=GREY)
    draw_right(d, 1780, 62, version, font("regular", 18), GREY)

    img.convert("RGB").save(path, optimize=True)


def design(path, version):
    w, h = 1920, 480
    img = canvas(w, h, (760, 250, 700, 300, 18))
    ov = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    o = ImageDraw.Draw(ov)

    o.line([(140, 216), (1780, 216)], fill=(252, 190, 17, 60), width=1)

    swatches = (
        ("FILL", "#FCBE11", (252, 190, 17, 255)),
        ("OUTLINE", "#1F1F1F \u00b7 1.5", (31, 31, 31, 255)),
        ("SHADOW", "#33000000 \u00b7 1 px", (0, 0, 0, 51)),
        ("TYPE", "SIZE 40 \u00b7 SPACING 0.5", None),
    )
    x = 140
    for label, value, color in swatches:
        if color is not None:
            o.rounded_rectangle([x, 356, x + 44, 400], radius=3, fill=color,
                                outline=(255, 216, 107, 80), width=1)
        x += 300

    img = Image.alpha_composite(img, ov)
    d = ImageDraw.Draw(img)

    draw_tracked(d, (140, 76), "DESIGN", font("semibold", 20), AMBER_DIM, 6)
    d.text((136, 108), "AMBER, NOT WHITE", font=font("heavy", 72), fill=AMBER)

    merri = ImageFont.truetype(str(HERE.parent / "fonts" / "Merriweather-Bold.ttf"), 56)
    d.text((140, 244), "The city never looked this quiet.",
           font=merri, fill=AMBER, stroke_width=3, stroke_fill=(31, 31, 31))

    x = 140
    for label, value, _color in swatches:
        draw_tracked(d, (x, 412), label, font("semibold", 15), GREY, 4)
        d.text((x, 432), value, font=font("semibold", 20), fill=WARM_WHITE)
        x += 300

    draw_tracked(d, (1442, 300), "MERRIWEATHER", font("semibold", 32), WARM_WHITE, 1)
    d.text((1440, 336), "BOLD 700", font=font("heavy", 46), fill=AMBER)
    d.text((1442, 394), "loaded from ~~/fonts", font=font("regular", 18), fill=GREY)
    draw_right(d, 1780, 62, version, font("regular", 18), GREY)

    img.convert("RGB").save(path, optimize=True)


def strip(path, kicker, title, detail):
    w, h = 1920, 170
    img = canvas(w, h, (560, 85, 620, 180, 16), inset=18, arm=56)
    ov = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    o = ImageDraw.Draw(ov)
    o.line([(1300, 46), (1300, 124)], fill=(252, 190, 17, 45), width=1)
    img = Image.alpha_composite(img, ov)
    d = ImageDraw.Draw(img)

    draw_tracked(d, (64, 42), kicker, font("semibold", 16), AMBER_DIM, 5)
    d.text((60, 62), title, font=font("heavy", 48), fill=AMBER)
    draw_right(d, 1850, 74, detail, font("semibold", 21), WARM_WHITE, 1)

    img.convert("RGB").save(path, optimize=True)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--out", type=Path, default=HERE)
    p.add_argument("--version", default="v1.2.4")
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=True)
    hero(a.out / "banner.png", a.version)
    design(a.out / "design.png", a.version)
    strip(a.out / "audio.png", "AUDIO", "FOUR PROFILES", "OFF \u00b7 SOFT \u00b7 BALANCED \u00b7 NIGHT")
    strip(a.out / "subtitles.png", "SUBTITLES", "ADAPTIVE PLACEMENT", "AMBER \u00b7 SIZE \u00b7 DELAY")
    strip(a.out / "installation.png", "INSTALL", "ONE CLONE", "mpv 0.40+ \u00b7 uosc optional")
    for name in ("banner.png", "design.png", "audio.png", "subtitles.png", "installation.png"):
        print(f"wrote {a.out / name}")


if __name__ == "__main__":
    main()
