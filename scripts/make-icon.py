#!/usr/bin/env python3
"""Draw the Bud Relay app icon: a sunflower relaying light to a tulip and a daisy."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "BudRelay/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
S = 2048  # supersampled, downscaled to 1024


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def petals(draw, cx, cy, count, radius, w, h, color, phase=0.0):
    for i in range(count):
        ang = i / count * 2 * math.pi + phase
        px = cx + math.cos(ang) * radius
        py = cy + math.sin(ang) * radius
        petal = Image.new("RGBA", (int(w * 2), int(h * 2)), (0, 0, 0, 0))
        pd = ImageDraw.Draw(petal)
        pd.ellipse([w / 2, h / 2, w * 1.5, h * 1.5], fill=color)
        petal = petal.rotate(-math.degrees(ang) - 90, resample=Image.BICUBIC)
        draw._image.alpha_composite(petal, (int(px - w), int(py - h)))


def stem(draw, x0, y0, x1, y1, width):
    draw.line([(x0, y0), (x1, y1)], fill=(60, 112, 48, 255), width=width)
    draw.line([(x0, y0), (x1, y1)], fill=(92, 154, 70, 255), width=int(width * 0.6))


def leaf(img, x, y, w, h, angle):
    lf = Image.new("RGBA", (w * 2, h * 2), (0, 0, 0, 0))
    d = ImageDraw.Draw(lf)
    d.ellipse([w // 2, h // 2, w * 3 // 2, h * 3 // 2], fill=(118, 190, 90, 255))
    lf = lf.rotate(angle, resample=Image.BICUBIC)
    img.alpha_composite(lf, (x - w, y - h))


def main() -> None:
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    # Sky-to-meadow gradient background.
    top, mid, bottom = (188, 226, 240), (214, 234, 196), (96, 160, 78)
    bg = Image.new("RGBA", (S, S))
    bd = ImageDraw.Draw(bg)
    for y in range(S):
        t = y / S
        c = lerp(top, mid, t / 0.55) if t < 0.55 else lerp(mid, bottom, (t - 0.55) / 0.45)
        bd.line([(0, y), (S, y)], fill=c + (255,))
    img.alpha_composite(bg)

    # Soft foliage blobs.
    blobs = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    bl = ImageDraw.Draw(blobs)
    for i, (x, y, r, col) in enumerate([
        (300, 1500, 420, (70, 140, 60)), (1750, 1550, 460, (58, 128, 52)), (1000, 1800, 520, (52, 118, 48)),
        (200, 900, 260, (120, 190, 100)), (1850, 950, 280, (130, 196, 110)),
    ]):
        bl.ellipse([x - r, y - r, x + r, y + r], fill=col + (200,))
    blobs = blobs.filter(ImageFilter.GaussianBlur(120))
    img.alpha_composite(blobs)

    # Glow of the relay.
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([S * 0.5 - 560, S * 0.50 - 380, S * 0.5 + 560, S * 0.50 + 380], fill=(255, 232, 120, 190))
    glow = glow.filter(ImageFilter.GaussianBlur(180))
    img.alpha_composite(glow)

    draw = ImageDraw.Draw(img)

    # Relay arcs between the three flowers.
    arc = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ad = ImageDraw.Draw(arc)
    ad.arc([S * 0.20, S * 0.24, S * 0.80, S * 0.86], start=195, end=345, fill=(255, 226, 100, 240), width=44)
    for i in range(7):
        a = math.radians(195 + i * 25)
        px, py = S * 0.5 + math.cos(a) * S * 0.30, S * 0.55 + math.sin(a) * S * 0.31
        ad.ellipse([px - 26, py - 26, px + 26, py + 26], fill=(255, 245, 170, 255))
    arc = arc.filter(ImageFilter.GaussianBlur(6))
    img.alpha_composite(arc)

    # Stems.
    stem(draw, int(S * 0.20), int(S * 0.96), int(S * 0.22), int(S * 0.66), 38)
    stem(draw, int(S * 0.80), int(S * 0.96), int(S * 0.78), int(S * 0.66), 38)
    stem(draw, int(S * 0.5), int(S * 0.98), int(S * 0.5), int(S * 0.56), 52)
    leaf(img, int(S * 0.43), int(S * 0.82), 150, 70, 35)
    leaf(img, int(S * 0.58), int(S * 0.88), 150, 70, -30)

    # Tulip on the left.
    tx, ty = S * 0.22, S * 0.60
    tw, th = S * 0.10, S * 0.14
    draw.rounded_rectangle([tx - tw, ty - th * 0.5, tx + tw, ty + th * 0.75], radius=int(tw * 0.9), fill=(224, 66, 92, 255))
    draw.polygon([(tx - tw, ty - th * 0.3), (tx - tw * 0.55, ty - th * 1.0), (tx - tw * 0.1, ty - th * 0.35)], fill=(236, 90, 112, 255))
    draw.polygon([(tx + tw, ty - th * 0.3), (tx + tw * 0.55, ty - th * 1.0), (tx + tw * 0.1, ty - th * 0.35)], fill=(236, 90, 112, 255))
    draw.polygon([(tx - tw * 0.35, ty - th * 0.3), (tx, ty - th * 1.05), (tx + tw * 0.35, ty - th * 0.3)], fill=(246, 120, 140, 255))

    # Daisy on the right.
    dx, dy = S * 0.78, S * 0.58
    petals(draw, dx, dy, 12, S * 0.065, S * 0.055, S * 0.115, (255, 250, 236, 255))
    draw.ellipse([dx - S * 0.048, dy - S * 0.048, dx + S * 0.048, dy + S * 0.048], fill=(246, 196, 60, 255))

    # Sunflower in the middle, biggest.
    sx, sy = S * 0.5, S * 0.50
    petals(draw, sx, sy, 18, S * 0.12, S * 0.06, S * 0.16, (226, 150, 30, 255), phase=0.17)
    petals(draw, sx, sy, 18, S * 0.11, S * 0.06, S * 0.16, (250, 190, 40, 255))
    r = S * 0.10
    draw.ellipse([sx - r, sy - r, sx + r, sy + r], fill=(94, 58, 28, 255))
    for ring in range(1, 4):
        cnt = ring * 7
        rr = ring * S * 0.026
        for i in range(cnt):
            a = i / cnt * 2 * math.pi + ring * 0.5
            px, py = sx + math.cos(a) * rr, sy + math.sin(a) * rr
            draw.ellipse([px - 14, py - 14, px + 14, py + 14], fill=(60, 36, 16, 255))

    # Small bee near the daisy.
    bx, by = S * 0.66, S * 0.26
    draw.ellipse([bx - 70, by - 46, bx + 70, by + 46], fill=(246, 196, 60, 255))
    for i in range(3):
        x = bx - 36 + i * 36
        draw.rectangle([x - 9, by - 46, x + 9, by + 46], fill=(40, 30, 20, 255))
    draw.ellipse([bx - 48, by - 100, bx + 6, by - 40], fill=(230, 240, 250, 235))
    draw.ellipse([bx - 6, by - 100, bx + 48, by - 40], fill=(230, 240, 250, 235))
    draw.ellipse([bx + 40, by - 30, bx + 90, by + 20], fill=(40, 30, 20, 255))

    icon = img.resize((1024, 1024), resample=Image.LANCZOS).convert("RGB")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    icon.save(OUT, "PNG", optimize=True)
    print(f"wrote {OUT} {icon.size}")


if __name__ == "__main__":
    main()
