#!/usr/bin/env python3
"""Generate app icon as PNG files for macOS .icns creation."""

import subprocess, os, struct, zlib, math

OUT_DIR = os.path.dirname(os.path.abspath(__file__))

def create_png(width, height, pixels):
    """Create a minimal PNG from RGBA pixel data."""
    def chunk(chunk_type, data):
        c = chunk_type + data
        return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)

    header = b"\x89PNG\r\n\x1a\n"
    ihdr = chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))

    raw = b""
    for y in range(height):
        raw += b"\x00"  # filter none
        for x in range(width):
            idx = (y * width + x) * 4
            raw += bytes(pixels[idx:idx+4])

    idat = chunk(b"IDAT", zlib.compress(raw, 9))
    iend = chunk(b"IEND", b"")
    return header + ihdr + idat + iend


def draw_icon(size):
    """Draw whip icon at given size."""
    pixels = [0] * (size * size * 4)
    scale = size / 512.0

    def put_pixel(x, y, r, g, b, a=255):
        if 0 <= x < size and 0 <= y < size:
            idx = (y * size + x) * 4
            # Alpha blend
            sa = a / 255.0
            da = pixels[idx + 3] / 255.0
            oa = sa + da * (1 - sa)
            if oa > 0:
                pixels[idx + 0] = int((r * sa + pixels[idx + 0] * da * (1 - sa)) / oa)
                pixels[idx + 1] = int((g * sa + pixels[idx + 1] * da * (1 - sa)) / oa)
                pixels[idx + 2] = int((b * sa + pixels[idx + 2] * da * (1 - sa)) / oa)
                pixels[idx + 3] = int(oa * 255)

    def fill_circle(cx, cy, r, red, green, blue, alpha=255):
        for y in range(max(0, int(cy - r)), min(size, int(cy + r + 1))):
            for x in range(max(0, int(cx - r)), min(size, int(cx + r + 1))):
                dist = math.sqrt((x - cx)**2 + (y - cy)**2)
                if dist <= r:
                    aa = min(alpha, int(max(0, (r - dist)) * 255)) if dist > r - 1 else alpha
                    put_pixel(x, y, red, green, blue, aa)

    def fill_rounded_rect(x1, y1, x2, y2, radius, r, g, b, a=255):
        for y in range(max(0, int(y1)), min(size, int(y2))):
            for x in range(max(0, int(x1)), min(size, int(x2))):
                inside = True
                # Check corners
                corners = [
                    (x1 + radius, y1 + radius),
                    (x2 - radius, y1 + radius),
                    (x1 + radius, y2 - radius),
                    (x2 - radius, y2 - radius),
                ]
                for cx, cy in corners:
                    if ((x < x1 + radius or x > x2 - radius) and
                        (y < y1 + radius or y > y2 - radius)):
                        if math.sqrt((x - cx)**2 + (y - cy)**2) > radius:
                            inside = False
                            break
                if inside:
                    put_pixel(x, y, r, g, b, a)

    def draw_thick_line(x1, y1, x2, y2, thickness, r, g, b, a=255):
        length = math.sqrt((x2-x1)**2 + (y2-y1)**2)
        if length == 0:
            return
        steps = max(1, int(length * 2))
        for i in range(steps + 1):
            t = i / steps
            cx = x1 + (x2 - x1) * t
            cy = y1 + (y2 - y1) * t
            fill_circle(cx, cy, thickness / 2, r, g, b, a)

    def draw_bezier(points, thickness, r, g, b, a=255, steps=100):
        """Draw cubic bezier curve."""
        prev = None
        for i in range(steps + 1):
            t = i / steps
            # Cubic bezier
            u = 1 - t
            x = (u**3 * points[0][0] + 3*u**2*t * points[1][0] +
                 3*u*t**2 * points[2][0] + t**3 * points[3][0])
            y = (u**3 * points[0][1] + 3*u**2*t * points[1][1] +
                 3*u*t**2 * points[2][1] + t**3 * points[3][1])
            # Taper the whip
            th = thickness * (1 - t * 0.7)
            if prev:
                draw_thick_line(prev[0], prev[1], x, y, th, r, g, b, a)
            prev = (x, y)

    s = scale  # shorthand

    # Background - rounded square with gradient
    radius = 90 * s
    for y in range(size):
        for x in range(size):
            # Gradient from dark to darker
            t = y / size
            r_bg = int(35 + 15 * t)
            g_bg = int(30 + 10 * t)
            b_bg = int(45 + 15 * t)
            put_pixel(x, y, r_bg, g_bg, b_bg, 0)  # transparent bg

    # Rounded rect background
    fill_rounded_rect(10*s, 10*s, 502*s, 502*s, radius, 40, 32, 52, 255)

    # Inner gradient overlay (subtle)
    for y in range(int(10*s), min(size, int(502*s))):
        for x in range(int(10*s), min(size, int(502*s))):
            t = (y - 10*s) / (492*s)
            a = int(30 * t)
            put_pixel(x, y, 0, 0, 0, a)

    # Whip handle
    hx, hy = 140 * s, 380 * s
    hw, hh = 40 * s, 130 * s

    # Handle shadow
    fill_rounded_rect(hx + 4*s, hy + 4*s, hx + hw + 4*s, hy + hh + 4*s, 6*s, 20, 15, 10, 80)
    # Handle body
    fill_rounded_rect(hx, hy, hx + hw, hy + hh, 6*s, 101, 58, 24, 255)
    # Handle highlight
    fill_rounded_rect(hx + 4*s, hy, hx + 12*s, hy + hh, 4*s, 140, 85, 40, 100)
    # Handle grip lines
    for i in range(5):
        gy = hy + 20*s + i * 22*s
        draw_thick_line(hx + 3*s, gy, hx + hw - 3*s, gy, 2*s, 70, 38, 15, 180)

    # Handle pommel (bottom)
    fill_rounded_rect(hx - 4*s, hy + hh - 8*s, hx + hw + 4*s, hy + hh + 8*s, 5*s, 80, 45, 18, 255)

    # Whip lash - bezier curve from handle top to crack point
    lash_start = (160*s, 380*s)
    ctrl1 = (180*s, 280*s)
    ctrl2 = (300*s, 180*s)
    lash_end = (420*s, 100*s)

    # Lash shadow
    shadow_points = [(p[0]+3*s, p[1]+3*s) for p in [lash_start, ctrl1, ctrl2, lash_end]]
    draw_bezier(shadow_points, 14*s, 20, 15, 10, 60, steps=150)
    # Lash body
    draw_bezier([lash_start, ctrl1, ctrl2, lash_end], 12*s, 90, 50, 20, 255, steps=150)
    # Lash highlight
    highlight_points = [(p[0]-1*s, p[1]-1*s) for p in [lash_start, ctrl1, ctrl2, lash_end]]
    draw_bezier(highlight_points, 4*s, 130, 80, 35, 100, steps=150)

    # Crack effect at tip - starburst
    cx, cy = 420*s, 100*s

    # Glow
    for r in range(int(50*s), 0, -1):
        a = int(60 * (1 - r / (50*s)))
        fill_circle(cx, cy, r, 255, 180, 50, a)

    # Spark lines
    for angle_deg in range(0, 360, 30):
        angle = math.radians(angle_deg + 15)
        length = (25 + (angle_deg % 60) * 0.3) * s
        ex = cx + math.cos(angle) * length
        ey = cy + math.sin(angle) * length
        draw_thick_line(cx, cy, ex, ey, 2.5*s, 255, 220, 100, 200)

    # Central flash
    fill_circle(cx, cy, 12*s, 255, 255, 255, 255)
    fill_circle(cx, cy, 8*s, 255, 240, 180, 255)

    # Small spark dots
    for angle_deg in range(0, 360, 45):
        angle = math.radians(angle_deg)
        dist = 35 * s
        sx = cx + math.cos(angle) * dist
        sy = cy + math.sin(angle) * dist
        fill_circle(sx, sy, 3*s, 255, 200, 80, 220)

    return pixels


def main():
    iconset_dir = os.path.join(OUT_DIR, "AppIcon.iconset")
    os.makedirs(iconset_dir, exist_ok=True)

    sizes = [
        (16, "icon_16x16.png"),
        (32, "icon_16x16@2x.png"),
        (32, "icon_32x32.png"),
        (64, "icon_32x32@2x.png"),
        (128, "icon_128x128.png"),
        (256, "icon_128x128@2x.png"),
        (256, "icon_256x256.png"),
        (512, "icon_256x256@2x.png"),
        (512, "icon_512x512.png"),
    ]

    for px_size, filename in sizes:
        print(f"  Generating {filename} ({px_size}x{px_size})...")
        pixels = draw_icon(px_size)
        png_data = create_png(px_size, px_size, pixels)
        with open(os.path.join(iconset_dir, filename), "wb") as f:
            f.write(png_data)

    # Convert to .icns
    icns_path = os.path.join(OUT_DIR, "AppIcon.icns")
    subprocess.run(["iconutil", "-c", "icns", iconset_dir, "-o", icns_path], check=True)
    print(f"  Created: {icns_path}")

    # Cleanup iconset
    import shutil
    shutil.rmtree(iconset_dir)


if __name__ == "__main__":
    print("Generating app icon...")
    main()
    print("Done!")
