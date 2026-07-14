import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Dịch vụ quản lý thông báo nhắc nhở học tập
class NotificationService {
  static const String _keyEnabled = 'reminder_enabled';
  static const String _keyHour = 'reminder_hour';
  static const String _keyMinute = 'reminder_minute';
  static const int _notificationId = 0;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Khởi tạo plugin và thiết lập kênh thông báo
  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// Khi người dùng chạm vào thông báo → mở app
  void _onNotificationTap(NotificationResponse response) {
    // App đã mở sẵn hoặc được mở bởi hệ thống
  }

  /// Lưu cài đặt nhắc nhở và lên lịch / hủy thông báo
  Future<void> saveReminder({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, enabled);
    await prefs.setInt(_keyHour, hour);
    await prefs.setInt(_keyMinute, minute);

    if (enabled) {
      await _scheduleDaily(hour, minute);
    } else {
      await cancelAll();
    }
  }

  /// Đọc cài đặt nhắc nhở từ SharedPreferences
  Future<Map<String, dynamic>> loadReminder() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_keyEnabled) ?? false,
      'hour': prefs.getInt(_keyHour) ?? 20,
      'minute': prefs.getInt(_keyMinute) ?? 0,
    };
  }

  /// Lên lịch thông báo hàng ngày vào giờ đã chọn
  Future<void> _scheduleDaily(int hour, int minute) async {
    // Huỷ lịch cũ trước khi tạo mới
    await _plugin.cancel(_notificationId);

    // Tính thời gian lịch tiếp theo theo múi giờ local
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Nếu giờ đã qua trong ngày → lên lịch cho ngày mai
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _notificationId,
      '📚 English App',
      'Đã đến giờ học tiếng Anh!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Nhắc nhở học tập',
          channelDescription: 'Thông báo nhắc nhở học tiếng Anh hàng ngày',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Lặp hàng ngày
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Huỷ tất cả thông báo đã lên lịch
  Future<void> cancelAll() async {
    await _plugin.cancel(_notificationId);
  }
}
