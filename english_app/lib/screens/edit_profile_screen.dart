import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/avatar_presets.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  String? _selectedAvatarId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _nameCtrl = TextEditingController(text: app.userName);
    _phoneCtrl = TextEditingController(text: app.userPhone ?? '');
    _selectedAvatarId = app.avatarId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context.read<AppState>().updateUserProfile(
            name: _nameCtrl.text,
            phone: _phoneCtrl.text,
            newAvatarId: _selectedAvatarId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật thông tin thành công!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final selectedAvatar = getAvatarById(_selectedAvatarId);

    return Scaffold(
      appBar: AppBar(title: const Text('Cập nhật thông tin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Avatar hiện tại ----
            Center(
              child: GestureDetector(
                onTap: () => _showAvatarPicker(),
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: selectedAvatar != null
                            ? selectedAvatar.color.withValues(alpha: 0.15)
                            : AppColors.primaryGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedAvatar?.color ?? AppColors.primaryGreen,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          selectedAvatar?.emoji ?? '👤',
                          style: const TextStyle(fontSize: 44),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Chạm để đổi avatar',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ---- Họ và tên ----
            const Text(
              'Họ và tên',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: 'Nhập tên của bạn',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---- Số điện thoại ----
            const Text(
              'Số điện thoại',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Nhập số điện thoại',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ---- Nút Lưu ----
            DuoButton(
              label: _saving ? 'Đang lưu...' : 'LƯU THAY ĐỔI',
              color: AppColors.primaryGreen,
              shadowColor: AppColors.darkGreen,
              onTap: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chọn avatar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                // Grid cuộn được, chiếm không gian còn lại
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: presetAvatars.length,
                    itemBuilder: (context, index) {
                      final avatar = presetAvatars[index];
                      final isSelected = avatar.id == _selectedAvatarId;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedAvatarId = avatar.id);
                          Navigator.pop(sheetContext);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: avatar.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? avatar.color
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(avatar.emoji,
                                style: const TextStyle(fontSize: 32)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Chọn biểu tượng bạn yêu thích',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
