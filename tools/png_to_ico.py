"""Small helper to convert a PNG to a multi-resolution Windows .ico file.

Usage:
    1. Install Pillow if needed: pip install pillow
    2. Place your PNG at: assets/icons/app_icon.png
    3. Run this script from the project root:
             python tools/png_to_ico.py

This will write: windows/runner/resources/app_icon.ico
Includes sizes: 16, 32, 48, 64, 96, 128, 256.
"""
from PIL import Image
import os

ROOT = os.path.dirname(os.path.dirname(__file__))
SRC = os.path.join(ROOT, "assets", "icons", "app_icon.png")
DST_DIR = os.path.join(ROOT, "windows", "runner", "resources")
DST = os.path.join(DST_DIR, "app_icon.ico")

if not os.path.exists(SRC):
    print(f"Source PNG not found: {SRC}")
    print("Place your logo PNG at assets/icons/app_icon.png and run again.")
    raise SystemExit(1)

os.makedirs(DST_DIR, exist_ok=True)

img = Image.open(SRC).convert("RGBA")
sizes = [(16,16),(32,32),(48,48),(64,64),(96,96),(128,128),(256,256)]
try:
    img.save(DST, format='ICO', sizes=sizes)
    print(f"Wrote: {DST}")
except Exception as e:
    print("Failed to write .ico:", e)
    raise
