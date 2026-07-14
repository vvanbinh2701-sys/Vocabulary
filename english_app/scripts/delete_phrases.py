"""
Xóa các document conversation/phrase khỏi Firestore collection 'vocabularies'.
"""
from firebase_admin import credentials, firestore, initialize_app

cred = credentials.Certificate('scripts/service_account.json')
initialize_app(cred)
db = firestore.client()

# Các ID cần xóa (conversation & phrase items)
ids_to_delete = ['c1', 'c2', 'c3', 'c4', 'c5',
                 'p1', 'p2', 'p2_1', 'p2_2',
                 'p3', 'p4', 'p4_1', 'p4_2',
                 'p5_1', 'p5_2', 'p5_3', 'p5_4']

print(f'🗑️  Chuẩn bị xóa {len(ids_to_delete)} documents...')
print()

deleted = 0
for doc_id in ids_to_delete:
    doc_ref = db.collection('vocabularies').document(doc_id)
    doc = doc_ref.get()
    if doc.exists:
        word = doc.to_dict().get('word', 'N/A')
        doc_ref.delete()
        print(f'   ✅ Đã xóa: {doc_id} - "{word}"')
        deleted += 1
    else:
        print(f'   ⚠ Không tồn tại: {doc_id}')

print()
print(f'🎉 Hoàn thành! Đã xóa {deleted} documents.')
