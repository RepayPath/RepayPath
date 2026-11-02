#!/usr/bin/env python3
"""交付前自检：文件齐全、本地化键一致、pbxproj 登记与磁盘文件匹配。"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path("/home/xykj211/RepayPath")
SRC = ROOT / "RepayPath"
pbx = ROOT / "RepayPath.xcodeproj" / "project.pbxproj"

ok = True


def fail(msg):
    global ok
    ok = False
    print("  ❌", msg)


def good(msg):
    print("  ✅", msg)


print("=== 1. Swift 文件与 pbxproj 登记是否一致 ===")
disk = sorted(p.name for p in SRC.rglob("*.swift"))
txt = pbx.read_text()
registered = sorted(set(re.findall(r"path = ([A-Za-z0-9_]+\.swift);", txt)))
print(f"  磁盘 {len(disk)} 个: {', '.join(disk)}")
print(f"  工程 {len(registered)} 个: {', '.join(registered)}")
if disk == registered:
    good("完全一致")
else:
    fail(f"不一致 → 仅在磁盘: {sorted(set(disk)-set(registered))} / 仅在工程: {sorted(set(registered)-set(disk))}")

print("\n=== 2. 括号/引号配平（去注释与字符串后）===")
for f in SRC.rglob("*.swift"):
    raw = f.read_text()
    # 顺序很关键：先去掉字符串字面量（否则 "https://..." 里的 // 会被当成注释，
    # 把整行后面的括号一起吃掉），再去掉注释。
    body = re.sub(r'"(\\.|[^"\\])*"', '""', raw)
    body = re.sub(r"//[^\n]*", "", body)
    body = re.sub(r"/\*.*?\*/", "", body, flags=re.S)
    for open_c, close_c in (("{", "}"), ("(", ")"), ("[", "]")):
        if body.count(open_c) != body.count(close_c):
            fail(f"{f.name}: {open_c}{close_c} 不配平 ({body.count(open_c)}/{body.count(close_c)})")
if ok:
    good("所有 Swift 文件括号配平")

print("\n=== 3. 本地化键一致性 ===")
en = (SRC / "Resources/en.lproj/Localizable.strings").read_text()
zh = (SRC / "Resources/zh-Hans.lproj/Localizable.strings").read_text()
key_re = re.compile(r'^"([^"]+)"\s*=\s*"', re.M)
en_keys, zh_keys = set(key_re.findall(en)), set(key_re.findall(zh))
code_keys = set(re.findall(r't\("([^"]+)"\)', (SRC / "Support/L10n.swift").read_text()))
print(f"  en {len(en_keys)} 键 / zh {len(zh_keys)} 键 / 代码引用 {len(code_keys)} 键")
for label, missing in (("代码用到但 en 缺失", code_keys - en_keys),
                       ("代码用到但 zh 缺失", code_keys - zh_keys),
                       ("en 有 zh 没有", en_keys - zh_keys),
                       ("zh 有 en 没有", zh_keys - en_keys)):
    if missing:
        fail(f"{label}: {sorted(missing)}")
if code_keys <= en_keys and code_keys <= zh_keys and en_keys == zh_keys:
    good("三边完全对齐")

print("\n=== 4. 关键配置 ===")
bids = set(re.findall(r"PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);", txt))
print("  bundle id:", bids)
if len(bids) == 1 and "replaceme" in list(bids)[0]:
    good("仍是占位值（等你给新号前缀后替换）")
elif len(bids) == 1:
    good("已设置且 Debug/Release 一致")
else:
    fail("Debug/Release 的 bundle id 不一致")

for kw in ("UILaunchScreen_Generation", "SWIFT_VERSION = 5.0", "IPHONEOS_DEPLOYMENT_TARGET = 17.0"):
    if kw in txt:
        good(f"含 {kw}")
    else:
        fail(f"缺 {kw}")

print("\n=== 5. 无网络/无 SDK 检查 ===")
banned = ["URLSession", "NSURLConnection", "WKWebView", "import Alamofire", "import Firebase",
          "import AppTrackingTransparency", "ASIdentifierManager", "UITEST", "ProcessInfo"]
hits = []
for f in SRC.rglob("*.swift"):
    t = f.read_text()
    for b in banned:
        if b in t:
            hits.append(f"{f.name}: {b}")
if hits:
    fail("发现可疑引用 → " + "; ".join(hits))
else:
    good("无网络库、无追踪、无第三方 SDK、无调试后门")

print("\n=== 6. 图标 ===")
icon = SRC / "Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
try:
    from PIL import Image
    im = Image.open(icon)
    if im.size == (1024, 1024) and im.mode == "RGB":
        good(f"1024x1024 无 alpha ({im.mode})")
    else:
        fail(f"图标规格不对: {im.size} {im.mode}")
except Exception as e:
    fail(f"图标读取失败: {e}")

print("\n" + ("=" * 40))
print("全部通过 ✅" if ok else "存在问题 ❌")
sys.exit(0 if ok else 1)
