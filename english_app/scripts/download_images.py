"""
Script tải ảnh chất lượng cao cho danh sách từ vựng.

Nguồn ảnh (theo thứ tự ưu tiên):
  1. Pexels API  – tìm chính xác theo từ khoá, 200 req/h (miễn phí)
  2. Pixabay API – dự phòng, 100 req/h (miễn phí)

Cài đặt:
  1. Đăng ký API key miễn phí tại https://www.pexels.com/api/
     (và/hoặc https://pixabay.com/api/docs/)
  2. Đặt key vào biến môi trường:
       set PEXELS_API_KEY=your_key_here
       set PIXABAY_API_KEY=your_key_here
     Hoặc sửa trực tiếp trong file này.

Cách dùng:
  python english_app/scripts/download_images.py

Kết quả:
  - Ảnh lưu vào assets/vocab_images/
  - Từ không tìm được ảnh → assets/missing_words.txt
  - File review.html để duyệt và loại ảnh sai trước khi đưa vào app
"""

import os
import sys
import time
import json
import struct
import zlib
import urllib.request
import urllib.error
import html as html_mod
from pathlib import Path

# ============================================================
# 🔑 API Keys – Lấy từ biến môi trường hoặc gán trực tiếp
# ============================================================
PEXELS_API_KEY = os.environ.get(
    "PEXELS_API_KEY",
    "FdjiBOJVJO8cF9OkqdNO5mm75otQ0zUWDWeFdoj8ch0dyepQxoJI8IW2"  # ← Dán Pexels API key vào đây (đăng ký tại https://www.pexels.com/api/)
)
PIXABAY_API_KEY = os.environ.get(
    "PIXABAY_API_KEY",
    "56667488-78610ecba5a10b79aaefe680b"  # ← Dán Pixabay API key vào đây
)

if not PEXELS_API_KEY and not PIXABAY_API_KEY:
    print("❌ Chưa có API key!")
    print("   Đăng ký miễn phí tại: https://www.pexels.com/api/")
    print("   Sau đó đặt: set PEXELS_API_KEY=your_key")
    print("   Hoặc dán key vào biến PEXELS_API_KEY trong script này.")
    sys.exit(1)

# ============================================================
# Đường dẫn
# ============================================================
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)


def _find_assets_dir() -> str:
    candidates = [
        os.path.join(PROJECT_DIR, "assets"),
        os.path.join(os.getcwd(), "english_app", "assets"),
        os.path.join(os.getcwd(), "assets"),
    ]
    for d in candidates:
        if os.path.isfile(os.path.join(d, "words.txt")):
            return d
    return os.path.join(PROJECT_DIR, "assets")


ASSETS_DIR = _find_assets_dir()
WORDS_FILE = os.path.join(ASSETS_DIR, "words.txt")
OUTPUT_DIR = os.path.join(ASSETS_DIR, "vocab_images")
MISSING_FILE = os.path.join(ASSETS_DIR, "missing_words.txt")
REVIEW_FILE = os.path.join(ASSETS_DIR, "review.html")

print(f"📁 Thư mục assets: {ASSETS_DIR}")

# ============================================================
# Cấu hình
# ============================================================
IMAGE_SIZE = 512
HEADERS = {"User-Agent": "VocabImageDownloader/1.0"}
DELAY = 0.7  # giây giữa các request (tôn trọng rate limit)


# ============================================================
# Đọc & parse words.txt
# ============================================================

def parse_words(filepath: str) -> list[str]:
    """Đọc file, bỏ dòng trống và comment (#)."""
    words = []
    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            s = line.strip()
            if s and not s.startswith("#"):
                words.append(s)
    return words


# ============================================================
# Pexels API
# ============================================================

def pexels_search(word: str) -> str | None:
    """Tìm ảnh trên Pexels, trả về URL ảnh hoặc None."""
    if not PEXELS_API_KEY:
        return None

    url = f"https://api.pexels.com/v1/search?query={urllib.request.quote(word)}&per_page=3&size=medium&orientation=square"
    try:
        req = urllib.request.Request(url, headers={
            **HEADERS,
            "Authorization": PEXELS_API_KEY,
        })
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read())

        photos = data.get("photos", [])
        if not photos:
            return None

        # Chọn ảnh đầu tiên (Pexels đã sắp xếp theo độ phổ biến)
        return photos[0]["src"]["medium"]  # 350px, resize về 512 vẫn đẹp

    except Exception as e:
        print(f"     ⚠ Pexels lỗi: {e}")
        return None


# ============================================================
# Pixabay API
# ============================================================

def pixabay_search(word: str) -> str | None:
    """Tìm ảnh trên Pixabay, trả về URL ảnh hoặc None."""
    if not PIXABAY_API_KEY:
        return None

    url = (
        f"https://pixabay.com/api/?"
        f"key={PIXABAY_API_KEY}&"
        f"q={urllib.request.quote(word)}&"
        f"per_page=3&"
        f"image_type=photo&"
        f"orientation=horizontal&"
        f"min_width=400"
    )
    try:
        req = urllib.request.Request(url, headers=HEADERS)
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read())

        hits = data.get("hits", [])
        if not hits:
            return None

        # Pixabay trả webformatURL (640px) – resize vừa đủ
        return hits[0]["webformatURL"]

    except Exception as e:
        print(f"     ⚠ Pixabay lỗi: {e}")
        return None


# ============================================================
# 🎨 Tự tạo ảnh màu sắc (PNG thuần, không cần thư viện ngoài)
# ============================================================

COLOR_SWATCHES: dict[str, tuple[int, int, int]] = {
    "red":    (0xE5, 0x39, 0x35),  # Đỏ vivid
    "blue":   (0x1E, 0x88, 0xE5),  # Xanh dương vivid
    "green":  (0x43, 0xA0, 0x47),  # Xanh lá vivid
    "yellow": (0xFD, 0xD8, 0x35),  # Vàng vivid
    "black":  (0x21, 0x21, 0x21),  # Đen
    "white":  (0xFA, 0xFA, 0xFA),  # Trắng (có viền nhẹ)
}
COLOR_WORDS = set(COLOR_SWATCHES.keys())

# Query tối ưu cho từ mơ hồ
SMART_QUERIES: dict[str, str] = {
    "apple":     "apple fruit red",
    "wind":      "wind blowing trees nature",
    "cloud":     "white cloud blue sky",
    "storm":     "thunderstorm lightning dark sky",
    "heart":     "human heart anatomy medical",
    "foot":      "bare human foot",
    "football":  "soccer ball on field",
    "phone":     "smartphone mobile phone",
    "internet":  "internet network technology globe",
    "screen":    "computer monitor display screen",
    "park":      "green public park nature",
    "market":    "outdoor street food market",
    "station":   "train station railway platform",
    "travel":    "tourist traveling vacation",
    "running":   "person jogging running sport",
    "swimming":  "person swimming pool water",
    "sibling":   "brother sister siblings happy",
    "homework":  "student doing homework studying",
    "rain":      "rain falling weather drops",
}


def _make_png(width: int, height: int, pixels: list[tuple[int, int, int]]) -> bytes:
    """Tạo ảnh PNG từ danh sách pixel RGB (thuần Python, không PIL)."""
    def chunk(ctype: bytes, data: bytes) -> bytes:
        c = ctype + data
        return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)

    # IHDR
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)  # 8-bit RGB

    # IDAT: mỗi dòng = filter byte 0 + RGB*width
    raw = b""
    for y in range(height):
        raw += b"\x00"  # filter None
        for x in range(width):
            r, g, b = pixels[y * width + x]
            raw += struct.pack("BBB", r, g, b)

    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", ihdr)
        + chunk(b"IDAT", zlib.compress(raw))
        + chunk(b"IEND", b"")
    )


def _generate_color_swatch(word: str, filepath: str, size: int = 512) -> bool:
    """Tạo ảnh hình tròn màu trên nền trắng."""
    r, g, b = COLOR_SWATCHES[word.lower()]
    cx, cy, radius = size // 2, size // 2, size // 3

    pixels = []
    for y in range(size):
        for x in range(size):
            dx, dy = x - cx, y - cy
            dist = (dx * dx + dy * dy) ** 0.5

            if word.lower() == "white":
                # Nền xám nhẹ + vòng tròn trắng có viền
                if dist <= radius:
                    pixels.append((255, 255, 255))       # trắng
                elif dist <= radius + 3:
                    pixels.append((180, 180, 180))       # viền xám
                else:
                    pixels.append((235, 235, 235))       # nền xám nhạt
            else:
                if dist <= radius:
                    pixels.append((r, g, b))             # màu chính
                elif dist <= radius + 2:
                    pixels.append((r * 3 // 4, g * 3 // 4, b * 3 // 4))  # viền đậm
                else:
                    pixels.append((248, 248, 248))       # nền trắng

    png_data = _make_png(size, size, pixels)
    with open(filepath, "wb") as f:
        f.write(png_data)
    return True


# ============================================================
# Tải ảnh
# ============================================================

def download_image(word: str, output_dir: str) -> tuple[bool, str]:
    """
    Tải/tạo 1 ảnh.
    - Từ màu sắc → tự tạo swatch PNG
    - Từ khác → Pexels → Pixabay
    Trả về (ok, source_name).
    """
    filename = f"{word.lower().strip().replace(' ', '_')}.jpg" if word.lower() not in COLOR_WORDS \
               else f"{word.lower().strip().replace(' ', '_')}.png"
    filepath = os.path.join(output_dir, filename)

    if os.path.exists(filepath):
        print(f"  ⏭  [{word}] Đã có ảnh, bỏ qua.")
        return True, "cached"

    # 🎨 Từ màu sắc → tự tạo swatch
    if word.lower() in COLOR_WORDS:
        ok = _generate_color_swatch(word, filepath)
        if ok:
            print(f"  🎨 [{word}] → {os.path.basename(filepath)} (color swatch)")
            return True, "generated"
        return False, "gen_error"

    # 🔍 Từ khác → search Pexels
    query = SMART_QUERIES.get(word.lower(), word)
    image_url = pexels_search(query)
    source = "pexels"

    if image_url is None:
        image_url = pixabay_search(query)
        source = "pixabay"

    if image_url is None:
        print(f"  ❌ [{word}] Không tìm thấy ảnh phù hợp → ghi vào missing_words.txt")
        return False, "missing"

    # Tải ảnh
    try:
        req = urllib.request.Request(image_url, headers=HEADERS)
        with urllib.request.urlopen(req, timeout=20) as resp:
            data = resp.read()

        if len(data) < 2000:
            print(f"  ❌ [{word}] Ảnh quá nhỏ ({len(data)} bytes) → bỏ qua")
            return False, "too_small"

        with open(filepath, "wb") as f:
            f.write(data)

        kb = len(data) // 1024
        print(f"  ✅ [{word}] → {filename} ({kb} KB) [{source}]")
        return True, source

    except Exception as e:
        print(f"  ❌ [{word}] Lỗi tải: {e}")
        return False, "download_error"


# ============================================================
# HTML Review Sheet
# ============================================================

def generate_review_html(
    downloaded: list[dict],
    missing: list[str],
    output_path: str,
):
    """Tạo file HTML để duyệt ảnh, đánh dấu ảnh sai."""

    cards = ""
    for item in downloaded:
        word_lower = item["word"].lower()
        ext = ".png" if word_lower in COLOR_WORDS else ".jpg"
        filename = word_lower.strip().replace(" ", "_") + ext
        cards += f"""
        <div class="card" data-word="{html_mod.escape(item['word'])}">
            <img src="vocab_images/{filename}" alt="{html_mod.escape(item['word'])}" loading="lazy" />
            <div class="label">{html_mod.escape(item['word'])}</div>
            <div class="source">{item['source']}</div>
            <button class="btn-bad" onclick="this.parentElement.classList.toggle('rejected')">
                ❌ Ảnh sai
            </button>
        </div>"""

    missing_html = ""
    if missing:
        items = "".join(f"<li>{html_mod.escape(w)}</li>" for w in missing)
        missing_html = f"""
        <div class="missing-section">
            <h3>⚠️ Từ chưa có ảnh ({len(missing)}):</h3>
            <ul>{items}</ul>
            <p><em>Thêm ảnh thủ công cho các từ này trước khi đưa vào app.</em></p>
        </div>"""

    html_content = f"""<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Review Ảnh Từ Vựng – EngMaster</title>
<style>
    * {{ margin:0; padding:0; box-sizing:border-box; }}
    body {{ font-family: 'Segoe UI', system-ui, sans-serif; background:#f5f5f5; padding:20px; }}
    h1 {{ text-align:center; margin-bottom:8px; color:#333; }}
    .subtitle {{ text-align:center; color:#888; margin-bottom:24px; }}
    .stats {{ display:flex; gap:16px; justify-content:center; flex-wrap:wrap; margin-bottom:24px; }}
    .stat {{ background:white; padding:12px 24px; border-radius:12px; box-shadow:0 1px 4px rgba(0,0,0,.08); }}
    .stat .num {{ font-size:28px; font-weight:700; }}
    .stat .lbl {{ font-size:13px; color:#888; }}
    .grid {{ display:grid; grid-template-columns:repeat(auto-fill,minmax(200px,1fr)); gap:16px; }}
    .card {{ background:white; border-radius:12px; overflow:hidden; box-shadow:0 2px 8px rgba(0,0,0,.1); transition:transform .2s,opacity .2s; position:relative; }}
    .card:hover {{ transform:translateY(-3px); }}
    .card.rejected {{ opacity:0.35; text-decoration:line-through; }}
    .card img {{ width:100%; height:180px; object-fit:cover; display:block; }}
    .card .label {{ padding:8px 12px 4px; font-weight:600; font-size:15px; }}
    .card .source {{ padding:0 12px 8px; font-size:11px; color:#aaa; text-transform:uppercase; }}
    .btn-bad {{ display:block; width:100%; padding:8px; border:none; background:#fee; color:#c33; cursor:pointer; font-size:13px; transition:background .2s; }}
    .btn-bad:hover {{ background:#fcc; }}
    .missing-section {{ background:#fff3cd; padding:20px; border-radius:12px; margin-top:24px; }}
    .missing-section ul {{ columns:3; margin-top:8px; padding-left:20px; }}
    .toolbar {{ position:sticky; top:12px; z-index:10; display:flex; gap:12px; justify-content:center; margin-bottom:20px; flex-wrap:wrap; }}
    .toolbar button {{ padding:10px 20px; border:none; border-radius:8px; cursor:pointer; font-size:14px; font-weight:600; transition:all .2s; }}
    .btn-accept {{ background:#4caf50; color:white; }}
    .btn-accept:hover {{ background:#388e3c; }}
    .btn-reject {{ background:#f44336; color:white; }}
    .btn-reject:hover {{ background:#d32f2f; }}
    .btn-reset {{ background:#eee; color:#555; }}
    .btn-reset:hover {{ background:#ddd; }}
</style>
</head>
<body>

<h1>🖼️ Review Ảnh Từ Vựng – EngMaster</h1>
<p class="subtitle">Duyệt nhanh, click ❌Ảnh sai để loại. Sau đó xoá file ảnh tương ứng trong thư mục vocab_images/</p>

<div class="toolbar">
    <button class="btn-reject" onclick="showRejected()">📋 Xem danh sách ảnh bị đánh dấu sai</button>
    <button class="btn-accept" onclick="resetAll()">🔄 Bỏ đánh dấu tất cả</button>
    <span style="color:#888;align-self:center;" id="rejectCount"></span>
</div>

<div class="stats">
    <div class="stat"><div class="num" style="color:#4caf50;">{len(downloaded)}</div><div class="lbl">Ảnh đã tải</div></div>
    <div class="stat"><div class="num" style="color:#f44336;">{len(missing)}</div><div class="lbl">Thiếu ảnh</div></div>
</div>

<div class="grid">
{cards}
</div>

{missing_html}

<script>
function showRejected() {{
    const rejected = document.querySelectorAll('.card.rejected');
    const words = Array.from(rejected).map(c => c.dataset.word);
    if (words.length === 0) {{
        alert('Chưa có ảnh nào bị đánh dấu sai.');
    }} else {{
        alert('Ảnh bị đánh dấu sai (' + words.length + '):\\n\\n' + words.join('\\n') + '\\n\\n→ Vào thư mục vocab_images/ xoá các file này.');
    }}
}}
function resetAll() {{
    document.querySelectorAll('.card.rejected').forEach(c => c.classList.remove('rejected'));
}}
// Auto update count
setInterval(() => {{
    const n = document.querySelectorAll('.card.rejected').length;
    document.getElementById('rejectCount').textContent = n ? n + ' ảnh bị đánh dấu sai' : '';
}}, 500);
</script>
</body>
</html>"""

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(html_content)

    print(f"\n📋 File review: {output_path}")
    print("   Mở file này trong browser để duyệt và loại ảnh sai.")


# ============================================================
# Main
# ============================================================

def main():
    if not os.path.exists(WORDS_FILE):
        print(f"❌ Không tìm thấy: {WORDS_FILE}")
        sys.exit(1)

    words = parse_words(WORDS_FILE)
    if not words:
        print("❌ File words.txt trống hoặc chỉ chứa comment!")
        sys.exit(1)

    print(f"\n📥 Tải ảnh cho {len(words)} từ vựng...")
    print(f"   Nguồn chính: Pexels API | Dự phòng: Pixabay API")
    print(f"   Không dùng ảnh ngẫu nhiên – từ không có ảnh đúng sẽ bị ghi lại.")
    print("-" * 55)

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    downloaded = []   # [{word, source}]
    missing = []      # [word]

    for i, word in enumerate(words, 1):
        print(f"[{i}/{len(words)}] {word}")
        ok, source = download_image(word, OUTPUT_DIR)
        if ok:
            downloaded.append({"word": word, "source": source})
        else:
            missing.append(word)
        if i < len(words):
            time.sleep(DELAY)

    # Tổng kết
    print("-" * 55)
    print(f"\n✅ Đã tải: {len(downloaded)} | ❌ Thiếu: {len(missing)}")

    # Ghi danh sách từ thiếu
    if missing:
        with open(MISSING_FILE, "w", encoding="utf-8") as f:
            f.write("\n".join(missing))
        print(f"📝 Từ thiếu ảnh → {MISSING_FILE}")

    # Tạo HTML review
    if downloaded:
        generate_review_html(downloaded, missing, REVIEW_FILE)

    print(f"\n📁 Ảnh: {OUTPUT_DIR}")
    print("💡 Mở review.html, duyệt ảnh, xoá ảnh sai rồi dùng image_seeder.dart upload lên Firebase.\n")


if __name__ == "__main__":
    main()

