"""
Script upload ảnh từ vựng lên Firebase Storage + cập nhật Firestore.

Pipeline:
  assets/vocab_images/*.jpg|.png
      │
      ▼
  Firebase Storage  (vocab_images/{docId}.jpg)
      │
      ▼
  Lấy download URL
      │
      ▼
  Firestore: vocabularies/{docId}.imageUrl = URL

Chuẩn bị:
  1. Tải Service Account Key từ Firebase Console:
     Project settings → Service accounts → Generate new private key
  2. Đặt file JSON vào: english_app/scripts/service_account.json

Cách chạy:
  pip install firebase-admin
  python english_app/scripts/upload_to_firebase.py
"""

import os
import sys
import time
import json

# ============================================================
# Đường dẫn
# ============================================================
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
ASSETS_DIR = os.path.join(PROJECT_DIR, "assets")
IMAGES_DIR = os.path.join(ASSETS_DIR, "vocab_images")
SERVICE_ACCOUNT_FILE = os.path.join(SCRIPT_DIR, "service_account.json")
FIRESTORE_DATA_FILE = os.path.join(ASSETS_DIR, "firebase_seed", "firestore_data.json")

# Storage bucket – lấy từ Firebase Console (Storage → Files → gs://...)
# Bạn có thể ghi đè bằng biến môi trường STORAGE_BUCKET
STORAGE_BUCKET = os.environ.get("STORAGE_BUCKET", "")


# ============================================================
# Kiểm tra prerequisites
# ============================================================

def check_prerequisites():
    if not os.path.exists(SERVICE_ACCOUNT_FILE):
        print("❌ Không tìm thấy service_account.json!")
        print(f"   Đặt file vào: {SERVICE_ACCOUNT_FILE}")
        print("   Hướng dẫn: Firebase Console → Project settings → Service accounts → Generate new private key")
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
# Main
# ============================================================

def main():
    check_prerequisites()

    import firebase_admin
    from firebase_admin import credentials, storage, firestore

    # Init Firebase
    print("🔌 Kết nối Firebase...")
    cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)

    # Lấy storageBucket từ service account hoặc cấu hình
    with open(SERVICE_ACCOUNT_FILE, "r") as f:
        sa = json.load(f)
    bucket_name = STORAGE_BUCKET or sa.get("project_id", "") + ".appspot.com"

    firebase_admin.initialize_app(cred, {
        "storageBucket": bucket_name,
    })

    db = firestore.client()
    bucket = storage.bucket()

    print(f"   Bucket: {bucket_name}")

    # Build word → docId mapping
    word_to_docid = build_word_to_docid()
    print(f"   Map từ vựng: {len(word_to_docid)} mục")

    # Duyệt ảnh trong thư mục
    image_files = sorted(
        f for f in os.listdir(IMAGES_DIR)
        if f.lower().endswith((".jpg", ".jpeg", ".png"))
    )
    print(f"\n📥 Tìm thấy {len(image_files)} ảnh trong vocab_images/")
    print("-" * 55)

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
            print(f"  ⚠ [{filename}] Không tìm thấy từ '{word_from_file}' trong firestore_data.json → dùng tên file làm docId")
            doc_id = word_from_file.lower().replace(" ", "_")

        # Kiểm tra xem doc có tồn tại trong Firestore không
        doc_ref = db.collection("vocabularies").document(doc_id)
        doc = doc_ref.get()

        if not doc.exists:
            print(f"  ⚠ [{filename}] Document '{doc_id}' chưa tồn tại trong Firestore → bỏ qua")
            skipped += 1
            continue

        # Kiểm tra đã có imageUrl chưa
        existing_url = doc.to_dict().get("imageUrl", "")
        if existing_url and existing_url.startswith("http"):
            print(f"  ⏭  [{filename}] Đã có imageUrl → bỏ qua")
            skipped += 1
            continue

        try:
            # Upload lên Storage
            storage_path = f"vocab_images/{doc_id}.jpg"
            blob = bucket.blob(storage_path)

            # Xác định content type
            content_type = "image/png" if filename.endswith(".png") else "image/jpeg"

            blob.upload_from_filename(filepath, content_type=content_type)
            blob.make_public()  # Cho phép đọc công khai

            download_url = blob.public_url
            # public_url dùng dạng https://storage.googleapis.com/bucket/path

            # Cập nhật Firestore
            doc_ref.update({"imageUrl": download_url})

            size_kb = os.path.getsize(filepath) // 1024
            print(f"  ✅ [{filename}] → {download_url[:60]}... ({size_kb} KB)")
            uploaded += 1

            # Delay nhẹ tránh rate limit
            time.sleep(0.3)

        except Exception as e:
            print(f"  ❌ [{filename}] Lỗi: {e}")
            failed += 1

    # Tổng kết
    print("-" * 55)
    print(f"\n🎉 Hoàn thành!")
    print(f"   ✅ Upload thành công: {uploaded}")
    print(f"   ⏭  Bỏ qua (đã có/cần thủ công): {skipped}")
    print(f"   ❌ Lỗi: {failed}")
    print(f"\n📱 Giờ mở Flutter app lên — ảnh sẽ hiển thị qua Image.network(url)!\n")


if __name__ == "__main__":
    main()
