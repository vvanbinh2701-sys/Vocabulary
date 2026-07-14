from firebase_admin import credentials, firestore, initialize_app

cred = credentials.Certificate('scripts/service_account.json')
initialize_app(cred)
db = firestore.client()

docs = list(db.collection('vocabularies').stream())
all_ok = True
for doc in docs:
    d = doc.to_dict()
    word = d.get('word', '?')
    evi = d.get('exampleVi', '')
    if not evi:
        print(f'❌ {doc.id} ({word}): thiếu exampleVi')
        all_ok = False
    else:
        print(f'✅ {doc.id} ({word}): {evi}')

if all_ok:
    print(f'\n🎉 Tất cả {len(docs)} từ đều đã có exampleVi!')
