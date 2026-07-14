import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static final List<_FaqItem> _faqs = [
    const _FaqItem(
      question: 'Làm thế nào để đăng ký?',
      answer:
          'Mở ứng dụng và nhấn "Đăng ký". Nhập tên, địa chỉ email và mật khẩu của bạn. Một email xác nhận sẽ được gửi đến địa chỉ email của bạn. Nhấp vào liên kết trong email để xác minh tài khoản, sau đó đăng nhập để bắt đầu học.'
    ),
    const _FaqItem(
      question: 'Làm thế nào để đặt lại mật khẩu?',
      answer:
          'Trên màn hình đăng nhập, nhấn "Quên mật khẩu". Nhập địa chỉ email bạn đã đăng ký. Chúng tôi sẽ gửi cho bạn một liên kết đặt lại mật khẩu. Mở liên kết và làm theo hướng dẫn để tạo mật khẩu mới.'
    ),
    const _FaqItem(
      question: 'Tại sao tôi không nhận được email xác nhận?',
      answer:
          'Vui lòng kiểm tra thư mục Spam hoặc Rác. Đảm bảo bạn đã nhập đúng địa chỉ email. Nếu vẫn không tìm thấy, bạn có thể yêu cầu gửi lại email xác nhận từ cài đặt ứng dụng. Cũng hãy kiểm tra hộp thư đến của bạn không bị đầy.'
    ),
    const _FaqItem(
      question: 'Làm thế nào để thay đổi ảnh đại diện?',
      answer:
          'Vào màn hình Hồ sơ và nhấn vào ảnh đại diện hoặc nút chỉnh sửa. Bạn sẽ thấy danh sách các ảnh đại diện có sẵn. Chọn ảnh bạn thích và nó sẽ được lưu tự động.'
    ),
    const _FaqItem(
      question: 'Làm thế nào để lưu tiến độ học tập?',
      answer:
          'Tiến độ của bạn được tự động lưu vào tài khoản khi bạn hoàn thành bài học, câu đố và bài tập. Hãy đảm bảo bạn đã đăng nhập và có kết nối internet. Bạn có thể xem lại tiến độ bất cứ lúc nào từ màn hình Hồ sơ và Tiến độ.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.help_outline, color: AppColors.primaryGreen),
                    SizedBox(width: 10),
                    Text(
                      'Câu hỏi thường gặp',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tìm câu trả lời cho các câu hỏi thường gặp bên dưới.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.cardBorder),
                const SizedBox(height: 8),
                ..._faqs.map(
                  (faq) => _FaqExpansionTile(faq: faq),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqExpansionTile extends StatelessWidget {
  final _FaqItem faq;

  const _FaqExpansionTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.background,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            iconColor: AppColors.primaryGreen,
            collapsedIconColor: AppColors.textGrey,
            expandedAlignment: Alignment.centerLeft,
            childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        ),
        child: ExpansionTile(
          title: Text(
            faq.question,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
          children: [
            Text(
              faq.answer,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });
}
