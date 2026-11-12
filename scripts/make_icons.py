#!/usr/bin/env python3
"""Genera icona e splash di Voto Tracker ("Stanghette") per Android, web, iOS
e Play Store, senza dipendenze: geometria qui sotto, PNG disegnati in Python.

    python3 scripts/make_icons.py

Uso: rilancialo solo se cambi la geometria o i colori; i file generati sono
versionati. Le coordinate sono nel quadro da 108 dp delle icone adaptive di
Android (zona sicura: cerchio di raggio 33 attorno a 54,54; area visibile:
quadrato 18..90).
"""

import math
import os
import struct
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Colori (vedi docs/DESIGN_SYSTEM.md, sezione Icona e splash).
INDIGO = "#4648D4"  # primary chiaro dell'app
WHITE = "#FFFFFF"
CORAL = "#FF8F80"
LILAC = "#C0C1FF"  # primary scuro
ON_LILAC = "#1000A9"  # onPrimary scuro
SURFACE_LIGHT = "#FCF8FF"
SURFACE_DARK = "#13131B"
AMBER = "#FFC857"  # banda DEBUG
INK = "#1B1B23"

STROKE = 6.0
BARS = [(37 + 11 * i, 38, 37 + 11 * i, 70) for i in range(4)]
# Diagonale accorciata del 10% rispetto alla bozza, dentro la zona sicura.
DIAGONAL = (31.5, 64.8, 76.5, 43.2)

# Banda DEBUG: lettere 3x5 a quadretti.
FONT = {
    "D": ["110", "101", "101", "101", "110"],
    "E": ["111", "100", "110", "100", "111"],
    "B": ["110", "101", "110", "101", "110"],
    "U": ["101", "101", "101", "101", "111"],
    "G": ["011", "100", "101", "101", "011"],
}
BAND = (24.0, 75.0, 84.0, 85.0)
UNIT = 1.3


def debug_letters():
    """Quadretti (x0, y0, x1, y1) della scritta DEBUG, centrata nella banda."""
    word = "DEBUG"
    width = len(word) * 3 * UNIT + (len(word) - 1) * UNIT
    x = 54 - width / 2
    y = (BAND[1] + BAND[3]) / 2 - 2.5 * UNIT
    cells = []
    for ch in word:
        for row, bits in enumerate(FONT[ch]):
            for col, bit in enumerate(bits):
                if bit == "1":
                    cx = x + col * UNIT
                    cy = y + row * UNIT
                    cells.append((cx, cy, cx + UNIT, cy + UNIT))
        x += 4 * UNIT
    return cells


def foreground(bars=WHITE, diagonal=CORAL, debug=False):
    shapes = [("capsule", b, STROKE, bars) for b in BARS]
    shapes.append(("capsule", DIAGONAL, STROKE, diagonal))
    if debug:
        shapes.append(("rect", BAND, 2.0, AMBER))
        shapes += [("rect", c, 0.0, INK) for c in debug_letters()]
    return shapes


# --- Android: VectorDrawable --------------------------------------------------


def vector_xml(shapes):
    out = [
        '<?xml version="1.0" encoding="utf-8"?>',
        "<!-- Generato da scripts/make_icons.py: non modificare a mano. -->",
        '<vector xmlns:android="http://schemas.android.com/apk/res/android"',
        '    android:width="108dp"',
        '    android:height="108dp"',
        '    android:viewportWidth="108"',
        '    android:viewportHeight="108">',
    ]
    for kind, g, w, color in shapes:
        if kind == "capsule":
            ax, ay, bx, by = g
            out.append(
                f'    <path android:pathData="M{ax:g},{ay:g} L{bx:g},{by:g}" '
                f'android:strokeColor="{color}" android:strokeWidth="{w:g}" '
                'android:strokeLineCap="round" />'
            )
        else:
            x0, y0, x1, y1 = (round(v, 3) for v in g)
            r = w
            if r:
                d = (
                    f"M{x0 + r:g},{y0:g} H{x1 - r:g} A{r:g},{r:g} 0 0 1 {x1:g},{y0 + r:g} "
                    f"V{y1 - r:g} A{r:g},{r:g} 0 0 1 {x1 - r:g},{y1:g} H{x0 + r:g} "
                    f"A{r:g},{r:g} 0 0 1 {x0:g},{y1 - r:g} V{y0 + r:g} "
                    f"A{r:g},{r:g} 0 0 1 {x0 + r:g},{y0:g} Z"
                )
            else:
                d = f"M{x0:g},{y0:g} H{x1:g} V{y1:g} H{x0:g} Z"
            out.append(f'    <path android:pathData="{d}" android:fillColor="{color}" />')
    out.append("</vector>")
    return "\n".join(out) + "\n"


# --- SVG (sorgente leggibile, per il Play Store e per guardarla) --------------


def svg(shapes, background):
    parts = [
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108" width="432" height="432">',
        f'<rect width="108" height="108" fill="{background}"/>',
    ]
    for kind, g, w, color in shapes:
        if kind == "capsule":
            ax, ay, bx, by = g
            parts.append(
                f'<line x1="{ax:g}" y1="{ay:g}" x2="{bx:g}" y2="{by:g}" stroke="{color}" '
                f'stroke-width="{w:g}" stroke-linecap="round"/>'
            )
        else:
            x0, y0, x1, y1 = g
            parts.append(
                f'<rect x="{x0:g}" y="{y0:g}" width="{x1 - x0:g}" height="{y1 - y0:g}" '
                f'rx="{w:g}" fill="{color}"/>'
            )
    parts.append("</svg>")
    return "\n".join(parts) + "\n"


# --- PNG: rasterizzatore minimo con bordi sfumati -----------------------------


def rgb(hex_color):
    h = hex_color.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))


def sd_capsule(px, py, g, w):
    ax, ay, bx, by = g
    dx, dy = bx - ax, by - ay
    t = max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy)))
    return math.hypot(px - ax - t * dx, py - ay - t * dy) - w / 2


def sd_rect(px, py, g, r):
    x0, y0, x1, y1 = g
    cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
    hx, hy = (x1 - x0) / 2 - r, (y1 - y0) / 2 - r
    qx, qy = abs(px - cx) - hx, abs(py - cy) - hy
    outside = math.hypot(max(qx, 0.0), max(qy, 0.0))
    return outside + min(max(qx, qy), 0.0) - r


def bbox(kind, g, w):
    if kind == "capsule":
        ax, ay, bx, by = g
        return min(ax, bx) - w, min(ay, by) - w, max(ax, bx) + w, max(ay, by) + w
    return g[0] - 1, g[1] - 1, g[2] + 1, g[3] + 1


def render(size, shapes, background, view=(18.0, 18.0, 72.0), clip=None, alpha=None):
    """PNG RGBA `size`×`size` della porzione `view` (x, y, lato) del quadro.

    clip: None (quadrato pieno), ("circle",) o ("round", raggio in unità).
    """
    vx, vy, side = view
    scale = size / side  # pixel per unità
    bg = rgb(background) if background else None
    px = [[None] * size for _ in range(size)]
    for y in range(size):
        row = px[y]
        for x in range(size):
            row[x] = [*bg, 1.0] if bg else [0, 0, 0, 0.0]
    for kind, g, w, color in shapes:
        c = rgb(color)
        x0, y0, x1, y1 = bbox(kind, g, w)
        ix0 = max(0, int((x0 - vx) * scale))
        iy0 = max(0, int((y0 - vy) * scale))
        ix1 = min(size, int((x1 - vx) * scale) + 2)
        iy1 = min(size, int((y1 - vy) * scale) + 2)
        for y in range(iy0, iy1):
            uy = vy + (y + 0.5) / scale
            row = px[y]
            for x in range(ix0, ix1):
                ux = vx + (x + 0.5) / scale
                d = sd_capsule(ux, uy, g, w) if kind == "capsule" else sd_rect(ux, uy, g, w)
                a = max(0.0, min(1.0, 0.5 - d * scale))
                if a <= 0:
                    continue
                p = row[x]
                out_a = a + p[3] * (1 - a)
                for i in range(3):
                    p[i] = (c[i] * a + p[i] * p[3] * (1 - a)) / out_a
                p[3] = out_a
    if clip:
        half = side / 2
        cx, cy = vx + half, vy + half
        for y in range(size):
            uy = vy + (y + 0.5) / scale
            for x in range(size):
                ux = vx + (x + 0.5) / scale
                if clip[0] == "circle":
                    d = math.hypot(ux - cx, uy - cy) - half
                else:
                    d = sd_rect(ux, uy, (vx, vy, vx + side, vy + side), clip[1])
                px[y][x][3] *= max(0.0, min(1.0, 0.5 - d * scale))
    # Fondo pieno e niente ritaglio: PNG senza canale alfa (lo vuole iOS),
    # salvo richiesta (il Play Store vuole un PNG a 32 bit).
    if alpha is None:
        alpha = not (bg and clip is None)
    raw = bytearray()
    for row in px:
        raw.append(0)
        for r, g_, b, a in row:
            raw += bytes((round(r), round(g_), round(b)))
            if alpha:
                raw.append(round(a * 255))
    return png_bytes(size, size, bytes(raw), alpha=alpha)


def png_bytes(w, h, raw, alpha):
    def chunk(tag, data):
        c = tag + data
        return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)

    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6 if alpha else 2, 0, 0, 0)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")


def write(path, data):
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    mode = "wb" if isinstance(data, bytes) else "w"
    with open(full, mode) as f:
        f.write(data)
    print("scritto", path)


DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}


def main():
    normal = foreground()
    debug = foreground(debug=True)
    mono = foreground(bars="#000000", diagonal="#000000")
    night = foreground(bars=ON_LILAC, diagonal=ON_LILAC)
    res = "android/app/src/main/res"
    dres = "android/app/src/debug/res"

    # Sorgenti leggibili.
    write("assets/icon/icon.svg", svg(normal, INDIGO))
    write("assets/icon/icon_debug.svg", svg(debug, INDIGO))

    # Android 8+: icona adaptive con livello monocromatico (icone a tema).
    write(f"{res}/drawable/ic_launcher_foreground.xml", vector_xml(normal))
    write(f"{res}/drawable/ic_launcher_monochrome.xml", vector_xml(mono))
    write(f"{res}/drawable/ic_splash_night.xml", vector_xml(night))
    write(f"{dres}/drawable/ic_launcher_foreground.xml", vector_xml(debug))

    # Android 7: PNG con angoli arrotondati; splash prima di Android 12.
    for name, k in DENSITIES.items():
        n = round(48 * k)
        write(f"{res}/mipmap-{name}/ic_launcher.png", render(n, normal, INDIGO, clip=("round", 14)))
        write(f"{dres}/mipmap-{name}/ic_launcher.png", render(n, debug, INDIGO, clip=("round", 14)))
        s = round(128 * k)
        write(f"{res}/drawable-{name}/splash_icon.png", render(s, normal, INDIGO, clip=("circle",)))
        write(f"{res}/drawable-night-{name}/splash_icon.png", render(s, night, LILAC, clip=("circle",)))

    # Play Store: 512 px pieno, PNG a 32 bit (la forma la mette lo Store).
    write("assets/icon/play_store_512.png", render(512, normal, INDIGO, alpha=True))

    # Web.
    write("web/icons/Icon-192.png", render(192, normal, INDIGO, clip=("round", 14)))
    write("web/icons/Icon-512.png", render(512, normal, INDIGO, clip=("round", 14)))
    write("web/icons/Icon-maskable-192.png", render(192, normal, INDIGO, view=(0, 0, 108)))
    write("web/icons/Icon-maskable-512.png", render(512, normal, INDIGO, view=(0, 0, 108)))
    write("web/favicon.png", render(32, normal, INDIGO, clip=("round", 14)))

    # iOS: quadrato pieno senza trasparenza; la forma la mette il sistema.
    ios = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for base, scales in [(20, (1, 2, 3)), (29, (1, 2, 3)), (40, (1, 2, 3)), (60, (2, 3)),
                         (76, (1, 2)), (83.5, (2,)), (1024, (1,))]:
        for sc in scales:
            n = round(base * sc)
            label = f"{base:g}x{base:g}"
            write(f"{ios}/Icon-App-{label}@{sc}x.png", render(n, normal, INDIGO))


if __name__ == "__main__":
    main()
