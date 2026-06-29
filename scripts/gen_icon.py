"""EchoBack Material 3 app icon — purple bg + bold white waveform."""
import os
from PIL import Image, ImageDraw

BG = (108, 99, 255)      # #6C63FF
WHITE = (255, 255, 255)
LIGHT = (220, 218, 255)

SIZES = {
    "mipmap-mdpi": 48, "mipmap-hdpi": 72, "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144, "mipmap-xxxhdpi": 192,
}

def make(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    p = int(size * 0.06)
    r = int(size * 0.22)

    # solid purple rounded rect
    d.rounded_rectangle([p, p, size - p, size - p], radius=r, fill=BG)

    cx = cy = size // 2
    s = int(size * 0.55)

    # waveform bars (increasing then decreasing)
    bars = [
        (-int(s * 0.38), int(s * 0.28), max(4, int(s * 0.10))),
        (-int(s * 0.22), int(s * 0.40), max(4, int(s * 0.11))),
        (0,              int(s * 0.56), max(5, int(s * 0.13))),
        (int(s * 0.22),  int(s * 0.40), max(4, int(s * 0.11))),
        (int(s * 0.38),  int(s * 0.28), max(4, int(s * 0.10))),
    ]
    for dx, bh, bw in bars:
        bx = cx + dx - bw // 2
        by = cy - bh // 2
        d.rounded_rectangle([bx, by, bx + bw, by + bh], radius=bw // 2, fill=WHITE)

    return img

if __name__ == "__main__":
    root = os.path.join(os.path.dirname(__file__), "..")
    res = os.path.join(root, "android", "app", "src", "main", "res")
    icon = make(1024)
    for folder, px in SIZES.items():
        icon.resize((px, px), Image.LANCZOS).save(os.path.join(res, folder, "ic_launcher.png"), "PNG")
        print(f"  {folder}/ic_launcher.png  {px}x{px}")
    assets = os.path.join(root, "assets")
    os.makedirs(assets, exist_ok=True)
    icon.save(os.path.join(assets, "icon_1024.png"), "PNG")
    print("  assets/icon_1024.png  1024x1024\nDone.")
