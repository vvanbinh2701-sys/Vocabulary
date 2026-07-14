"""
Script set role Admin cho tài khoản trong Firestore.

Cách dùng:
  1. Đảm bảo file service_account.json đã có trong thư mục scripts/
  2. Chạy:  python scripts/set_admin.py <email_của_user>
  
  Ví dụ:  python scripts/set_admin.py admin@example.com
"""

import os
import sys
import firebase_admin
from firebase_admin import credentials, firestore

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SERVICE_ACCOUNT_FILE = os.path.join(SCRIPT_DIR, "service_account.json")

if not os.path.exists(SERVICE_ACCOUNT_FILE):
    print("❌ Không tìm thấy service_account.json")
    print("   Vào Firebase Console → Project settings → Service accounts → Generate new private key")
    print("   Rồi đặt file JSON vào: english_app/scripts/service_account.json")
    sys.exit(1)

# Khởi tạo Firebase Admin
try:
    cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("✅ Đã kết nối Firebase")
except Exception as e:
    print(f"❌ Lỗi kết nối: {e}")
    # Có thể đã khởi tạo trước đó
    db = firestore.client()

def set_admin_by_email(email: str):
    """Tìm user theo email và set role = admin"""
    users_ref = db.collection("users")
    
    # Tìm user theo email
    docs = users_ref.where("email", "==", email).limit(1).stream()
    docs_list = list(docs)
    
    if not docs_list:
        print(f"❌ Không tìm thấy user với email: {email}")
        print("   Hãy đăng ký tài khoản trước, hoặc kiểm tra lại email.")
        return False
    
    doc = docs_list[0]
    uid = doc.id
    
    # Set role admin
    users_ref.document(uid).update({"role": "admin"})
    print(f"✅ Đã set role ADMIN cho user:")
    print(f"   UID:   {uid}")
    print(f"   Email: {email}")
    print(f"   Role:  admin")
    return True

def set_admin_by_uid(uid: str):
    """Set role admin trực tiếp bằng UID"""
    users_ref = db.collection("users")
    users_ref.document(uid).set({"role": "admin"}, merge=True)
    print(f"✅ Đã set role ADMIN cho UID: {uid}")
    return True

def list_all_users():
    """Liệt kê tất cả users"""
    users_ref = db.collection("users")
    docs = users_ref.stream()
    print("\n📋 Danh sách users:")
    print("-" * 60)
    for doc in docs:
        data = doc.data()
        role = data.get("role", "user")
        email = data.get("email", "N/A")
        name = data.get("name", data.get("displayName", "N/A"))
        badge = "👑 ADMIN" if role == "admin" else "👤 USER"
        print(f"  {badge} | {email} | {name}")
    print("-" * 60)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Cách dùng:")
        print("  python set_admin.py <email>       - Set admin theo email")
        print("  python set_admin.py --uid <uid>           - Set admin theo UID")
        print("  python set_admin.py --list                - Liệt kê tất cả users")
        sys.exit(0)
    
    if sys.argv[1] == "--list":
        list_all_users()
    elif sys.argv[1] == "--uid" and len(sys.argv) >= 3:
        set_admin_by_uid(sys.argv[2])
    else:
        set_admin_by_email(sys.argv[1])
