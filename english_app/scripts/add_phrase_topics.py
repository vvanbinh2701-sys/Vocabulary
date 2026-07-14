"""
Thêm 3 chủ đề mới cho mục Học Câu + các phrase items tương ứng.
"""
from firebase_admin import credentials, firestore, initialize_app

cred = credentials.Certificate('scripts/service_account.json')
initialize_app(cred)
db = firestore.client()

# ----- 3 chủ đề mới -----
new_topics = [
    {"id": "phrase_polite", "categoryId": "phrase", "title": "Giao tiếp lịch sự", "icon": "🤝", "itemCount": 4},
    {"id": "phrase_opinion", "categoryId": "phrase", "title": "Đồng ý & Phản đối", "icon": "👍", "itemCount": 4},
    {"id": "phrase_info", "categoryId": "phrase", "title": "Hỏi thông tin", "icon": "❓", "itemCount": 4},
]

# ----- Các phrase items cho từng chủ đề -----
new_phrases = [
    # Giao tiếp lịch sự (phrase_polite)
    {"id": "p6_1", "word": "Excuse me, could you help me?", "meaning": "Xin lỗi, bạn có thể giúp tôi được không?", "pronunciation": "", "example": "Câu hỏi lịch sự nhờ giúp đỡ.", "category": "phrase", "topicId": "phrase_polite", "masteryLevel": "Mới"},
    {"id": "p6_2", "word": "I'm sorry for the inconvenience.", "meaning": "Tôi xin lỗi vì sự bất tiện này.", "pronunciation": "", "example": "Xin lỗi khi làm phiền người khác.", "category": "phrase", "topicId": "phrase_polite", "masteryLevel": "Mới"},
    {"id": "p6_3", "word": "Thank you in advance.", "meaning": "Cảm ơn bạn trước nhé.", "pronunciation": "", "example": "Cảm ơn trước khi ai đó làm gì cho mình.", "category": "phrase", "topicId": "phrase_polite", "masteryLevel": "Mới"},
    {"id": "p6_4", "word": "After you.", "meaning": "Mời bạn đi trước.", "pronunciation": "", "example": "Nhường người khác đi trước (cửa, thang máy...).", "category": "phrase", "topicId": "phrase_polite", "masteryLevel": "Mới"},

    # Đồng ý & Phản đối (phrase_opinion)
    {"id": "p7_1", "word": "I couldn't agree more.", "meaning": "Tôi hoàn toàn đồng ý.", "pronunciation": "", "example": "Nhấn mạnh sự đồng tình.", "category": "phrase", "topicId": "phrase_opinion", "masteryLevel": "Mới"},
    {"id": "p7_2", "word": "That's a good point, but...", "meaning": "Ý kiến hay đấy, nhưng...", "pronunciation": "", "example": "Phản đối một cách lịch sự.", "category": "phrase", "topicId": "phrase_opinion", "masteryLevel": "Mới"},
    {"id": "p7_3", "word": "I see what you mean.", "meaning": "Tôi hiểu ý bạn.", "pronunciation": "", "example": "Thể hiện sự thấu hiểu quan điểm.", "category": "phrase", "topicId": "phrase_opinion", "masteryLevel": "Mới"},
    {"id": "p7_4", "word": "I'm afraid I disagree.", "meaning": "Tôi e rằng tôi không đồng ý.", "pronunciation": "", "example": "Phản đối lịch sự, tế nhị.", "category": "phrase", "topicId": "phrase_opinion", "masteryLevel": "Mới"},

    # Hỏi thông tin (phrase_info)
    {"id": "p8_1", "word": "Could you tell me more about it?", "meaning": "Bạn có thể cho tôi biết thêm về điều đó không?", "pronunciation": "", "example": "Hỏi chi tiết về một vấn đề.", "category": "phrase", "topicId": "phrase_info", "masteryLevel": "Mới"},
    {"id": "p8_2", "word": "Do you happen to know...?", "meaning": "Bạn có tình cờ biết...?", "pronunciation": "", "example": "Hỏi thông tin một cách lịch sự.", "category": "phrase", "topicId": "phrase_info", "masteryLevel": "Mới"},
    {"id": "p8_3", "word": "I'd like to know more details.", "meaning": "Tôi muốn biết thêm chi tiết.", "pronunciation": "", "example": "Yêu cầu thông tin bổ sung.", "category": "phrase", "topicId": "phrase_info", "masteryLevel": "Mới"},
    {"id": "p8_4", "word": "What does that mean exactly?", "meaning": "Chính xác thì điều đó có nghĩa là gì?", "pronunciation": "", "example": "Hỏi lại khi không hiểu rõ.", "category": "phrase", "topicId": "phrase_info", "masteryLevel": "Mới"},
]

# ----- Thêm topics -----
print('📝 Đang thêm chủ đề...')
for t in new_topics:
    doc_ref = db.collection('topics').document(t['id'])
    if not doc_ref.get().exists:
        data = {k: v for k, v in t.items() if k != 'id'}
        doc_ref.set(data)
        print(f'   ✅ Topic: {t["title"]} ({t["id"]})')
    else:
        print(f'   ⏭  Topic: {t["title"]} - đã tồn tại')

print()

# ----- Thêm phrases -----
print('📝 Đang thêm phrase items...')
for p in new_phrases:
    doc_ref = db.collection('vocabularies').document(p['id'])
    if not doc_ref.get().exists:
        data = {k: v for k, v in p.items() if k != 'id'}
        doc_ref.set(data)
        print(f'   ✅ {p["id"]} ({p["word"]})')
    else:
        print(f'   ⏭  {p["id"]} ({p["word"]}) - đã tồn tại')

print()
print('🎉 Hoàn thành! Đã thêm 3 chủ đề + 12 phrase mới!')
