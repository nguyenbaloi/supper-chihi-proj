"""Sinh icon launcher Android + iOS tu assets/icon/iconappchichi.png.

Anh nguon la anh che ban: hinh icon bo goc dat giua nen trang co bong do.
Script cat lay dung hinh icon, roi keo mau vien ra tran khung vuong
(edge-clamp theo goc cuc) de he dieu hanh tu bo goc ma khong lo vien trang.

Chay bang venv scratchpad co Pillow — khong dung phu thuoc nao cua project.
"""
import math, os, sys
from PIL import Image

ROOT = sys.argv[1]
SRC = os.path.join(ROOT, 'assets/icon/iconappchichi.png')
OUT_PREVIEW = sys.argv[2] if len(sys.argv) > 2 else None

# --- 1. Cat lay hinh icon, bo nen trang + bong do -------------------------
CROP = (113, 127, 911, 933)          # do bang do bao hoa mau, xem ghi chu commit
N = 1024                             # do phan giai ban chu
src = Image.open(SRC).convert('RGB').crop(CROP).resize((N, N), Image.LANCZOS)
px = src.load()

# --- 2. Mat na "ben trong hinh icon" -------------------------------------
# Vung ngoai = nen sang, do bao hoa thap; loang tu 4 goc vao nen khong an
# nham mau kem/trang cua long gau truc ben trong.
def is_bg(p):
    r, g, b = p
    mx, mn = max(p), min(p)
    sat = 0 if mx == 0 else (mx - mn) / mx
    return sat < 0.20 and mx > 195

outside = [[False] * N for _ in range(N)]
stack = [(0, 0), (N - 1, 0), (0, N - 1), (N - 1, N - 1)]
while stack:
    x, y = stack.pop()
    if x < 0 or y < 0 or x >= N or y >= N or outside[y][x] or not is_bg(px[x, y]):
        continue
    outside[y][x] = True
    stack += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
n_out = sum(map(sum, outside))
print(f'  vung ngoai hinh icon: {n_out} px ({n_out / (N * N):.2%} khung)')

# --- 3. Mau vien theo goc cuc, co lui vao 3 px tranh rang cua -----------
NA, INSET = 2880, 3
c = (N - 1) / 2.0
border = []
for i in range(NA):
    th = 2 * math.pi * i / NA
    dx, dy = math.cos(th), math.sin(th)
    rmax = c / max(abs(dx), abs(dy))
    r = rmax
    while r > 0:                      # lui tu bien vao den khi cham hinh icon
        x, y = int(c + dx * r), int(c + dy * r)
        if 0 <= x < N and 0 <= y < N and not outside[y][x]:
            break
        r -= 1.0
    r = max(r - INSET, 0)
    border.append(px[int(c + dx * r), int(c + dy * r)])

def bleed(alpha_outside):
    """Tra ve ban tran vien. alpha_outside=0 -> goc trong suot (lop foreground)."""
    im = Image.new('RGBA', (N, N))
    q = im.load()
    for y in range(N):
        for x in range(N):
            if outside[y][x]:
                th = math.atan2(y - c, x - c) % (2 * math.pi)
                r, g, b = border[int(th / (2 * math.pi) * NA) % NA]
                q[x, y] = (r, g, b, alpha_outside)
            else:
                q[x, y] = px[x, y] + (255,)
    return im

full = bleed(255)      # tran vien dac — cho iOS + mipmap thuong + nen adaptive
shaped = bleed(0)      # giu bo goc trong suot — cho lop foreground adaptive
if OUT_PREVIEW:
    full.save(os.path.join(OUT_PREVIEW, 'preview-full.png'))
    shaped.save(os.path.join(OUT_PREVIEW, 'preview-shaped.png'))

# --- 4. Android mipmap thuong -------------------------------------------
DPI = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
res = os.path.join(ROOT, 'android/app/src/main/res')
for dpi, k in DPI.items():
    d = os.path.join(res, f'mipmap-{dpi}')
    os.makedirs(d, exist_ok=True)
    s = round(48 * k)
    full.resize((s, s), Image.LANCZOS).save(os.path.join(d, 'ic_launcher.png'))

    # Adaptive: khung 108dp, noi dung nam gon trong vung an toan 72dp giua.
    S, inner = round(108 * k), round(72 * k)
    off = (S - inner) // 2

    fg = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    fg.paste(shaped.resize((inner, inner), Image.LANCZOS), (off, off))
    fg.save(os.path.join(d, 'ic_launcher_foreground.png'))

    # Nen = chinh mau vien keo tiep ra ngoai, nen lien mach voi foreground.
    bg = Image.new('RGB', (S, S))
    b = bg.load()
    ic = (inner - 1) / 2.0
    for y in range(S):
        for x in range(S):
            th = math.atan2((y - off) - ic, (x - off) - ic) % (2 * math.pi)
            b[x, y] = border[int(th / (2 * math.pi) * NA) % NA]
    bg.save(os.path.join(d, 'ic_launcher_background.png'))
    print(f'  mipmap-{dpi}: ic_launcher {s}px, adaptive {S}px (an toan {inner}px)')

# --- 5. iOS — App Store cam kenh alpha -----------------------------------
IOS = {
    'Icon-App-20x20@1x.png': 20, 'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60, 'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58, 'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40, 'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120, 'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180, 'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152, 'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
}
ios_dir = os.path.join(ROOT, 'ios/Runner/Assets.xcassets/AppIcon.appiconset')
flat = full.convert('RGB')
for name, s in IOS.items():
    flat.resize((s, s), Image.LANCZOS).save(os.path.join(ios_dir, name))
print(f'  ios: {len(IOS)} file RGB (khong alpha)')
