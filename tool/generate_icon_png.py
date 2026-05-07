"""
Render the City Guide logo to assets/icons/app_logo.png (1024x1024).

This avoids running the Flutter desktop generator (which needs Developer
Mode on Windows) and lets `flutter_launcher_icons` produce platform icons
on every machine without setup.

Usage:
    pip install pillow
    python tool/generate_icon_png.py

Then:
    dart run flutter_launcher_icons
    flutter build apk --release
"""

from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "icons" / "app_logo.png"

SIZE = 1024
RADIUS = 220


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def gradient_rect(width: int, height: int, c1, c2) -> Image.Image:
    img = Image.new("RGB", (width, height))
    px = img.load()
    for y in range(height):
        t = y / max(1, height - 1)
        color = lerp(c1, c2, t)
        for x in range(width):
            px[x, y] = color
    return img


def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)

    # ---- Background: rounded square with diagonal gradient
    bg = gradient_rect(SIZE, SIZE, (66, 165, 245), (21, 101, 192))
    mask = Image.new("L", (SIZE, SIZE), 0)
    mdraw = ImageDraw.Draw(mask)
    mdraw.rounded_rectangle((0, 0, SIZE, SIZE), RADIUS, fill=255)

    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    canvas.paste(bg, (0, 0), mask)

    draw = ImageDraw.Draw(canvas, "RGBA")

    # ---- Soft highlight in upper-left
    draw.ellipse((20, 10, 260, 250), fill=(255, 255, 255, 22))

    # ---- Skyline buildings (white)
    buildings = [
        (96, 300, 52, 120),
        (156, 250, 46, 170),
        (210, 220, 58, 200),
        (276, 260, 46, 160),
        (330, 230, 54, 190),
        (392, 290, 32, 130),
    ]
    for x, y, w, h in buildings:
        draw.rounded_rectangle((x, y, x + w, y + h), 12, fill=(245, 250, 255, 255))

    # ---- Building windows (dark blue, semi-transparent)
    windows = [
        (108, 320), (126, 320), (108, 345), (126, 345),
        (166, 275), (184, 275), (166, 300), (184, 300),
        (222, 250), (240, 250), (222, 280), (240, 280),
        (222, 310), (240, 310),
        (286, 285), (302, 285),
        (342, 260), (360, 260), (342, 290), (360, 290),
    ]
    for x, y in windows:
        draw.rectangle((x, y, x + 10, y + 14), fill=(21, 101, 192, 180))

    # ---- Ground line
    draw.rounded_rectangle((72, 420, 440, 430), 5, fill=(255, 255, 255, 200))

    # ---- Pin (location marker) with vertical gradient
    pin_w, pin_h = 192, 240
    pin_x, pin_y = 160, 80
    pin_grad = gradient_rect(pin_w, pin_h, (255, 112, 67), (230, 74, 25))
    pin_mask = Image.new("L", (pin_w, pin_h), 0)
    pin_mdraw = ImageDraw.Draw(pin_mask)
    # draw a teardrop-ish shape: ellipse on top, triangle at bottom-center
    # ellipse covers upper portion
    pin_mdraw.ellipse((0, 0, pin_w, pin_w), fill=255)
    # bottom triangle pointing down
    tri_top_x = pin_w // 2
    tri = [(0, int(pin_w * 0.65)),
           (pin_w, int(pin_w * 0.65)),
           (tri_top_x, pin_h)]
    pin_mdraw.polygon(tri, fill=255)
    canvas.paste(pin_grad, (pin_x, pin_y), pin_mask)

    # ---- White stroke around pin (approx by re-drawing scaled mask edge)
    stroke = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(stroke)
    sdraw.ellipse((pin_x - 4, pin_y - 4, pin_x + pin_w + 4, pin_y + pin_w + 4),
                  outline=(255, 255, 255, 255), width=8)
    canvas.alpha_composite(stroke)

    # ---- Inner white circle + red dot
    cx, cy = pin_x + pin_w // 2, pin_y + pin_w // 2 - 8
    draw.ellipse((cx - 38, cy - 38, cx + 38, cy + 38), fill=(255, 255, 255, 255))
    draw.ellipse((cx - 16, cy - 16, cx + 16, cy + 16), fill=(230, 74, 25, 255))

    canvas.save(OUT, format="PNG")
    print(f"Wrote {OUT.relative_to(ROOT)}  ({OUT.stat().st_size // 1024} KB, {SIZE}x{SIZE})")


if __name__ == "__main__":
    main()
