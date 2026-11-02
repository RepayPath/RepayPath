#!/usr/bin/env python3
"""生成 RepayPath 的 1024x1024 App 图标（无 alpha，符合 App Store 要求）。"""
from PIL import Image, ImageDraw, ImageFilter
import math, os

S = 4096          # 超采样画布
OUT = 1024
img = Image.new("RGB", (S, S), (0, 0, 0))

# 1) 对角渐变背景（深青绿）
top = (26, 108, 92)
bottom = (8, 46, 40)
px = img.load()
for y in range(S):
    t = y / (S - 1)
    r = int(top[0] + (bottom[0] - top[0]) * t)
    g = int(top[1] + (bottom[1] - top[1]) * t)
    b = int(top[2] + (bottom[2] - top[2]) * t)
    for x in range(0, S, 8):
        for dx in range(8):
            if x + dx < S:
                px[x + dx, y] = (r, g, b)

d = ImageDraw.Draw(img, "RGBA")

# 2) 余额下降曲线（指数衰减），不做硬边填充，只沿曲线铺一层柔和光
N = 240
pts = []
for i in range(N + 1):
    t = i / N
    x = S * (0.15 + 0.70 * t)
    y = S * (0.26 + 0.50 * (1 - math.exp(-3.0 * t)))
    pts.append((x, y))

# 3) 沿曲线的柔和发光（粗、极度模糊、低透明，边缘自然衰减）
glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
gd = ImageDraw.Draw(glow)
gd.line(pts, fill=(140, 255, 225, 110), width=int(S * 0.075), joint="curve")
glow = glow.filter(ImageFilter.GaussianBlur(S * 0.030))
img = Image.alpha_composite(img.convert("RGBA"), glow)
d = ImageDraw.Draw(img, "RGBA")

# 4) 白色主曲线
d.line(pts, fill=(255, 255, 255, 255), width=int(S * 0.023), joint="curve")

# 4) 末端圆点（还清/注销的终点）
ex, ey = pts[-1]
r = S * 0.038
d.ellipse([ex - r, ey - r, ex + r, ey + r], fill=(255, 255, 255, 255))
r2 = S * 0.019
d.ellipse([ex - r2, ey - r2, ex + r2, ey + r2], fill=(26, 108, 92, 255))

# 5) 起点小圆点，暗示时间轴
sx, sy = pts[0]
r3 = S * 0.016
d.ellipse([sx - r3, sy - r3, sx + r3, sy + r3], fill=(255, 255, 255, 200))

img = img.convert("RGB").resize((OUT, OUT), Image.LANCZOS)
dst = "/home/xykj211/RepayPath/RepayPath/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
img.save(dst, "PNG")
print("saved", dst, img.size, img.mode)
