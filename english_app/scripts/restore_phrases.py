"""
Khôi phục dữ liệu phrase vào Firestore collection 'vocabularies'.
Chỉ khôi phục các phrase (p1-p5_4), không khôi phục conversation.
"""
from firebase_admin import credentials, firestore, initialize_app

cred = credentials.Certificate('scripts/service_account.json')
initialize_app(cred)
db = firestore.client()

phrases = [
    {"id": "p1", "word": "Take it easy.", "meaning": "Thư giãn đi / Đừng lo lắng.", "pronunciation": "", "example": "Mẫu câu an ủi.", "category": "phrase", "topicId": "phrase_daily", "masteryLevel": "Mới"},
    {"id": "p2", "word": "It depends.", "meaning": "Còn tuỳ.", "pronunciation": "", "example": "Dùng khi chưa chắc chắn.", "category": "phrase", "topicId": "phrase_daily", "masteryLevel": "Mới"},
    {"id": "p2_1", "word": "Long time no see.", "meaning": "Lâu rồi không gặp.", "pronunciation": "", "example": "Dùng khi gặp lại người quen.", "category": "phrase", "topicId": "phrase_daily", "masteryLevel": "Mới"},
    {"id": "p2_2", "word": "Have a nice day.", "meaning": "Chúc một ngày tốt lành.", "pronunciation": "", "example": "Mẫu câu chúc xã giao.", "category": "phrase", "topicId": "phrase_daily", "masteryLevel": "Mới"},
    {"id": "p3", "word": "I am on my way.", "meaning": "Tôi đang trên đường tới.", "pronunciation": "", "example": "Thông báo đang di chuyển.", "category": "phrase", "topicId": "phrase_work", "masteryLevel": "Mới"},
    {"id": "p4", "word": "Let's get started.", "meaning": "Hãy bắt đầu thôi.", "pronunciation": "", "example": "Mở đầu cuộc họp.", "category": "phrase", "topicId": "phrase_work", "masteryLevel": "Mới"},
    {"id": "p4_1", "word": "Please keep me updated.", "meaning": "Xin vui lòng cập nhật tình hình cho tôi.", "pronunciation": "", "example": "Dùng khi muốn theo dõi tiến độ.", "category": "phrase", "topicId": "phrase_work", "masteryLevel": "Mới"},
    {"id": "p4_2", "word": "Let's call it a day.", "meaning": "Hôm nay nghỉ ở đây nhé.", "pronunciation": "", "example": "Dùng khi kết thúc công việc trong ngày.", "category": "phrase", "topicId": "phrase_work", "masteryLevel": "Mới"},
    {"id": "p5_1", "word": "Help me, please!", "meaning": "Làm ơn giúp tôi với!", "pronunciation": "", "example": "Kêu gọi trợ giúp khẩn cấp.", "category": "phrase", "topicId": "phrase_emergency", "masteryLevel": "Mới"},
    {"id": "p5_2", "word": "Call an ambulance!", "meaning": "Hãy gọi xe cứu thương!", "pronunciation": "", "example": "Yêu cầu y tế khẩn cấp.", "category": "phrase", "topicId": "phrase_emergency", "masteryLevel": "Mới"},
    {"id": "p5_3", "word": "I lost my passport.", "meaning": "Tôi đã làm mất hộ chiếu.", "pronunciation": "", "example": "Khai báo mất giấy tờ.", "category": "phrase", "topicId": "phrase_emergency", "masteryLevel": "Mới"},
    {"id": "p5_4", "word": "Where is the police station?", "meaning": "Đồn cảnh sát ở đâu?", "pronunciation": "", "example": "Hỏi đường khi gặp sự cố.", "category": "phrase", "topicId": "phrase_emergency", "masteryLevel": "Mới"},
]

print(f'📝 Đang khôi phục {len(phrases)} phrase items...')
print()

added = 0
for p in phrases:
    doc_ref = db.collection('vocabularies').document(p['id'])
    doc = doc_ref.get()
    if doc.exists:
        print(f'   ⏭  {p["id"]} ({p["word"]}) - đã tồn tại, bỏ qua')
    else:
        data = {k: v for k, v in p.items() if k != 'id'}
        doc_ref.set(data)
        print(f'   ✅ {p["id"]} ({p["word"]}) - đã khôi phục')
        added += 1

print()
print(f'🎉 Hoàn thành! Đã khôi phục {added} phrase items.')
