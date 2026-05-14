"""Generate the projection-locked court/environment background.

The output is a single 979x1606 bitmap that matches CourtProjection's image
space. Runtime code cover-fits this image with the same transform used for
court/player/ball projection, so the painted court never drifts from gameplay.
"""

from __future__ import annotations

import json
import math
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "images" / "environment" / "classic" / "projection_environment_v1.png"
MANIFEST = ROOT.parent / "docs" / "art" / "visual-overhaul" / "projection-environment-v1-manifest.json"

IMAGE_WIDTH = 979
IMAGE_HEIGHT = 1606

COURT_WIDTH = 220.0
COURT_LENGTH = 480.0
COURT_NET_Y = 240.0
COURT_LEFT = 0.0
COURT_RIGHT = COURT_WIDTH
COURT_TOP = 0.0
COURT_BOTTOM = COURT_LENGTH
FEET_TO_UNITS = COURT_LENGTH / 44.0
KITCHEN_DEPTH = 7.0 * FEET_TO_UNITS
OPPONENT_KITCHEN_TOP_Y = COURT_NET_Y - KITCHEN_DEPTH
PLAYER_KITCHEN_BOTTOM_Y = COURT_NET_Y + KITCHEN_DEPTH

PAINTED_FAR_Y = 430.0
PAINTED_NET_Y = 638.0
PAINTED_NEAR_Y = 1180.0
PAINTED_FAR_LEFT_X = 228.0
PAINTED_FAR_RIGHT_X = 751.0
PAINTED_NEAR_LEFT_X = 112.0
PAINTED_NEAR_RIGHT_X = 867.0
PERSPECTIVE_EXPONENT = 1.85


def rgb(hex_color: str) -> tuple[int, int, int]:
    value = hex_color.lstrip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))


PALETTE = {
    "ground_dark": rgb("#304A34"),
    "ground": rgb("#4F6241"),
    "ground_warm": rgb("#5B6C48"),
    "apron": rgb("#697257"),
    "apron_dark": rgb("#3B4638"),
    "court": rgb("#2B76AA"),
    "court_light": rgb("#3894C9"),
    "court_dark": rgb("#225E90"),
    "kitchen": rgb("#4EAAC6"),
    "line": rgb("#F4F7E8"),
    "ink": rgb("#10151B"),
    "navy": rgb("#102946"),
    "red": rgb("#C24A32"),
    "gold": rgb("#E3C66A"),
    "foliage_back": rgb("#0C1B12"),
    "foliage_dark": rgb("#162819"),
    "foliage_mid": rgb("#284523"),
    "foliage_light": rgb("#486326"),
    "wood_dark": rgb("#3B2D21"),
    "wood": rgb("#82522E"),
    "lamp": rgb("#F4E4A8"),
    "fence": rgb("#1A2D35"),
    "mesh": rgb("#263B45"),
    "stone": rgb("#7D856C"),
    "stone_dark": rgb("#4D5746"),
}


def depth_t(court_y: float) -> float:
    t = max(0.0, min(1.0, court_y / COURT_LENGTH))
    return math.pow(t, PERSPECTIVE_EXPONENT)


def width_at_y(court_y: float) -> float:
    t = depth_t(court_y)
    far_width = PAINTED_FAR_RIGHT_X - PAINTED_FAR_LEFT_X
    near_width = PAINTED_NEAR_RIGHT_X - PAINTED_NEAR_LEFT_X
    return far_width + t * (near_width - far_width)


def image_y(court_y: float) -> float:
    t = depth_t(court_y)
    return PAINTED_FAR_Y + t * (PAINTED_NEAR_Y - PAINTED_FAR_Y)


def court_to_image(court_x: float, court_y: float) -> tuple[float, float]:
    center_x = (PAINTED_FAR_LEFT_X + PAINTED_FAR_RIGHT_X) / 2.0
    tx = (court_x - COURT_WIDTH / 2.0) / COURT_WIDTH
    return center_x + tx * width_at_y(court_y), image_y(court_y)


def court_polygon(
    left: float = COURT_LEFT,
    top: float = COURT_TOP,
    right: float = COURT_RIGHT,
    bottom: float = COURT_BOTTOM,
) -> list[tuple[float, float]]:
    return [
        court_to_image(left, top),
        court_to_image(right, top),
        court_to_image(right, bottom),
        court_to_image(left, bottom),
    ]


def draw_gradient(draw: ImageDraw.ImageDraw) -> None:
    for y in range(IMAGE_HEIGHT):
        t = y / (IMAGE_HEIGHT - 1)
        if t < 0.58:
            local = t / 0.58
            a, b = PALETTE["ground_dark"], PALETTE["ground"]
        else:
            local = (t - 0.58) / 0.42
            a, b = PALETTE["ground"], PALETTE["ground_warm"]
        color = tuple(round(a[i] * (1 - local) + b[i] * local) for i in range(3))
        draw.line([(0, y), (IMAGE_WIDTH, y)], fill=color)


def draw_masked_noise(
    image: Image.Image,
    mask: Image.Image,
    color: tuple[int, int, int],
    *,
    count: int,
    alpha: int,
    size_range: tuple[int, int],
    seed: int,
) -> None:
    rng = random.Random(seed)
    layer = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer, "RGBA")
    for _ in range(count):
        x = rng.randrange(0, IMAGE_WIDTH)
        y = rng.randrange(0, IMAGE_HEIGHT)
        if mask.getpixel((x, y)) == 0:
            continue
        size = rng.randrange(size_range[0], size_range[1] + 1)
        draw.rectangle([x, y, x + size, y + size], fill=(*color, alpha))
    blend_layer(image, layer)


def draw_ground_texture(image: Image.Image) -> None:
    rng = random.Random(1312)
    draw = ImageDraw.Draw(image, "RGBA")
    for _ in range(1300):
        x = rng.randrange(-20, IMAGE_WIDTH + 20)
        y = rng.randrange(0, IMAGE_HEIGHT)
        w = rng.randrange(2, 9)
        h = rng.randrange(1, 4)
        color = PALETTE["ground_dark"] if rng.random() < 0.55 else PALETTE["ground_warm"]
        draw.rectangle([x, y, x + w, y + h], fill=(*color, rng.randrange(18, 46)))
    for center, radius in [
        ((80, 155), 112),
        ((920, 170), 132),
        ((18, 680), 86),
        ((945, 724), 90),
        ((105, 1456), 132),
        ((882, 1428), 126),
    ]:
        draw_foliage_cluster(draw, center, radius, alpha=96)


def draw_foliage_cluster(
    draw: ImageDraw.ImageDraw,
    center: tuple[float, float],
    radius: float,
    *,
    alpha: int = 255,
) -> None:
    cx, cy = center
    blobs = [
        (0.00, 0.00, 1.00, "foliage_dark"),
        (0.52, 0.08, 0.72, "foliage_mid"),
        (-0.36, 0.22, 0.64, "foliage_mid"),
        (0.12, -0.34, 0.54, "foliage_light"),
        (-0.18, -0.24, 0.44, "foliage_light"),
    ]
    for ox, oy, scale, key in blobs:
        r = radius * scale
        draw.ellipse(
            [cx + ox * radius - r, cy + oy * radius - r, cx + ox * radius + r, cy + oy * radius + r],
            fill=(*PALETTE[key], alpha),
        )


def draw_far_environment(image: Image.Image) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rectangle([0, 0, IMAGE_WIDTH, 330], fill=(*PALETTE["foliage_back"], 215))

    for i in range(-1, 12):
        x = i * 98 + (28 if i % 2 == 0 else -12)
        radius = 78 + (i % 4) * 14
        trunk_x = x + radius * 0.08
        draw.rectangle(
            [trunk_x - 7, 145, trunk_x + 8, 340],
            fill=(*PALETTE["wood_dark"], 230),
        )
        draw_foliage_cluster(draw, (x, 122 + (i % 3) * 18), radius, alpha=230)

    draw.rectangle([0, 282, IMAGE_WIDTH, 430], fill=(*PALETTE["apron_dark"], 180))
    draw.rectangle([0, 396, IMAGE_WIDTH, 430], fill=(*PALETTE["stone"], 225))
    for x in range(-20, IMAGE_WIDTH, 86):
        draw.line([(x, 398), (x + 30, 430)], fill=(*PALETTE["stone_dark"], 110), width=2)

    fence_top, fence_bottom = 250, 397
    draw.rectangle([0, fence_top, IMAGE_WIDTH, fence_bottom], fill=(12, 22, 24, 96))
    for y in [fence_top + 8, 315, fence_bottom - 8]:
        draw.line([(0, y), (IMAGE_WIDTH, y)], fill=(*PALETTE["fence"], 220), width=5)
    for x in range(18, IMAGE_WIDTH, 70):
        draw.rectangle([x - 4, fence_top, x + 4, fence_bottom], fill=(*PALETTE["fence"], 230))
    for x in range(-120, IMAGE_WIDTH + 120, 34):
        draw.line([(x, fence_bottom), (x + 136, fence_top)], fill=(*PALETTE["mesh"], 96), width=2)
        draw.line([(x, fence_top), (x + 136, fence_bottom)], fill=(*PALETTE["mesh"], 78), width=2)

    draw_banner(draw, (327, 252, 653, 324), "DINK", "RIVALS")
    draw_sign(draw, (692, 270, 846, 326), "PICKLEBALL", "PARK")
    draw_lamp(draw, 884, 222, 186, scale=0.92)
    draw_lamp(draw, 95, 232, 170, scale=0.78)


def draw_banner(
    draw: ImageDraw.ImageDraw,
    rect: tuple[int, int, int, int],
    top_text: str,
    bottom_text: str,
) -> None:
    x0, y0, x1, y1 = rect
    shadow = 8
    draw.rectangle([x0 + shadow, y0 + shadow, x1 + shadow, y1 + shadow], fill=(0, 0, 0, 86))
    draw.rectangle(rect, fill=(*PALETTE["navy"], 245), outline=(*PALETTE["ink"], 255), width=5)
    draw.rectangle([x0 + 8, y0 + 8, x1 - 8, y1 - 8], outline=(*PALETTE["line"], 118), width=2)
    font_big = load_font(42)
    font_small = load_font(34)
    text_outline(draw, (x0 + 36, y0 + 6), top_text, font_big, PALETTE["line"], PALETTE["ink"], 3)
    text_outline(draw, (x0 + 42, y0 + 36), bottom_text, font_small, PALETTE["red"], PALETTE["ink"], 3)


def draw_sign(
    draw: ImageDraw.ImageDraw,
    rect: tuple[int, int, int, int],
    line_one: str,
    line_two: str,
) -> None:
    x0, y0, x1, y1 = rect
    draw.rectangle([x0 + 5, y0 + 6, x1 + 5, y1 + 6], fill=(0, 0, 0, 72))
    draw.rectangle(rect, fill=(25, 54, 40, 238), outline=(*PALETTE["gold"], 230), width=3)
    font = load_font(21)
    text_outline(draw, (x0 + 18, y0 + 12), line_one, font, PALETTE["line"], PALETTE["ink"], 2)
    text_outline(draw, (x0 + 30, y0 + 38), line_two, font, PALETTE["line"], PALETTE["ink"], 2)


def draw_lamp(draw: ImageDraw.ImageDraw, x: float, y: float, height: float, *, scale: float) -> None:
    pole_w = max(4, int(7 * scale))
    draw.rectangle([x - pole_w / 2, y, x + pole_w / 2, y + height], fill=(*PALETTE["ink"], 230))
    draw.rectangle([x - 24 * scale, y - 26 * scale, x + 24 * scale, y + 20 * scale], fill=(*PALETTE["ink"], 230))
    draw.rectangle([x - 14 * scale, y - 18 * scale, x + 14 * scale, y + 12 * scale], fill=(*PALETTE["lamp"], 190))
    draw.rectangle([x - 9 * scale, y + height, x + 9 * scale, y + height + 8 * scale], fill=(*PALETTE["ink"], 230))


def draw_apron_and_court(image: Image.Image) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    apron = [
        (PAINTED_FAR_LEFT_X - 118, PAINTED_FAR_Y - 94),
        (PAINTED_FAR_RIGHT_X + 118, PAINTED_FAR_Y - 94),
        (PAINTED_NEAR_RIGHT_X + 105, PAINTED_NEAR_Y + 112),
        (PAINTED_NEAR_LEFT_X - 105, PAINTED_NEAR_Y + 112),
    ]
    apron_shadow = [(x + 10, y + 18) for x, y in apron]
    draw.polygon(apron_shadow, fill=(2, 10, 12, 70))
    draw.polygon(apron, fill=(*PALETTE["apron"], 255))

    draw_apron_grid(draw)
    draw_court_shadow(draw)

    court = court_polygon()
    draw.polygon(court, fill=(*PALETTE["court_dark"], 255))
    inset = court_polygon(4, 7, COURT_WIDTH - 4, COURT_LENGTH - 7)
    draw.polygon(inset, fill=(*PALETTE["court"], 255))

    draw_zone_tint(draw, COURT_TOP, OPPONENT_KITCHEN_TOP_Y, PALETTE["court_dark"], 64)
    draw_zone_tint(draw, OPPONENT_KITCHEN_TOP_Y, COURT_NET_Y, PALETTE["kitchen"], 58)
    draw_zone_tint(draw, COURT_NET_Y, PLAYER_KITCHEN_BOTTOM_Y, PALETTE["kitchen"], 52)
    draw_zone_tint(draw, PLAYER_KITCHEN_BOTTOM_Y, COURT_BOTTOM, PALETTE["court_light"], 40)

    court_mask = Image.new("L", image.size, 0)
    mask_draw = ImageDraw.Draw(court_mask)
    mask_draw.polygon(court, fill=255)
    draw_masked_noise(image, court_mask, PALETTE["court_light"], count=5400, alpha=22, size_range=(1, 3), seed=2201)
    draw_masked_noise(image, court_mask, PALETTE["court_dark"], count=3800, alpha=26, size_range=(1, 4), seed=2202)
    draw_scuffs(image, court_mask)
    draw_net_shadow(draw)


def draw_apron_grid(draw: ImageDraw.ImageDraw) -> None:
    for y in [350, 394, 450, 515, 590, 678, 782, 902, 1038, 1192, 1362]:
        left = lerp(PAINTED_FAR_LEFT_X - 108, PAINTED_NEAR_LEFT_X - 100, min(1, max(0, (y - 336) / 956)))
        right = lerp(PAINTED_FAR_RIGHT_X + 108, PAINTED_NEAR_RIGHT_X + 100, min(1, max(0, (y - 336) / 956)))
        draw.line([(left, y), (right, y)], fill=(*PALETTE["stone_dark"], 80), width=2)
    for i in range(-5, 18):
        x_top = PAINTED_FAR_LEFT_X - 120 + i * 64
        x_bottom = PAINTED_NEAR_LEFT_X - 108 + i * 82
        draw.line([(x_top, 336), (x_bottom, 1292)], fill=(*PALETTE["stone_dark"], 66), width=2)


def draw_court_shadow(draw: ImageDraw.ImageDraw) -> None:
    shadow = [(x + 8, y + 18) for x, y in court_polygon()]
    draw.polygon(shadow, fill=(3, 12, 16, 42))


def draw_zone_tint(
    draw: ImageDraw.ImageDraw,
    top: float,
    bottom: float,
    color: tuple[int, int, int],
    alpha: int,
) -> None:
    draw.polygon(court_polygon(COURT_LEFT + 3, top, COURT_RIGHT - 3, bottom), fill=(*color, alpha))


def draw_scuffs(image: Image.Image, mask: Image.Image) -> None:
    rng = random.Random(9084)
    layer = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer, "RGBA")
    for _ in range(95):
        x = rng.randrange(110, 870)
        y = rng.randrange(440, 1170)
        if mask.getpixel((x, y)) == 0:
            continue
        w = rng.randrange(10, 48)
        h = rng.randrange(2, 8)
        color = PALETTE["line"] if rng.random() < 0.42 else PALETTE["ink"]
        alpha = rng.randrange(12, 30)
        draw.ellipse([x, y, x + w, y + h], fill=(*color, alpha))
    blend_layer(image, layer)


def draw_net_shadow(draw: ImageDraw.ImageDraw) -> None:
    left = court_to_image(COURT_LEFT - 4, COURT_NET_Y + 3)
    right = court_to_image(COURT_RIGHT + 4, COURT_NET_Y + 3)
    lower_right = court_to_image(COURT_RIGHT + 2, COURT_NET_Y + 8)
    lower_left = court_to_image(COURT_LEFT - 2, COURT_NET_Y + 8)
    draw.polygon([left, right, lower_right, lower_left], fill=(29, 73, 88, 255))


def draw_props(image: Image.Image) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    draw_bench(draw, 92, 454, scale=0.78, flip=False)
    draw_bench(draw, 805, 452, scale=0.76, flip=True)
    draw_bench(draw, 44, 760, scale=0.96, flip=False)
    draw_bench(draw, 891, 742, scale=0.92, flip=True)
    draw_planter(draw, 170, 455, scale=0.85)
    draw_planter(draw, 745, 450, scale=0.80)
    draw_planter(draw, 116, 620, scale=0.72)
    draw_planter(draw, 845, 620, scale=0.76)
    draw_equipment_bag(draw, 170, 510, scale=0.78)
    draw_equipment_bag(draw, 805, 520, scale=0.68)


def draw_bench(draw: ImageDraw.ImageDraw, x: float, y: float, *, scale: float, flip: bool) -> None:
    width = 128 * scale
    height = 56 * scale
    draw.ellipse([x - width * 0.45, y + height * 0.70, x + width * 0.45, y + height], fill=(0, 0, 0, 55))
    draw.rectangle([x - width / 2, y, x + width / 2, y + height * 0.18], fill=(*PALETTE["ink"], 220))
    for row in range(3):
        yy = y + height * (0.18 + row * 0.16)
        draw.rectangle([x - width * 0.44, yy, x + width * 0.44, yy + height * 0.10], fill=(*PALETTE["wood"], 235))
        draw.line([(x - width * 0.44, yy), (x + width * 0.44, yy)], fill=(*PALETTE["wood_dark"], 190), width=max(1, int(2 * scale)))
    leg_offset = -0.25 if not flip else 0.25
    for lx in [x - width * 0.32, x + width * 0.32]:
        draw.line([(lx, y + height * 0.58), (lx + width * leg_offset, y + height * 0.94)], fill=(*PALETTE["ink"], 230), width=max(2, int(5 * scale)))


def draw_planter(draw: ImageDraw.ImageDraw, x: float, y: float, *, scale: float) -> None:
    w = 54 * scale
    h = 38 * scale
    draw.ellipse([x - w * 0.58, y + h * 0.56, x + w * 0.58, y + h * 0.92], fill=(0, 0, 0, 48))
    for ox, oy, r, key in [
        (-0.36, -0.36, 0.42, "foliage_dark"),
        (0.10, -0.48, 0.52, "foliage_mid"),
        (0.42, -0.26, 0.36, "foliage_light"),
    ]:
        rr = w * r
        draw.ellipse([x + ox * w - rr / 2, y + oy * h - rr / 2, x + ox * w + rr / 2, y + oy * h + rr / 2], fill=(*PALETTE[key], 235))
    draw.polygon(
        [(x - w * 0.42, y + h * 0.06), (x + w * 0.42, y + h * 0.06), (x + w * 0.28, y + h * 0.72), (x - w * 0.28, y + h * 0.72)],
        fill=(106, 74, 48, 245),
        outline=(*PALETTE["ink"], 190),
    )


def draw_equipment_bag(draw: ImageDraw.ImageDraw, x: float, y: float, *, scale: float) -> None:
    w = 58 * scale
    h = 44 * scale
    draw.ellipse([x - w * 0.46, y + h * 0.62, x + w * 0.54, y + h * 0.92], fill=(0, 0, 0, 58))
    draw.rounded_rectangle([x - w / 2, y, x + w / 2, y + h * 0.72], radius=max(2, int(8 * scale)), fill=(32, 50, 56, 245), outline=(*PALETTE["ink"], 230), width=max(1, int(3 * scale)))
    draw.arc([x - w * 0.24, y - h * 0.18, x + w * 0.24, y + h * 0.36], 180, 360, fill=(*PALETTE["gold"], 210), width=max(1, int(3 * scale)))
    draw.rectangle([x - w * 0.32, y + h * 0.20, x + w * 0.32, y + h * 0.32], fill=(48, 87, 94, 210))


def draw_vignette(image: Image.Image) -> None:
    vignette = Image.new("L", image.size, 0)
    draw = ImageDraw.Draw(vignette)
    draw.ellipse([-200, -80, IMAGE_WIDTH + 200, IMAGE_HEIGHT + 140], fill=255)
    vignette = Image.eval(vignette.filter(ImageFilter.GaussianBlur(72)), lambda p: 86 - int(p * 0.24))
    shade = Image.new("RGBA", image.size, (0, 0, 0, 0))
    shade.putalpha(vignette)
    blend_layer(image, shade)


def blend_layer(image: Image.Image, layer: Image.Image) -> None:
    merged = Image.alpha_composite(image.convert("RGBA"), layer)
    image.paste(merged.convert("RGB"))


def text_outline(
    draw: ImageDraw.ImageDraw,
    xy: tuple[float, float],
    text: str,
    font: ImageFont.ImageFont,
    fill: tuple[int, int, int],
    outline: tuple[int, int, int],
    width: int,
) -> None:
    x, y = xy
    for dx in range(-width, width + 1):
        for dy in range(-width, width + 1):
            if dx * dx + dy * dy <= width * width:
                draw.text((x + dx, y + dy), text, font=font, fill=outline)
    draw.text((x, y), text, font=font, fill=fill)


def load_font(size: int) -> ImageFont.ImageFont:
    candidates = [
        Path("C:/Windows/Fonts/impact.ttf"),
        Path("C:/Windows/Fonts/arialbd.ttf"),
        Path("C:/Windows/Fonts/consolab.ttf"),
    ]
    for path in candidates:
        if path.exists():
            return ImageFont.truetype(str(path), size)
    return ImageFont.load_default()


def lerp(a: float, b: float, t: float) -> float:
    return a * (1 - t) + b * t


def main() -> None:
    image = Image.new("RGB", (IMAGE_WIDTH, IMAGE_HEIGHT), PALETTE["ground"])
    draw = ImageDraw.Draw(image, "RGBA")
    draw_gradient(draw)
    draw_ground_texture(image)
    draw_far_environment(image)
    draw_apron_and_court(image)
    draw_props(image)
    draw_vignette(image)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGBA").save(OUT)

    manifest = {
        "asset": str(OUT.relative_to(ROOT)).replace("\\", "/"),
        "size": [IMAGE_WIDTH, IMAGE_HEIGHT],
        "projection": {
            "paintedFarY": PAINTED_FAR_Y,
            "paintedNetY": PAINTED_NET_Y,
            "paintedNearY": PAINTED_NEAR_Y,
            "paintedFarLeftX": PAINTED_FAR_LEFT_X,
            "paintedFarRightX": PAINTED_FAR_RIGHT_X,
            "paintedNearLeftX": PAINTED_NEAR_LEFT_X,
            "paintedNearRightX": PAINTED_NEAR_RIGHT_X,
            "perspectiveExponent": PERSPECTIVE_EXPONENT,
        },
        "inspiration": [
            "docs/art/concepts/concept-screenshot.png",
            "docs/art/concepts/concept-sheet.png",
            "docs/art/visual-overhaul/contact-sheets/vo3-player-skill-runtime-sheets.png",
            "docs/art/visual-overhaul/contact-sheets/vo3-opponent-skill-runtime-sheets.png",
        ],
        "style": "chunky arcade pixel-art court, blue surface, green park apron, dark fence and signage band",
    }
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {OUT}")
    print(f"wrote {MANIFEST}")


if __name__ == "__main__":
    main()
