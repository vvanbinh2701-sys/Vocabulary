import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/home_shell.dart';
import 'screens/welcome_screen.dart';
import 'services/notification_service.dart';

/// Dịch vụ thông báo — khởi tạo 1 lần duy nhất
final notificationService = NotificationService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await notificationService.init();
  runApp(const EnglishApp());
}

class EnglishApp extends StatelessWidget {
  const EnglishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'EngMaster - Học Tiếng Anh',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    if (!app.authReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return app.isLoggedIn ? const HomeShell() : const WelcomeScreen();
  }
}
