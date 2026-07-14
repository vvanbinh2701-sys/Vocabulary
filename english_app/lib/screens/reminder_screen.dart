import 'package:flutter/material.dart';

import '../main.dart';
import '../theme/app_theme.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 0);
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final data = await notificationService.loadReminder();
    if (!mounted) return;
    setState(() {
      _enabled = data['enabled'] as bool;
      _time = TimeOfDay(hour: data['hour'] as int, minute: data['minute'] as int);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _time = picked);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await notificationService.saveReminder(
        enabled: _enabled,
        hour: _time.hour,
        minute: _time.minute,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu cài đặt nhắc nhở!')),
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

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo nhắc nhở')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ---- Bật/tắt nhắc nhở ----
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_outlined,
                      color: AppColors.textDark),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Bật nhắc nhở',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Switch(
                    value: _enabled,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (v) => setState(() => _enabled = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ---- Chọn giờ ----
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder, width: 2),
              ),
              child: InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: AppColors.textDark),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Giờ nhắc nhở',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(_time),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textGrey),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ---- Nút Lưu ----
            DuoButton(
              label: _saving ? 'Đang lưu...' : 'LƯU',
              color: AppColors.primaryGreen,
              shadowColor: AppColors.darkGreen,
              onTap: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
