import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'admin/providers/admin_provider.dart';
import 'admin/screens/admin_main_screen.dart';
import 'admin/screens/admin_login_screen.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'EngMaster - Học Tiếng Anh',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}

/// Cổng xác thực: phân luồng Admin vs User thường
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checking = true;
  bool _lastLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    // Chờ auth ready
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;
      return !context.read<AppState>().authReady;
    });

    if (!mounted) return;

    final appState = context.read<AppState>();
    if (appState.isLoggedIn) {
      await context.read<AdminProvider>().init();
      _lastLoggedIn = true;
    }

    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final admin = context.watch<AdminProvider>();

    // Phát hiện user vừa login → kiểm tra lại admin role
    if (app.isLoggedIn && !_lastLoggedIn) {
      _lastLoggedIn = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<AdminProvider>().init();
        }
      });
    } else if (!app.isLoggedIn) {
      _lastLoggedIn = false;
    }

    // Loading
    if (_checking || (app.isLoggedIn && admin.isLoading)) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Nếu đã login và là admin → vào Admin Dashboard
    if (app.isLoggedIn && admin.isAdmin) {
      return const AdminMainScreen();
    }

    // Nếu đã login và là user thường → vào app thường
    if (app.isLoggedIn) {
      return const HomeShell();
    }

    // Chưa login → Welcome
    return const WelcomeScreen();
  }
}
