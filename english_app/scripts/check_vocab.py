"""
Kiểm tra Firestore: chỉ còn từ vựng vocab có ảnh.
"""
from firebase_admin import credentials, firestore, initialize_app

cred = credentials.Certificate('scripts/service_account.json')
initialize_app(cred)
db = firestore.client()

docs = list(db.collection('vocabularies').stream())
print(f'📊 Tổng số document còn lại: {len(docs)}')
print()
for doc in docs:
    d = doc.to_dict()
    word = d.get('word', '?')
    has_img = bool(d.get('imageUrl', ''))
    icon = '✅' if has_img else '❌'
    print(f'   {icon} {doc.id}: {word}')
