"""Generate EchoBack app icons at all required Android sizes."""
import math
import os
from PIL import Image, ImageDraw

SIZE_COLORS = [(1, 1, 36), (10, 10, 50), (20, 20, 60)]
COLOR_PRIMARY = (108, 99, 255)
COLOR_ACCENT = (98, 230, 200)
COLOR_WHITE = (240, 240, 255)

SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

def draw_icon(img: Image, size: int) -> Image:
    base = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(base)
    pad = int(size * 0.08)
    cx = cy = size // 2
    r = size // 2 - pad

    # rounded rect background
    rect = [pad, pad, size - pad, size - pad]
    d.rounded_rectangle(rect, radius=int(size * 0.18), fill=(18, 18, 30, 255))

    # gradient ring
    for i in range(r - 2, r - int(r * 0.55), -1):
        t = (r - i) / (r * 0.55)
        cr = int(COLOR_PRIMARY[0] + (COLOR_ACCENT[0] - COLOR_PRIMARY[0]) * t)
        cg = int(COLOR_PRIMARY[1] + (COLOR_ACCENT[1] - COLOR_PRIMARY[1]) * t)
        cb = int(COLOR_PRIMARY[2] + (COLOR_ACCENT[2] - COLOR_PRIMARY[2]) * t)
        d.ellipse([cx - i, cy - i, cx + i, cy + i], outline=(cr, cg, cb, min(255, int(60 * t))), width=1)

    # inner circle
    ir = int(r * 0.38)
    d.ellipse([cx - ir, cy - ir, cx + ir, cy + ir], fill=COLOR_PRIMARY)

    # mic body
    mic_w = int(ir * 0.35)
    mic_h = int(ir * 0.55)
    mx = cx - mic_w // 2
    my = cy - mic_h // 2 + int(ir * 0.05)
    d.rounded_rectangle([mx, my, mx + mic_w, my + mic_h], radius=int(mic_w * 0.3), fill=COLOR_WHITE)

    # mic top arc
    arc_r = mic_w // 2
    d.arc([cx - arc_r, cy - ir - int(ir * 0.1), cx + arc_r, cy - ir + int(ir * 0.45)], 180, 0, fill=COLOR_WHITE, width=max(2, size // 48))

    # mic stand
    stand_w = max(2, size // 64)
    d.rectangle([cx - stand_w, my + mic_h, cx + stand_w, my + mic_h + int(ir * 0.2)], fill=COLOR_WHITE)

    # mic base arc
    base_arc_y = my + mic_h + int(ir * 0.2)
    d.arc([cx - int(ir * 0.25), base_arc_y, cx + int(ir * 0.25), base_arc_y + int(ir * 0.15)], 0, 180, fill=COLOR_WHITE, width=max(2, size // 64))

    # sound waves
    for j, offset in enumerate([int(ir * 0.55), int(ir * 0.75), int(ir * 0.95)]):
        alpha = max(60, 200 - j * 50)
        sw = max(2, 4 - j)
        d.arc(
            [cx - offset, cy - offset, cx + offset, cy + offset],
            -45, 45, fill=(*COLOR_ACCENT, alpha), width=sw,
        )
        d.arc(
            [cx - offset, cy - offset, cx + offset, cy + offset],
            135, 225, fill=(*COLOR_ACCENT, alpha), width=sw,
        )

    return base

if __name__ == "__main__":
    base_dir = os.path.join(os.path.dirname(__file__), "..", "android", "app", "src", "main", "res")

    # Generate base 1024x1024 and resize
    icon_1024 = draw_icon(None, 1024)

    for folder, px in SIZES.items():
        out_dir = os.path.join(base_dir, folder)
        os.makedirs(out_dir, exist_ok=True)
        out_path = os.path.join(out_dir, "ic_launcher.png")
        resized = icon_1024.resize((px, px), Image.LANCZOS)
        resized.save(out_path, "PNG")
        print(f"  {folder}/ic_launcher.png  {px}x{px}")

    # Also save the 1024 source for reference
    out_1024 = os.path.join(os.path.dirname(__file__), "..", "assets", "icon_1024.png")
    os.makedirs(os.path.dirname(out_1024), exist_ok=True)
    icon_1024.save(out_1024, "PNG")
    print(f"  assets/icon_1024.png  1024x1024 (source)")
    print("Done.")
