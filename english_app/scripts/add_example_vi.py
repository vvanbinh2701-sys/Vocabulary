"""
Thêm bản dịch tiếng Việt cho example sentences vào Firestore.
"""
from firebase_admin import credentials, firestore, initialize_app

cred = credentials.Certificate('scripts/service_account.json')
initialize_app(cred)
db = firestore.client()

# Map: docId -> bản dịch tiếng Việt của example
example_translations = {
    'v1': 'Tôi yêu gia đình tôi.',
    'v2': 'Mẹ tôi là giáo viên.',
    'v3': 'Bố tôi làm việc chăm chỉ.',
    'v4': 'Tôi có hai anh chị em.',
    'v4_1': 'Ông tôi bảy mươi tuổi.',
    'v5': 'Tôi ăn một quả táo mỗi ngày.',
    'v6': 'Chúng tôi ăn cơm vào bữa tối.',
    'v7': 'Tôi thích mì bò.',
    'v7_1': 'Tôi muốn ăn bánh mì.',
    'v7_2': 'Pizza này có thêm phô mai.',
    'v8': 'Tôi muốn đi du lịch vòng quanh thế giới.',
    'v9': 'Sân bay hôm nay rất đông.',
    'v10': 'Đừng quên hộ chiếu của bạn.',
    'v10_1': 'Vui lòng giữ hành lý bên cạnh bạn.',
    'v10_2': 'Chúng tôi đã đặt một phòng tại khách sạn.',
    'v11': 'Tôi đi học mỗi ngày.',
    'v12': 'Giáo viên thật tốt bụng.',
    'v13': 'Tôi đã làm xong bài tập về nhà.',
    'v13_1': 'Cậu ấy là bạn cùng lớp yêu thích của tôi.',
    'v13_2': 'Tôi học trong thư viện.',
    'v14_1': 'Bác sĩ đã cho tôi một ít thuốc.',
    'v14_2': 'Anh ấy muốn trở thành kỹ sư phần mềm.',
    'v14_3': 'Cô ấy là một họa sĩ tài năng.',
    'v14_4': 'Phi công đã lái máy bay an toàn.',
    'v14_5': 'Đầu bếp đã chuẩn bị một bữa tối ngon lành.',
    'v15_1': 'Sư tử là vua của rừng xanh.',
    'v15_2': 'Voi là động vật trên cạn lớn nhất.',
    'v15_3': 'Con khỉ đang trèo cây.',
    'v15_4': 'Con thỏ trắng ăn cà rốt.',
    'v15_5': 'Cá heo là loài động vật thông minh.',
}

print(f'📝 Đang cập nhật {len(example_translations)} bản dịch...')
print()

updated = 0
for doc_id, vi_text in example_translations.items():
    doc_ref = db.collection('vocabularies').document(doc_id)
    doc = doc_ref.get()
    if doc.exists:
        doc_ref.update({'exampleVi': vi_text})
        word = doc.to_dict().get('word', 'N/A')
        print(f'   ✅ {doc_id} ({word}): {vi_text}')
        updated += 1
    else:
        print(f'   ⚠ Không tìm thấy: {doc_id}')

print()
print(f'🎉 Hoàn thành! Đã cập nhật {updated}/{len(example_translations)} documents.')
