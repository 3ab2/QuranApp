#!/usr/bin/env python3
"""Regenerate Android mipmap launcher PNGs from web/icons/Icon-512.png."""

from __future__ import annotations

import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset" / "Icon-App-1024x1024@1x.png"
RES = ROOT / "android" / "app" / "src" / "main" / "res"

# Standard launcher icon sizes (px).
SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}


def _paeth(a: int, b: int, c: int) -> int:
    p = a + b - c
    pa = abs(p - a)
    pb = abs(p - b)
    pc = abs(p - c)
    if pa <= pb and pa <= pc:
        return a
    if pb <= pc:
        return b
    return c


def _read_jpeg(path: Path) -> tuple[int, int, bytes]:
    try:
        from PIL import Image  # type: ignore
    except ImportError:
        raise SystemExit("Install Pillow: pip install pillow") from None
    img = Image.open(path).convert("RGBA")
    return img.width, img.height, img.tobytes()


def _read_png(path: Path) -> tuple[int, int, bytes]:
    data = path.read_bytes()
    if data[:2] == b"\xff\xd8":
        return _read_jpeg(path)
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"Unsupported image format: {path}")
    pos = 8
    width = height = 0
    raw = b""
    while pos < len(data):
        length = struct.unpack(">I", data[pos : pos + 4])[0]
        pos += 4
        ctype = data[pos : pos + 4]
        pos += 4
        chunk = data[pos : pos + length]
        pos += length
        pos += 4  # crc
        if ctype == b"IHDR":
            width, height = struct.unpack(">II", chunk[:8])
        elif ctype == b"IDAT":
            raw += chunk
        elif ctype == b"IEND":
            break
    if not width:
        raise ValueError("Missing IHDR")
    inflated = zlib.decompress(raw)
    stride = width * 4
    rows = []
    i = 0
    for _ in range(height):
        filt = inflated[i]
        i += 1
        row = bytearray(inflated[i : i + stride])
        i += stride
        if filt == 1:
            for x in range(4, len(row)):
                row[x] = (row[x] + row[x - 4]) & 255
        elif filt == 2:
            prev = rows[-1] if rows else bytearray(stride)
            for x in range(len(row)):
                row[x] = (row[x] + prev[x]) & 255
        elif filt == 3:
            prev = rows[-1] if rows else bytearray(stride)
            for x in range(len(row)):
                left = row[x - 4] if x >= 4 else 0
                row[x] = (row[x] + (left + prev[x]) // 2) & 255
        elif filt == 4:
            prev = rows[-1] if rows else bytearray(stride)
            for x in range(len(row)):
                left = row[x - 4] if x >= 4 else 0
                up = prev[x]
                up_left = prev[x - 4] if x >= 4 else 0
                row[x] = (row[x] + _paeth(left, up, up_left)) & 255
        rows.append(bytes(row))
    return width, height, b"".join(rows)


def _write_png(path: Path, width: int, height: int, rgba: bytes) -> None:
    def chunk(ctype: bytes, payload: bytes) -> bytes:
        crc = zlib.crc32(ctype + payload) & 0xFFFFFFFF
        return struct.pack(">I", len(payload)) + ctype + payload + struct.pack(">I", crc)

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    raw = bytearray()
    stride = width * 4
    for y in range(height):
        raw.append(0)
        raw.extend(rgba[y * stride : (y + 1) * stride])
    idat = zlib.compress(bytes(raw), 9)
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", idat) + chunk(b"IEND", b"")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(png)


def _resize_rgba(
    src_w: int, src_h: int, src: bytes, dst_w: int, dst_h: int
) -> bytes:
    dst = bytearray(dst_w * dst_h * 4)
    for y in range(dst_h):
        sy = min(src_h - 1, int(y * src_h / dst_h))
        for x in range(dst_w):
            sx = min(src_w - 1, int(x * src_w / dst_w))
            si = (sy * src_w + sx) * 4
            di = (y * dst_w + x) * 4
            dst[di : di + 4] = src[si : si + 4]
    return bytes(dst)


def main() -> None:
    if not SRC.is_file():
        raise SystemExit(f"Source icon missing: {SRC}")
    sw, sh, rgba = _read_png(SRC)
    for folder, size in SIZES.items():
        out_dir = RES / folder
        scaled = _resize_rgba(sw, sh, rgba, size, size)
        for name in ("ic_launcher.png", "ic_launcher_foreground.png"):
            _write_png(out_dir / name, size, size, scaled)
            print(f"Wrote {out_dir / name} ({size}x{size})")


if __name__ == "__main__":
    main()
