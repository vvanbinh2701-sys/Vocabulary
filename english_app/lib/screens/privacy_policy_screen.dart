import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chính sách bảo mật')),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.privacy_tip_outlined,
                        color: AppColors.primaryGreen),
                    SizedBox(width: 10),
                    Text(
                      'Chính sách bảo mật',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(height: 1, color: AppColors.cardBorder),
                SizedBox(height: 16),
                Text(
                  'Cập nhật lần cuối: Tháng 7, 2026',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 20),
                _SectionTitle(title: '1. Thông tin chúng tôi thu thập'),
                SizedBox(height: 8),
                _BodyText(
                  text:
                      'Chúng tôi thu thập thông tin bạn cung cấp khi tạo tài khoản, bao gồm tên, địa chỉ email và ảnh đại diện. Chúng tôi cũng thu thập dữ liệu tiến độ học tập như bài học đã hoàn thành, điểm số câu đố và sở thích từ vựng để cá nhân hóa trải nghiệm của bạn.',
                ),
                SizedBox(height: 20),
                _SectionTitle(title: '2. Cách chúng tôi sử dụng thông tin của bạn'),
                SizedBox(height: 8),
                _BodyText(
                  text:
                      'Thông tin của bạn được sử dụng để cung cấp và cải thiện trải nghiệm học tập, theo dõi tiến độ của bạn, gửi thông báo và liên lạc với bạn về các yêu cầu hỗ trợ. Chúng tôi không bán hoặc chia sẻ dữ liệu cá nhân của bạn với bên thứ ba cho mục đích tiếp thị.',
                ),
                SizedBox(height: 20),
                _SectionTitle(title: '3. Lưu trữ và bảo mật dữ liệu'),
                SizedBox(height: 8),
                _BodyText(
                  text:
                      'Dữ liệu của bạn được lưu trữ an toàn bằng dịch vụ Firebase với mã hóa trong quá trình truyền tải và lưu trữ. Chúng tôi áp dụng các biện pháp bảo mật tiêu chuẩn ngành để bảo vệ thông tin cá nhân của bạn khỏi truy cập trái phép, thay đổi hoặc tiết lộ.',
                ),
                SizedBox(height: 20),
                _SectionTitle(title: '4. Dịch vụ bên thứ ba'),
                SizedBox(height: 8),
                _BodyText(
                  text:
                      'Chúng tôi sử dụng Firebase (Google) cho dịch vụ xác thực, cơ sở dữ liệu và lưu trữ. Gemini AI được sử dụng để tạo nội dung học tập. Các dịch vụ này có chính sách bảo mật riêng điều chỉnh các hoạt động xử lý dữ liệu.',
                ),
                SizedBox(height: 20),
                _SectionTitle(title: '5. Quyền của bạn'),
                SizedBox(height: 8),
                _BodyText(
                  text:
                      'Bạn có thể truy cập, cập nhật hoặc xóa thông tin tài khoản của mình bất kỳ lúc nào thông qua cài đặt ứng dụng. Bạn cũng có thể liên hệ với chúng tôi để yêu cầu xóa dữ liệu hoặc xuất dữ liệu cá nhân của mình.',
                ),
                SizedBox(height: 20),
                _SectionTitle(title: '6. Liên hệ chúng tôi'),
                SizedBox(height: 8),
                _BodyText(
                  text:
                      'Nếu bạn có bất kỳ câu hỏi nào về Chính sách bảo mật này, vui lòng liên hệ với chúng tôi qua địa chỉ vvanbinh2701@gmail.com.',
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;

  const _BodyText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textDark,
        height: 1.6,
      ),
    );
  }
}
