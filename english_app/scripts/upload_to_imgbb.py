"""
Upload ảnh từ vựng lên ImgBB (miễn phí, không cần thẻ) + cập nhật Firestore.

Pipeline:
  assets/vocab_images/*.jpg|.png
      │
      ▼  POST https://api.imgbb.com/1/upload
  ImgBB cloud
      │
      ▼  Lấy display_url
  Firestore: vocabularies/{docId}.imageUrl = URL

Cách chạy:
  python scripts/upload_to_imgbb.py
"""

import os
import sys
import time
import json
import base64
import urllib.request
import urllib.parse

# ============================================================
# Cấu hình
# ============================================================
IMGBB_API_KEY = "54454ff16250b5a9f5fc35f622c58222"
IMGBB_UPLOAD_URL = "https://api.imgbb.com/1/upload"

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
ASSETS_DIR = os.path.join(PROJECT_DIR, "assets")
IMAGES_DIR = os.path.join(ASSETS_DIR, "vocab_images")
SERVICE_ACCOUNT_FILE = os.path.join(SCRIPT_DIR, "service_account.json")
FIRESTORE_DATA_FILE = os.path.join(ASSETS_DIR, "firebase_seed", "firestore_data.json")


# ============================================================
# Kiểm tra prerequisites
# ============================================================

def check_prerequisites():
    if not os.path.exists(SERVICE_ACCOUNT_FILE):
        print("❌ Không tìm thấy service_account.json!")
        print(f"   Đặt file vào: {SERVICE_ACCOUNT_FILE}")
        sys.exit(1)

    if not os.path.isdir(IMAGES_DIR):
        print(f"❌ Không tìm thấy thư mục ảnh: {IMAGES_DIR}")
        sys.exit(1)

    try:
        import firebase_admin
    except ImportError:
        print("❌ Chưa cài firebase-admin!")
        print("   Chạy: pip install firebase-admin")
        sys.exit(1)


# ============================================================
# Map từ vựng: word → firestore docId
# ============================================================

def build_word_to_docid() -> dict[str, str]:
    """Đọc firestore_data.json, tạo map word → docId."""
    if not os.path.exists(FIRESTORE_DATA_FILE):
        print(f"⚠ Không tìm thấy {FIRESTORE_DATA_FILE}, sẽ dùng word làm docId")
        return {}

    with open(FIRESTORE_DATA_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    mapping = {}
    for v in data.get("vocabularies", []):
        word_key = v["word"].lower().strip()
        mapping[word_key] = v["id"]
    return mapping


# ============================================================
# Upload lên ImgBB
# ============================================================

def upload_to_imgbb(filepath: str) -> str | None:
    """Upload 1 file ảnh lên ImgBB, trả về display_url hoặc None."""
    try:
        # Đọc file và encode base64
        with open(filepath, "rb") as f:
            image_data = base64.b64encode(f.read()).decode("utf-8")

        # Gọi API ImgBB
        data = urllib.parse.urlencode({
            "key": IMGBB_API_KEY,
            "image": image_data,
        }).encode("utf-8")

        req = urllib.request.Request(IMGBB_UPLOAD_URL, data=data, method="POST")
        req.add_header("Content-Type", "application/x-www-form-urlencoded")

        with urllib.request.urlopen(req, timeout=30) as resp:
            result = json.loads(resp.read())

        if result.get("success"):
            return result["data"]["display_url"]  # URL ảnh gốc hiển thị được
        else:
            error_msg = result.get("error", {}).get("message", "Unknown error")
            print(f"     ⚠ ImgBB lỗi: {error_msg}")
            return None

    except Exception as e:
        print(f"     ⚠ Lỗi upload ImgBB: {e}")
        return None


# ============================================================
# Tạo file review.html
# ============================================================

def generate_review_html(results: list[dict]):
    """Tạo file HTML để xem trước ảnh đã upload."""
    html_parts = [
        "<!DOCTYPE html><html lang='vi'><head><meta charset='utf-8'>",
        "<title>Review ảnh từ vựng</title>",
        "<style>body{font-family:sans-serif;max-width:1200px;margin:auto;padding:20px}",
        ".grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:16px}",
        ".card{border:1px solid #ddd;border-radius:10px;overflow:hidden;background:#fafafa}",
        ".card img{width:100%;height:180px;object-fit:cover}",
        ".card .info{padding:10px}",
        ".card .word{font-weight:bold;font-size:16px}",
        ".card .status{font-size:12px;color:#666}",
        ".ok{border-left:4px solid #4caf50}",
        ".skip{border-left:4px solid #ff9800}",
        ".fail{border-left:4px solid #f44336}</style></head><body>",
        "<h1>📸 Review ảnh từ vựng</h1>",
        f"<p>Tổng: {len(results)} ảnh</p><div class='grid'>",
    ]

    for r in results:
        status_class = r.get("status", "")
        status_icon = {"ok": "✅", "skip": "⏭️", "fail": "❌"}.get(status_class, "❓")
        img_tag = f"<img src='{r['url']}'>" if r.get("url") else "<div style='height:180px;background:#eee;display:flex;align-items:center;justify-content:center;color:#999'>No image</div>"
        html_parts.append(
            f"<div class='card {status_class}'>"
            f"{img_tag}"
            f"<div class='info'>"
            f"<div class='word'>{status_icon} {r['word']}</div>"
            f"<div class='status'>{r.get('message', '')}</div>"
            f"</div></div>"
        )

    html_parts.append("</div></body></html>")

    review_path = os.path.join(ASSETS_DIR, "review.html")
    with open(review_path, "w", encoding="utf-8") as f:
        f.write("\n".join(html_parts))
    print(f"\n📄 Mở file review.html để xem kết quả: {review_path}")


# ============================================================
# Main
# ============================================================

def main():
    check_prerequisites()

    import firebase_admin
    from firebase_admin import credentials, firestore

    # Init Firebase (chỉ dùng Firestore, không cần Storage)
    print("🔌 Kết nối Firebase Firestore...")
    cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("   ✅ Đã kết nối Firestore")

    # Build word → docId mapping
    word_to_docid = build_word_to_docid()
    print(f"   📝 Map từ vựng: {len(word_to_docid)} mục")

    # Duyệt ảnh trong thư mục
    image_files = sorted(
        f for f in os.listdir(IMAGES_DIR)
        if f.lower().endswith((".jpg", ".jpeg", ".png"))
    )
    print(f"\n📥 Tìm thấy {len(image_files)} ảnh trong vocab_images/")
    print("-" * 60)

    results = []
    uploaded = 0
    skipped = 0
    failed = 0

    for filename in image_files:
        filepath = os.path.join(IMAGES_DIR, filename)

        # Lấy tên từ từ filename (bỏ đuôi .jpg/.png)
        word_from_file = os.path.splitext(filename)[0].replace("_", " ")

        # Tìm docId trong Firestore
        doc_id = word_to_docid.get(word_from_file.lower())

        if doc_id is None:
            print(f"  ⚠ [{filename}] Không tìm thấy từ '{word_from_file}' trong Firestore → bỏ qua")
            results.append({"word": word_from_file, "status": "skip", "url": None, "message": "Không có trong Firestore"})
            skipped += 1
            continue

        # Kiểm tra xem doc có tồn tại trong Firestore không
        doc_ref = db.collection("vocabularies").document(doc_id)
        doc = doc_ref.get()

        if not doc.exists:
            print(f"  ⚠ [{filename}] Document '{doc_id}' chưa tồn tại trong Firestore → bỏ qua")
            results.append({"word": word_from_file, "status": "skip", "url": None, "message": f"Doc {doc_id} chưa tồn tại"})
            skipped += 1
            continue

        # Kiểm tra đã có imageUrl chưa
        existing_url = doc.to_dict().get("imageUrl", "")
        if existing_url and existing_url.startswith("http"):
            print(f"  ⏭  [{filename}] Đã có imageUrl → bỏ qua")
            results.append({"word": word_from_file, "status": "skip", "url": existing_url, "message": "Đã có ảnh"})
            skipped += 1
            continue

        # Upload lên ImgBB
        print(f"  📤 [{filename}] Đang upload...", end=" ")
        sys.stdout.flush()

        try:
            image_url = upload_to_imgbb(filepath)

            if image_url is None:
                print("❌")
                results.append({"word": word_from_file, "status": "fail", "url": None, "message": "Upload ImgBB thất bại"})
                failed += 1
                continue

            # Cập nhật Firestore
            doc_ref.update({"imageUrl": image_url})

            size_kb = os.path.getsize(filepath) // 1024
            print(f"✅ ({size_kb} KB)")
            print(f"       → {image_url}")
            results.append({"word": word_from_file, "status": "ok", "url": image_url, "message": f"{size_kb} KB"})
            uploaded += 1

            # Delay tránh rate limit ImgBB
            time.sleep(1.0)

        except Exception as e:
            print(f"❌")
            print(f"       Lỗi: {e}")
            results.append({"word": word_from_file, "status": "fail", "url": None, "message": str(e)})
            failed += 1

    # Tổng kết
    print("-" * 60)
    print(f"\n🎉 Hoàn thành!")
    print(f"   ✅ Upload thành công: {uploaded}")
    print(f"   ⏭  Bỏ qua: {skipped}")
    print(f"   ❌ Lỗi: {failed}")
    print(f"\n📱 Giờ chạy Flutter app — ảnh sẽ hiển thị qua Image.network(url)!")

    # Tạo file review
    generate_review_html(results)


if __name__ == "__main__":
    main()
