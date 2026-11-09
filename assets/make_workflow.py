"""Generate the README workflow figure (assets/workflow.svg).

Xenium output -> LoadXenium() -> Seurat .rds -> Shiny app tabs -> plots and
marker genes, drawn in the same palette as the logo. Pure Python, fixed seed.

Usage: python3 assets/make_workflow.py
"""
import math
import random
from pathlib import Path

OUT = Path(__file__).parent
NAVY, AMBER, INK, MUTED = "#1A1A2E", "#F2A541", "#1F2133", "#5E6178"
LINE, PAPER, WHITE = "#E2E4EC", "#F7F8FB", "#FFFFFF"
GLASS, TISSUE, TEDGE, SOFT = "#24243E", "#23233D", "#3B3B60", "#A9ABC8"
GENES = ["#4C9BE8", "#F28C3A", "#45B87A", "#B57BE0"]
SANS = 'font-family="Inter, -apple-system, Segoe UI, Helvetica, Arial, sans-serif"'
MONO = 'font-family="SFMono-Regular, Menlo, Consolas, monospace"'


class Fig:
    def __init__(self, w, h, seed=17):
        self.w, self.h, self.b = w, h, []
        self.rng = random.Random(seed)

    def add(self, x):
        self.b.append(x)

    def g(self):
        r = self.rng
        return (r.random() + r.random() + r.random() - 1.5) / 1.5

    def svg(self):
        markers = "".join(
            f'<marker id="ah-{n}" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" '
            f'orient="auto-start-reverse"><path d="M1.5 1.5L8 5L1.5 8.5" fill="none" stroke="{c}" '
            f'stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></marker>'
            for n, c in [("amber", AMBER), ("muted", "#9A9CB4")])
        return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {self.w} {self.h}" '
                f'width="{self.w}" height="{self.h}" role="img" aria-label="MedicagoXeniumSpatialViewer workflow">\n'
                f'<defs>{markers}</defs>\n' + "\n".join(self.b) + "\n</svg>\n")

    # primitives -----------------------------------------------------------
    def T(self, x, y, t, size=14, w=400, fill=INK, anchor="start", font=SANS, ls=None):
        extra = f' letter-spacing="{ls}"' if ls else ""
        t = str(t).replace("&", "&amp;")
        self.add(f'<text x="{x}" y="{y}" {font} font-size="{size}" font-weight="{w}" fill="{fill}" '
                 f'text-anchor="{anchor}"{extra}>{t}</text>')

    def R(self, x, y, w, h, rx=8, fill=WHITE, stroke=None, sw=1):
        s = f' stroke="{stroke}" stroke-width="{sw}"' if stroke else ""
        self.add(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}"{s}/>')

    def C(self, cx, cy, r, fill, stroke=None, sw=1, op=None):
        s = f' stroke="{stroke}" stroke-width="{sw}"' if stroke else ""
        o = f' opacity="{op}"' if op is not None else ""
        self.add(f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{r}" fill="{fill}"{s}{o}/>')

    def L(self, x1, y1, x2, y2, stroke=AMBER, sw=2, marker=None, dash=None):
        m = f' marker-end="url(#ah-{marker})"' if marker else ""
        d = f' stroke-dasharray="{dash}"' if dash else ""
        self.add(f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{stroke}" stroke-width="{sw}" '
                 f'stroke-linecap="round"{m}{d}/>')

    def chip(self, x, y, text, size=12, fill="#EEF0F6", color=INK, mono=True, center=False, h=None):
        w = len(text) * size * (0.61 if mono else 0.56) + 18
        h = h or size + 12
        if center:
            x = x - w / 2
        self.R(round(x, 1), y, round(w, 1), h, rx=h / 2 if not mono else 6, fill=fill)
        self.T(round(x + w / 2, 1), y + h / 2 + size * 0.35, text, size, 500, color, "middle", MONO if mono else SANS)
        return w

    # illustrations --------------------------------------------------------
    def tissue(self, cx, cy, ax, ay, n=600, r=1.2, outline=True, op=0.9):
        br = lambda t: 1 + 0.08 * math.sin(3 * t + 0.5) + 0.05 * math.cos(5 * t)
        pts = " ".join(f"{cx + ax * br(t) * math.cos(t):.1f},{cy + ay * br(t) * math.sin(t):.1f}"
                       for t in (k / 72 * 2 * math.pi for k in range(72)))
        if outline:
            self.add(f'<polygon points="{pts}" fill="{TISSUE}" stroke="{TEDGE}" stroke-width="1"/>')
        for _ in range(n):
            x, y = cx - ax * 1.2 + self.rng.random() * ax * 2.4, cy - ay * 1.2 + self.rng.random() * ay * 2.4
            u, v = (x - cx) / ax, (y - cy) / ay
            if math.hypot(u, v) < br(math.atan2(v, u)) * 0.95:
                d = int(((u * 0.75 + v * 0.35) + 1.1) / 2.2 * 4 + self.g() * 0.35)
                self.C(x, y, r, GENES[max(0, min(3, d))], op=op)

    def umap(self, cx, cy, s, r=1.5, n=22):
        for (dx, dy), c in zip([(-0.9, -0.7), (0.85, -0.85), (0.95, 0.75), (-0.75, 0.85)], GENES):
            for _ in range(n):
                self.C(cx + (dx + self.g() * 0.6) * s, cy + (dy + self.g() * 0.6) * s, r, c)

    def violin(self, x, y, w, h, colors=(GENES[0], GENES[2])):
        k = len(colors)
        for i, col in enumerate(colors):
            cx = x + w * (i + 0.5) / k
            half = w / k * 0.38
            prof = [(t, half * (0.25 + 0.75 * math.sin(math.pi * t) ** 1.5 * (1 - 0.5 * t))) for t in
                    [j / 20 for j in range(21)]]
            right = [f"{cx + p:.1f},{y + h * (1 - t):.1f}" for t, p in prof]
            left = [f"{cx - p:.1f},{y + h * (1 - t):.1f}" for t, p in reversed(prof)]
            self.add(f'<polygon points="{" ".join(right + left)}" fill="{col}" opacity="0.9"/>')

    def db(self, cx, cy, w, h, fill=AMBER, stroke=NAVY, label=".rds", lfill=NAVY):
        rx, ry, x0, y0 = w / 2, w * 0.14, cx - w / 2, cy - h / 2
        self.add(f'<path d="M{x0},{y0} v{h} a{rx},{ry} 0 0 0 {w},0 v{-h}" fill="{fill}" stroke="{stroke}" stroke-width="1.5"/>')
        self.add(f'<ellipse cx="{cx}" cy="{y0}" rx="{rx}" ry="{ry}" fill="{fill}" stroke="{stroke}" stroke-width="1.5"/>')
        self.add(f'<path d="M{x0},{y0 + h * 0.4} a{rx},{ry} 0 0 0 {w},0" fill="none" stroke="{stroke}" stroke-width="1" opacity="0.5"/>')
        self.T(cx, cy + h * 0.32, label, 13, 700, lfill, "middle", MONO)

    def table(self, x, y, w, h, head=AMBER, body=WHITE, line="#D5D8E3"):
        self.R(x, y, w, h, 6, body, line)
        self.add(f'<path d="M{x},{y + 6} a6,6 0 0 1 6,-6 h{w - 12} a6,6 0 0 1 6,6 v10 h{-w} z" fill="{head}"/>')
        rows = 4
        for i in range(1, rows):
            yy = y + 16 + (h - 16) * i / rows
            self.L(x + 6, yy, x + w - 6, yy, line, 1)
        self.L(x + w * 0.42, y + 18, x + w * 0.42, y + h - 4, line, 1)

    def window(self, x, y, w, h, fill=WHITE, stroke="#D5D8E3", bar="#F1F2F7", title=None, tcol=MUTED):
        self.R(x, y, w, h, 10, fill, stroke, 1.2)
        self.add(f'<path d="M{x},{y + 10} a10,10 0 0 1 10,-10 h{w - 20} a10,10 0 0 1 10,10 v16 h{-w} z" fill="{bar}"/>')
        for i, c in enumerate(["#EE6A5F", "#F5BD4F", "#61C454"]):
            self.C(x + 14 + i * 12, y + 13, 3.6, c)
        if title:
            self.T(x + w / 2, y + 17, title, 11, 500, tcol, "middle")


TABS = ["QC", "UMAP", "Spatial", "Genes", "Markers"]


def v2_dark():
    f = Fig(1000, 340, seed=5)
    f.R(0, 0, 1000, 340, 18, NAVY)
    steps = [(120, "1", "Load"), (330, "2", "Save"), (600, "3", "Explore"), (900, "4", "Export")]
    for x, n, t in steps:
        f.T(x, 44, f"{n}  ·  {t.upper()}", 12, 700, AMBER, "middle", ls="1.5")
    f.tissue(116, 158, 70, 66, 1000, 1.25)
    f.T(120, 270, "Xenium output", 15, 600, WHITE, "middle")
    f.T(120, 290, "transcripts · cells · boundaries", 12, 400, SOFT, "middle")
    f.L(215, 158, 282, 158, AMBER, 2, "amber")
    f.chip(252, 124, "LoadXenium()", 11, "#2A2A48", AMBER, center=True)
    f.db(330, 158, 66, 70)
    f.T(330, 270, "Seurat object", 15, 600, WHITE, "middle")
    f.T(330, 290, "saved as .rds", 12, 400, SOFT, "middle")
    f.L(375, 158, 438, 158, AMBER, 2, "amber")
    f.T(406, 146, "upload", 11, 500, SOFT, "middle")
    f.window(450, 72, 300, 172, GLASS, TEDGE, "#2F2F50", "Xenium Spatial Viewer", SOFT)
    for j, t in enumerate(TABS):
        bx = 462 + j * 56
        f.R(bx, 106, 52, 18, 9, AMBER if j == 2 else "#33335A")
        f.T(bx + 26, 119, t, 10.5, 600, NAVY if j == 2 else SOFT, "middle")
    f.violin(466, 142, 70, 88)
    f.umap(600, 186, 22, 1.2, 16)
    f.tissue(700, 186, 38, 34, 380, 0.95, outline=False)
    f.T(600, 270, "Shiny app", 15, 600, WHITE, "middle")
    f.T(600, 290, "QC · clustering · spatial · genes · markers", 12, 400, SOFT, "middle")
    f.L(760, 130, 822, 112, AMBER, 2, "amber")
    f.L(760, 186, 822, 204, AMBER, 2, "amber")
    f.R(832, 76, 136, 76, 10, "#2A2A48", TEDGE)
    f.umap(870, 114, 13, 1.1, 12)
    f.violin(905, 88, 50, 52, (GENES[1], GENES[3]))
    f.table(832, 168, 136, 76, AMBER, "#2A2A48", TEDGE)
    f.T(900, 270, "Plots & markers", 15, 600, WHITE, "middle")
    f.T(900, 290, "marker_genes.csv", 12, 400, SOFT, "middle", MONO)
    return f


if __name__ == "__main__":
    out = OUT / "workflow.svg"
    out.write_text(v2_dark().svg())
    print("wrote", out)
