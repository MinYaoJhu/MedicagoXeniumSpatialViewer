"""Generate the MedicagoXeniumSpatialViewer hex logo (assets/logo.svg).

The logo shows an imaging-based Xenium tissue section: individual transcripts
as dots, segmented cells as Voronoi polygons, and a lens whose right half shows
the same cells as UMAP clusters. Pure Python, fixed seed, so output is stable.

Usage: python3 assets/make_logo.py
"""
import math
import random
from pathlib import Path

rng = random.Random(17)

# Palette
BG, EDGE, TISSUE, TISSUE_EDGE, GLASS = "#1A1A2E", "#F2A541", "#23233D", "#3B3B60", "#1E1E36"
CELL_LINE, TEXT = "#8C8CB8", "#FFFFFF"
GENES = ["#4C9BE8", "#F28C3A", "#45B87A", "#B57BE0"]

# Geometry (hex radius 72, scaled up at the end)
HEX = [(0, -72), (62.35, -36), (62.35, 36), (0, 72), (-62.35, 36), (-62.35, -36)]
LX, LY, LR = -6.0, -18.0, 30.0           # lens centre and radius
BX, BY, AX, AY = 0.0, -14.0, 50.0, 38.0  # tissue section centre and semi-axes


def gauss():
    return (rng.random() + rng.random() + rng.random() - 1.5) / 1.5


def blob_r(t):
    return 1 + 0.08 * math.sin(3 * t + 0.5) + 0.05 * math.cos(5 * t)


def in_tissue(x, y):
    u, v = (x - BX) / AX, (y - BY) / AY
    return math.hypot(u, v) < blob_r(math.atan2(v, u)) * 0.97


def in_lens(x, y, margin=0.0):
    return math.hypot(x - LX, y - LY) < LR - margin


def domain(x, y):
    """Spatially coherent 'cell type' so neighbouring cells share colours."""
    d = ((x + 50) * 0.75 + (y + 50) * 0.35 + gauss() * 6) / 24
    return max(0, min(3, int(d)))


def clip_halfplane(poly, a, b, c):
    """Keep the part of polygon where a*x + b*y <= c (Sutherland-Hodgman)."""
    out = []
    for i, p in enumerate(poly):
        q = poly[(i + 1) % len(poly)]
        fp, fq = a * p[0] + b * p[1] - c, a * q[0] + b * q[1] - c
        if fp <= 0:
            out.append(p)
        if fp * fq < 0:
            t = fp / (fp - fq)
            out.append((p[0] + t * (q[0] - p[0]), p[1] + t * (q[1] - p[1])))
    return out


def voronoi(seeds, box):
    x0, y0, x1, y1 = box
    cells = []
    for i, (px, py) in enumerate(seeds):
        poly = [(x0, y0), (x1, y0), (x1, y1), (x0, y1)]
        for j, (qx, qy) in enumerate(seeds):
            if i != j:
                # points closer to p than q: 2(q-p).x <= |q|^2 - |p|^2
                poly = clip_halfplane(poly, 2 * (qx - px), 2 * (qy - py),
                                      qx * qx + qy * qy - px * px - py * py)
        cells.append(poly)
    return cells


def in_poly(x, y, poly):
    inside = False
    for i, (ax, ay) in enumerate(poly):
        bx, by = poly[i - 1]
        if (ay > y) != (by > y) and x < (bx - ax) * (y - ay) / (by - ay) + ax:
            inside = not inside
    return inside


def pts(poly):
    return " ".join(f"{x:.2f},{y:.2f}" for x, y in poly)


svg = []
add = svg.append

# Tissue outline
tissue = [(BX + AX * blob_r(t) * math.cos(t), BY + AY * blob_r(t) * math.sin(t))
          for t in (k / 72 * 2 * math.pi for k in range(72))]

add(f'<polygon points="{pts(HEX)}" fill="{BG}" stroke="{EDGE}" stroke-width="3.5" stroke-linejoin="round"/>')
add(f'<polygon points="{pts(tissue)}" fill="{TISSUE}" stroke="{TISSUE_EDGE}" stroke-width="1"/>')

# Transcripts across the tissue section (outside the lens)
add('<g opacity="0.7">')
for _ in range(900):
    x, y = -55 + rng.random() * 110, -62 + rng.random() * 100
    if in_tissue(x, y) and not in_lens(x, y, -2):
        add(f'<circle cx="{x:.2f}" cy="{y:.2f}" r="0.6" fill="{GENES[domain(x, y)]}"/>')
add('</g>')

# Lens glass
add(f'<circle cx="{LX}" cy="{LY}" r="{LR}" fill="{GLASS}"/>')

# Left half of the lens: segmented cells with their transcripts
seeds = []
while len(seeds) < 10:
    x, y = LX - LR + rng.random() * LR, LY - LR + rng.random() * 2 * LR
    if in_lens(x, y, -4) and all(math.hypot(x - sx, y - sy) > 7 for sx, sy in seeds):
        seeds.append((x, y))
cells = voronoi(seeds, (LX - LR - 2, LY - LR - 2, LX + 2, LY + LR + 2))

add('<g clip-path="url(#lens-left)">')
for (sx, sy), poly in zip(seeds, cells):
    add(f'<polygon points="{pts(poly)}" fill="none" stroke="{CELL_LINE}" stroke-width="0.7" stroke-linejoin="round"/>')
    cell_type = domain(sx + 20, sy)
    placed = 0
    xs, ys = [p[0] for p in poly], [p[1] for p in poly]
    while placed < 14:
        # transcripts spread through the whole visible part of the cell
        x = min(xs) + rng.random() * (max(xs) - min(xs))
        y = min(ys) + rng.random() * (max(ys) - min(ys))
        if in_poly(x, y, poly) and in_lens(x, y, 1.5) and x < LX - 1:
            gene = cell_type if rng.random() < 0.7 else rng.randrange(4)
            add(f'<circle cx="{x:.2f}" cy="{y:.2f}" r="0.8" fill="{GENES[gene]}"/>')
            placed += 1
add('</g>')

# Right half of the lens: the same cells as UMAP clusters
for dx, dy, c in [(12, -13, 0), (17, 3, 1), (8, 16, 2), (6, -2, 3)]:
    for _ in range(24):
        x, y = LX + dx + gauss() * 6.5, LY + dy + gauss() * 6.5
        if in_lens(x, y, 3) and x > LX + 2:
            add(f'<circle cx="{x:.2f}" cy="{y:.2f}" r="1.1" fill="{GENES[c]}"/>')

# Divider, handle, rim
hx, hy = LX + LR * 0.707 + 2, LY + LR * 0.707 + 2
add(f'<line x1="{LX}" y1="{LY - LR}" x2="{LX}" y2="{LY + LR}" stroke="{EDGE}" stroke-width="1.2"/>')
add(f'<line x1="{hx:.2f}" y1="{hy:.2f}" x2="31" y2="17" stroke="{EDGE}" stroke-width="7" stroke-linecap="round"/>')
add(f'<circle cx="{LX}" cy="{LY}" r="{LR}" fill="none" stroke="{EDGE}" stroke-width="4.5"/>')

# Name
font = 'font-family="Helvetica, Arial, sans-serif"'
add(f'<text x="0" y="45" text-anchor="middle" {font} font-size="11" font-weight="bold" fill="{TEXT}">Xenium</text>')
add(f'<text x="0" y="55" text-anchor="middle" {font} font-size="6.8" letter-spacing="0.3" fill="{EDGE}">spatial viewer</text>')

scale = 1.8
half_w, half_h = 62.35 * scale + 4, 72 * scale + 4
out = (
    f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{-half_w:.1f} {-half_h:.1f} {2 * half_w:.1f} {2 * half_h:.1f}" '
    f'width="{2 * half_w:.0f}" height="{2 * half_h:.0f}" role="img" aria-label="MedicagoXeniumSpatialViewer logo">\n'
    f'<defs><clipPath id="lens-left"><path d="M{LX},{LY - LR} A{LR},{LR} 0 0 0 {LX},{LY + LR} Z"/></clipPath></defs>\n'
    f'<g transform="scale({scale})">\n' + "\n".join(svg) + "\n</g>\n</svg>\n"
)
Path(__file__).with_name("logo.svg").write_text(out)
print(f"wrote {Path(__file__).with_name('logo.svg')}")
