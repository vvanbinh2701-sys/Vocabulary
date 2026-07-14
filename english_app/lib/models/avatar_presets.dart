import 'package:flutter/material.dart';

/// Một avatar mẫu có sẵn, gồm biểu tượng (emoji) và màu nền.
class PresetAvatar {
  final String id;
  final String emoji;
  final Color color;
  final String label;

  const PresetAvatar({
    required this.id,
    required this.emoji,
    required this.color,
    required this.label,
  });
}

/// Danh sách các avatar có sẵn cho người dùng chọn.
const List<PresetAvatar> presetAvatars = [
  PresetAvatar(id: 'cat', emoji: '🐱', color: Color(0xFF58CC02), label: 'Mèo'),
  PresetAvatar(id: 'dog', emoji: '🐶', color: Color(0xFFFF9600), label: 'Chó'),
  PresetAvatar(id: 'fox', emoji: '🦊', color: Color(0xFFFF4B4B), label: 'Cáo'),
  PresetAvatar(id: 'panda', emoji: '🐼', color: Color(0xFF3C3C3C), label: 'Gấu trúc'),
  PresetAvatar(id: 'lion', emoji: '🦁', color: Color(0xFFFFC800), label: 'Sư tử'),
  PresetAvatar(id: 'frog', emoji: '🐸', color: Color(0xFF58CC02), label: 'Ếch'),
  PresetAvatar(id: 'rabbit', emoji: '🐰', color: Color(0xFFCE82FF), label: 'Thỏ'),
  PresetAvatar(id: 'owl', emoji: '🦉', color: Color(0xFF1CB0F6), label: 'Cú'),
  PresetAvatar(id: 'star', emoji: '⭐', color: Color(0xFFFFC800), label: 'Sao'),
  PresetAvatar(id: 'rainbow', emoji: '🌈', color: Color(0xFFCE82FF), label: 'Cầu vồng'),
  PresetAvatar(id: 'music', emoji: '🎵', color: Color(0xFF1CB0F6), label: 'Nhạc'),
  PresetAvatar(id: 'sunflower', emoji: '🌻', color: Color(0xFFFF9600), label: 'Hoa'),
  PresetAvatar(id: 'turtle', emoji: '🐢', color: Color(0xFF58CC02), label: 'Rùa'),
  PresetAvatar(id: 'butterfly', emoji: '🦋', color: Color(0xFFCE82FF), label: 'Bướm'),
  PresetAvatar(id: 'penguin', emoji: '🐧', color: Color(0xFF1CB0F6), label: 'Chim cánh cụt'),
  PresetAvatar(id: 'unicorn', emoji: '🦄', color: Color(0xFFCE82FF), label: 'Kỳ lân'),
];

/// Lấy thông tin preset avatar theo id, trả về null nếu không tìm thấy.
PresetAvatar? getAvatarById(String? id) {
  if (id == null) return null;
  try {
    return presetAvatars.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
}
