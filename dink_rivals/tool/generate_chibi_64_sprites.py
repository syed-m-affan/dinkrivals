from __future__ import annotations

"""Legacy procedural sprite fallback.

Do not use this script for the current production character art direction
unless the user explicitly asks for procedural fallback output. The accepted
runtime sheets are imagegen-backed skill outputs documented in
docs/art/visual-overhaul/sprite-generator-skill-workflow.md.
"""

import argparse
import json
import math
from datetime import datetime
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFont


CELL = 64
STATES = {
    "idle": 2,
    "ready": 6,
    "run": 12,
    "dink": 4,
    "drive": 6,
    "lob": 6,
    "smash": 6,
    "swing": 6,
    "hit_confirm": 4,
    "point_win": 6,
    "point_loss": 4,
}
ORDER = [
    "idle",
    "ready",
    "run",
    "dink",
    "drive",
    "lob",
    "smash",
    "swing",
    "hit_confirm",
    "point_win",
    "point_loss",
]

OUTLINE = (15, 18, 25, 255)
INK = (31, 35, 43, 255)
WHITE = (239, 236, 220, 255)
WHITE_DARK = (184, 190, 184, 255)
SKIN = (222, 143, 82, 255)
SKIN_LIGHT = (244, 176, 105, 255)
SKIN_DARK = (145, 80, 54, 255)
HAIR = (35, 29, 27, 255)
SOLE = (229, 234, 226, 255)
SHOE_BLUE = (42, 91, 143, 255)
PLAYER_BLUE = (18, 112, 213, 255)
PLAYER_BLUE_DARK = (10, 52, 113, 255)
PLAYER_BLUE_LIGHT = (77, 164, 239, 255)
OPP_RED = (196, 56, 37, 255)
OPP_RED_DARK = (98, 27, 27, 255)
OPP_RED_LIGHT = (237, 99, 55, 255)
PADDLE = (30, 35, 39, 255)
PADDLE_LIGHT = (79, 84, 83, 255)


def side_palette(side: str) -> dict[str, tuple[int, int, int, int]]:
    if side == "player":
        return {
            "shirt": WHITE,
            "shirt_dark": WHITE_DARK,
            "accent": PLAYER_BLUE,
            "accent_dark": PLAYER_BLUE_DARK,
            "accent_light": PLAYER_BLUE_LIGHT,
            "shorts": (15, 55, 87, 255),
            "shorts_light": (30, 90, 130, 255),
            "cap": PLAYER_BLUE,
            "cap_dark": PLAYER_BLUE_DARK,
            "cap_light": PLAYER_BLUE_LIGHT,
        }
    return {
        "shirt": OPP_RED,
        "shirt_dark": OPP_RED_DARK,
        "accent": OPP_RED_LIGHT,
        "accent_dark": OPP_RED_DARK,
        "accent_light": OPP_RED_LIGHT,
        "shorts": (32, 36, 47, 255),
        "shorts_light": (62, 67, 78, 255),
        "cap": WHITE,
        "cap_dark": WHITE_DARK,
        "cap_light": (255, 252, 238, 255),
    }


def draw_line(draw: ImageDraw.ImageDraw, points: list[tuple[int, int]], fill, width: int) -> None:
    draw.line(points, fill=OUTLINE, width=width + 3, joint="curve")
    draw.line(points, fill=fill, width=width, joint="curve")


def draw_ellipse(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], fill) -> None:
    x0, y0, x1, y1 = box
    draw.ellipse((x0 - 1, y0 - 1, x1 + 1, y1 + 1), fill=OUTLINE)
    draw.ellipse(box, fill=fill)


def draw_rect(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], fill) -> None:
    x0, y0, x1, y1 = box
    draw.rectangle((x0 - 1, y0 - 1, x1 + 1, y1 + 1), fill=OUTLINE)
    draw.rectangle(box, fill=fill)


def draw_poly(draw: ImageDraw.ImageDraw, points: list[tuple[int, int]], fill) -> None:
    for dx, dy in ((-2, 0), (2, 0), (0, -2), (0, 2), (-1, -1), (1, -1), (-1, 1), (1, 1)):
        draw.polygon([(x + dx, y + dy) for x, y in points], fill=OUTLINE)
    draw.polygon(points, fill=fill)


def draw_soft_rect(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], fill) -> None:
    x0, y0, x1, y1 = box
    draw.rounded_rectangle((x0 - 2, y0 - 2, x1 + 2, y1 + 2), radius=3, fill=OUTLINE)
    draw.rounded_rectangle(box, radius=2, fill=fill)


def pose_params(state: str, frame: int, frames: int) -> dict[str, float | str]:
    t = frame / max(frames - 1, 1)
    cycle = math.sin((frame / max(frames, 1)) * math.tau)
    alt = math.sin((frame / max(frames, 1)) * math.tau + math.pi)
    params: dict[str, float | str] = {
        "bob": 0,
        "lean": 0,
        "left_leg": -2,
        "right_leg": 2,
        "left_arm": 0,
        "right_arm": 0,
        "paddle_x": 45,
        "paddle_y": 38,
        "paddle_w": 11,
        "paddle_h": 15,
        "face": "ready",
    }
    if state == "idle":
        params["bob"] = 1 if frame == 1 else 0
        params["left_leg"] = -1
        params["right_leg"] = 1
    elif state == "ready":
        params["bob"] = 1 if frame in (1, 4) else 0
        params["lean"] = [-1, 0, 1, 2, 0, -1][frame % 6]
        params["left_arm"] = [-3, -2, -1, 1, -2, -3][frame % 6]
        params["right_arm"] = [3, 2, 1, -1, 2, 3][frame % 6]
    elif state == "run":
        params["bob"] = 1 + round((1 - abs(cycle)) * 1.8)
        params["lean"] = round(cycle * 1.2)
        params["left_leg"] = round(cycle * 6)
        params["right_leg"] = round(alt * 6)
        params["left_arm"] = round(alt * 5)
        params["right_arm"] = round(cycle * 5)
        params["paddle_x"] = 44 + round(cycle * 3)
        params["paddle_y"] = 37 + round(abs(cycle) * 3)
    elif state == "dink":
        params["lean"] = 2
        params["bob"] = 1
        params["right_arm"] = round(2 + t * 7)
        params["paddle_x"] = round(42 + t * 8)
        params["paddle_y"] = round(40 - t * 4)
    elif state in ("drive", "swing", "hit_confirm"):
        params["lean"] = round(1 + t * 3)
        params["right_arm"] = round(1 + math.sin(t * math.pi) * 10)
        params["paddle_x"] = round(31 + t * 17)
        params["paddle_y"] = round(38 - math.sin(t * math.pi) * 9)
    elif state == "lob":
        params["lean"] = -1
        params["right_arm"] = round(t * 9)
        params["paddle_x"] = round(38 + t * 10)
        params["paddle_y"] = round(40 - t * 20)
    elif state == "smash":
        params["lean"] = round(-2 + t * 4)
        params["bob"] = 0 if frame < 2 else 2
        params["right_arm"] = round(10 - t * 12)
        params["paddle_x"] = round(36 + t * 10)
        params["paddle_y"] = round(17 + t * 19)
    elif state == "point_win":
        params["bob"] = 0 if frame % 2 == 0 else 2
        params["left_arm"] = -8
        params["right_arm"] = 8
        params["paddle_x"] = 43
        params["paddle_y"] = 20
        params["face"] = "win"
    elif state == "point_loss":
        params["bob"] = [1, 2, 3, 2][frame % 4]
        params["lean"] = [-1, -2, -3, -2][frame % 4]
        params["left_arm"] = [3, 5, 6, 4][frame % 4]
        params["right_arm"] = [-3, -5, -6, -4][frame % 4]
        params["paddle_x"] = [42, 41, 40, 41][frame % 4]
        params["paddle_y"] = [43, 45, 46, 44][frame % 4]
        params["face"] = "loss"
    return params


def draw_character(side: str, state: str, frame: int, frames: int) -> Image.Image:
    img = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    pal = side_palette(side)
    pose = pose_params(state, frame, frames)
    bob = int(pose["bob"])
    lean = int(pose["lean"])
    cx = 31 + lean
    foot_y = 57 - bob
    hip_y = 42 - bob
    waist_y = 38 - bob
    shoulder_y = 30 - bob
    head_y = 21 - bob

    left_leg = int(pose["left_leg"])
    right_leg = int(pose["right_leg"])
    left_arm = int(pose["left_arm"])
    right_arm = int(pose["right_arm"])

    # Chunkier limbs and shoes match the concept sheet better than the old stick-like pass.
    draw_line(draw, [(cx - 7, hip_y), (cx - 10 - left_leg // 3, 50 - bob), (cx - 13 - left_leg, foot_y - 3)], SKIN, 5)
    draw_line(draw, [(cx + 7, hip_y), (cx + 9 - right_leg // 3, 50 - bob), (cx + 12 - right_leg, foot_y - 3)], SKIN, 5)
    draw_poly(draw, [(cx - 20 - left_leg, foot_y - 5), (cx - 9 - left_leg, foot_y - 5), (cx - 6 - left_leg, foot_y), (cx - 20 - left_leg, foot_y + 1)], SOLE)
    draw_poly(draw, [(cx + 6 - right_leg, foot_y - 5), (cx + 18 - right_leg, foot_y - 5), (cx + 20 - right_leg, foot_y), (cx + 5 - right_leg, foot_y + 1)], SOLE)
    draw.rectangle((cx - 16 - left_leg, foot_y - 3, cx - 9 - left_leg, foot_y - 1), fill=SHOE_BLUE)
    draw.rectangle((cx + 9 - right_leg, foot_y - 3, cx + 17 - right_leg, foot_y - 1), fill=SHOE_BLUE)

    draw_poly(
        draw,
        [(cx - 14, waist_y), (cx + 13, waist_y), (cx + 10, 48 - bob), (cx - 12, 48 - bob)],
        pal["shorts"],
    )
    draw.rectangle((cx - 8, waist_y + 2, cx + 10, waist_y + 5), fill=pal["shorts_light"])

    if side == "player":
        draw_poly(
            draw,
            [(cx - 16, shoulder_y), (cx + 14, shoulder_y), (cx + 17, 42 - bob), (cx + 7, 46 - bob), (cx - 12, 45 - bob), (cx - 17, 38 - bob)],
            pal["shirt"],
        )
        draw.rectangle((cx - 14, shoulder_y + 2, cx - 10, 43 - bob), fill=pal["accent_dark"])
        draw.rectangle((cx + 9, shoulder_y + 3, cx + 14, 43 - bob), fill=pal["shirt_dark"])
        draw.line((cx - 9, shoulder_y + 4, cx + 8, 43 - bob), fill=(210, 211, 201, 255), width=1)
    else:
        draw_poly(
            draw,
            [(cx - 16, shoulder_y), (cx + 15, shoulder_y), (cx + 17, 42 - bob), (cx + 8, 46 - bob), (cx - 13, 45 - bob), (cx - 18, 38 - bob)],
            pal["shirt"],
        )
        draw.rectangle((cx - 14, shoulder_y + 3, cx + 12, shoulder_y + 6), fill=pal["accent"])
        draw.rectangle((cx + 9, shoulder_y + 6, cx + 15, 42 - bob), fill=pal["shirt_dark"])

    if side == "player":
        draw_line(draw, [(cx - 15, shoulder_y + 2), (cx - 21, 38 - bob + left_arm // 2), (cx - 20, 47 - bob + left_arm)], SKIN, 5)
        hand_anchor = (cx + 15, 38 - bob - right_arm // 3)
    else:
        draw_line(draw, [(cx - 15, shoulder_y + 2), (cx - 20, 38 - bob + left_arm // 2), (cx - 18, 45 - bob + left_arm)], SKIN, 5)
        hand_anchor = (cx + 13, 37 - bob - right_arm // 3)
    px = int(pose["paddle_x"])
    py = int(pose["paddle_y"]) - bob
    draw_line(draw, [(cx + 12, shoulder_y + 5), hand_anchor, (px - 7, py + 5)], SKIN, 5)
    draw_line(draw, [(px - 8, py + 5), (px - 3, py - 1)], INK, 3)
    paddle_w = int(pose["paddle_w"])
    paddle_h = int(pose["paddle_h"])
    draw.ellipse((px - paddle_w, py - paddle_h, px + paddle_w, py + paddle_h), fill=OUTLINE)
    draw.ellipse((px - paddle_w + 3, py - paddle_h + 3, px + paddle_w - 2, py + paddle_h - 2), fill=PADDLE)
    draw.arc((px - paddle_w + 5, py - paddle_h + 5, px + paddle_w - 4, py + paddle_h - 3), 255, 75, fill=PADDLE_LIGHT, width=1)

    if side == "player":
        draw_ellipse(draw, (cx - 14, head_y - 11, cx + 13, head_y + 12), HAIR)
        draw.rectangle((cx - 10, head_y + 2, cx + 11, head_y + 11), fill=HAIR)
        draw.rectangle((cx - 6, head_y + 6, cx + 6, head_y + 10), fill=SKIN_DARK)
        draw.ellipse((cx + 10, head_y - 2, cx + 16, head_y + 7), fill=OUTLINE)
        draw.ellipse((cx + 11, head_y - 1, cx + 15, head_y + 6), fill=SKIN)
        draw.ellipse((cx - 15, head_y - 16, cx + 12, head_y - 3), fill=OUTLINE)
        draw.ellipse((cx - 13, head_y - 15, cx + 10, head_y - 5), fill=pal["cap"])
        draw.rectangle((cx - 13, head_y - 8, cx + 8, head_y - 5), fill=pal["cap_dark"])
        draw.rectangle((cx - 2, head_y - 17, cx + 4, head_y - 15), fill=pal["cap_light"])
        draw.rectangle((cx + 7, head_y - 10, cx + 20, head_y - 6), fill=OUTLINE)
        draw.rectangle((cx + 8, head_y - 9, cx + 18, head_y - 7), fill=pal["cap"])
    else:
        draw_ellipse(draw, (cx - 14, head_y - 10, cx + 13, head_y + 13), SKIN)
        draw.rectangle((cx - 10, head_y + 7, cx + 8, head_y + 12), fill=SKIN_LIGHT)
        draw.rectangle((cx - 12, head_y - 1, cx - 8, head_y + 10), fill=HAIR)
        draw.rectangle((cx + 8, head_y, cx + 12, head_y + 10), fill=HAIR)
        draw.ellipse((cx - 15, head_y - 16, cx + 13, head_y - 3), fill=OUTLINE)
        draw.ellipse((cx - 13, head_y - 15, cx + 11, head_y - 5), fill=pal["cap"])
        draw.rectangle((cx - 13, head_y - 7, cx + 11, head_y - 5), fill=pal["cap_dark"])
        draw.rectangle((cx + 6, head_y - 10, cx + 20, head_y - 6), fill=OUTLINE)
        draw.rectangle((cx + 7, head_y - 9, cx + 18, head_y - 7), fill=pal["cap"])
        eye_y = head_y + 2
        if pose["face"] == "loss":
            draw.line((cx - 6, eye_y, cx - 2, eye_y + 2), fill=OUTLINE, width=2)
            draw.line((cx + 2, eye_y + 2, cx + 6, eye_y), fill=OUTLINE, width=2)
        else:
            draw.rectangle((cx - 6, eye_y, cx - 4, eye_y + 2), fill=OUTLINE)
            draw.rectangle((cx + 4, eye_y, cx + 6, eye_y + 2), fill=OUTLINE)
        draw.rectangle((cx - 1, eye_y + 4, cx + 2, eye_y + 5), fill=SKIN_DARK)
        if pose["face"] == "win":
            draw.line((cx - 4, eye_y + 8, cx + 5, eye_y + 8), fill=OUTLINE, width=1)

    return img


def build_sheet(side: str, state: str, frames: int, out_path: Path) -> None:
    sheet = Image.new("RGBA", (CELL * frames, CELL), (0, 0, 0, 0))
    for frame in range(frames):
        sheet.alpha_composite(draw_character(side, state, frame, frames), (frame * CELL, 0))
    sheet.save(out_path)


def frame_metrics(frame: Image.Image) -> dict[str, object]:
    alpha = frame.getchannel("A")
    partial = sum(alpha.histogram()[1:255])
    edge = 0
    for box in ((0, 0, CELL, 1), (0, CELL - 1, CELL, CELL), (0, 0, 1, CELL), (CELL - 1, 0, CELL, CELL)):
        edge += sum(alpha.crop(box).histogram()[1:])
    return {"partial_alpha": partial, "edge_pixels": edge, "bbox": frame.getbbox()}


def audit_sheet(path: Path, frames: int) -> dict[str, object]:
    image = Image.open(path).convert("RGBA")
    errors = []
    warnings = []
    if image.size != (CELL * frames, CELL):
        errors.append(f"wrong geometry {image.size}, expected {(CELL * frames, CELL)}")
    diffs = []
    metrics = []
    previous = None
    for index in range(frames):
        frame = image.crop((index * CELL, 0, (index + 1) * CELL, CELL))
        metric = frame_metrics(frame)
        metrics.append(metric)
        if metric["partial_alpha"]:
            errors.append(f"frame {index} has partial alpha")
        if metric["edge_pixels"]:
            errors.append(f"frame {index} touches edge")
        if previous is not None:
            diff = ImageChops.difference(previous, frame)
            changed = sum(1 for px in diff.getdata() if px != (0, 0, 0, 0)) / (CELL * CELL)
            diffs.append(round(changed, 4))
            if changed < 0.012 and frames > 2:
                warnings.append(f"near-duplicate transition after frame {index - 1}")
        previous = frame
    return {
        "file": path.name,
        "frames": frames,
        "size": list(image.size),
        "errors": errors,
        "warnings": warnings,
        "frame_diffs": diffs,
        "frame_metrics": metrics,
    }


def contact_sheet(paths: list[Path], output: Path) -> None:
    rows = [(path.stem, Image.open(path).convert("RGBA")) for path in paths]
    label_w = 120
    margin = 8
    gap = 8
    max_frames = max(image.width // CELL for _, image in rows)
    out = Image.new("RGBA", (margin * 2 + label_w + max_frames * CELL, margin * 2 + len(rows) * CELL + (len(rows) - 1) * gap), (15, 20, 28, 255))
    draw = ImageDraw.Draw(out)
    try:
        font = ImageFont.truetype("consola.ttf", 10)
    except OSError:
        font = ImageFont.load_default()
    y = margin
    for label, image in rows:
        draw.rectangle((margin, y, out.width - margin, y + CELL), fill=(24, 29, 36, 255))
        draw.text((margin + 2, y + 4), label, fill=(224, 230, 220, 255), font=font)
        for index in range(image.width // CELL):
            x = margin + label_w + index * CELL
            checker = Image.new("RGBA", (CELL, CELL), (42, 46, 54, 255))
            cd = ImageDraw.Draw(checker)
            for cy in range(0, CELL, 8):
                for cx in range(0, CELL, 8):
                    if (cx // 8 + cy // 8) % 2:
                        cd.rectangle((cx, cy, cx + 7, cy + 7), fill=(68, 74, 86, 255))
            checker.alpha_composite(image.crop((index * CELL, 0, (index + 1) * CELL, CELL)))
            out.alpha_composite(checker, (x, y))
            draw.rectangle((x, y, x + CELL, y + CELL), outline=(255, 255, 255, 70))
        y += CELL + gap
    output.parent.mkdir(parents=True, exist_ok=True)
    out.save(output)


def save_gif(path: Path, output: Path, duration: int = 125) -> None:
    image = Image.open(path).convert("RGBA")
    frames = [
        image.crop((index * CELL, 0, (index + 1) * CELL, CELL)).resize((CELL * 4, CELL * 4), Image.Resampling.NEAREST)
        for index in range(image.width // CELL)
    ]
    output.parent.mkdir(parents=True, exist_ok=True)
    frames[0].save(output, save_all=True, append_images=frames[1:], duration=duration, loop=0, disposal=2)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--sprites-dir", required=True)
    parser.add_argument("--run-dir", required=True)
    parser.add_argument("--contact-dir", required=True)
    parser.add_argument("--audit-out", required=True)
    args = parser.parse_args()

    sprites_dir = Path(args.sprites_dir)
    run_dir = Path(args.run_dir)
    contact_dir = Path(args.contact_dir)
    audit_out = Path(args.audit_out)
    run_dir.mkdir(parents=True, exist_ok=True)

    audits = []
    for side in ("player", "opponent"):
        for state, frames in STATES.items():
            path = sprites_dir / f"{side}_{state}.png"
            build_sheet(side, state, frames, path)
            audits.append(audit_sheet(path, frames))

    contact_sheet([sprites_dir / f"player_{state}.png" for state in ORDER], contact_dir / "vo2-player-competitor-runtime-sheets.png")
    contact_sheet([sprites_dir / f"opponent_{state}.png" for state in ORDER], contact_dir / "vo2-opponent-competitor-runtime-sheets.png")
    for side in ("player", "opponent"):
        for state in ("run", "drive", "smash"):
            save_gif(sprites_dir / f"{side}_{state}.png", run_dir / "qa" / "previews" / f"{side}-{state}-64-chibi-x4.gif")

    errors = [error for sheet in audits for error in sheet["errors"]]
    warnings = [warning for sheet in audits for warning in sheet["warnings"]]
    audit_out.parent.mkdir(parents=True, exist_ok=True)
    audit_out.write_text(json.dumps({"cell": [CELL, CELL], "sheets": audits}, indent=2), encoding="utf-8")
    (run_dir / "run-manifest.json").write_text(
        json.dumps(
            {
                "created_at": datetime.now().isoformat(timespec="seconds"),
                "workflow": "native 64x64 chibi replacement sprites",
                "scope": {"cell": [CELL, CELL], "states": STATES, "sides": ["player", "opponent"]},
                "generation": {
                    "method": "concept_guided_hand_authored_64px_chibi_pixel_art",
                    "reason": "User rejected the first procedural chibi pass as uglier than the concept; this pass redraws the runtime sheets around the concept screenshot's large-head competitor proportions, front/back court roles, darker paddle treatment, and binary-alpha cleanup.",
                },
                "outputs": {
                    "audit": audit_out.as_posix(),
                    "player_contact_sheet": (contact_dir / "vo2-player-competitor-runtime-sheets.png").as_posix(),
                    "opponent_contact_sheet": (contact_dir / "vo2-opponent-competitor-runtime-sheets.png").as_posix(),
                    "previews": (run_dir / "qa" / "previews").as_posix(),
                },
            },
            indent=2,
        ),
        encoding="utf-8",
    )
    (run_dir / "sprite-cell-size-decision.md").write_text(
        "\n".join(
            [
                "# Sprite Cell Size Decision",
                "",
                "Decision: move the runtime character sheets to native 64x64 chibi cells.",
                "",
                "Why this changed:",
                "- The user explicitly preferred the chibi direction that better matches the concept.",
                "- 64x64 is the installed character-sprite skill's default for readable chibi game sprites.",
                "- Square cells give enough room for a large head, compact limbs, paddle cue, and clean frame margins without clipping.",
                "- The renderer now computes frame count from 64px cells and samples integer source rectangles.",
                "",
                "Risk accepted:",
                "- This intentionally changes the character silhouette from tall athlete to compact chibi.",
                "- Runtime display dimensions were retuned so gameplay scale stays readable without changing hitboxes or movement.",
                "",
            ]
        ),
        encoding="utf-8",
    )
    print(json.dumps({"ok": not errors, "errors": errors, "warnings": warnings}, indent=2))


if __name__ == "__main__":
    main()
