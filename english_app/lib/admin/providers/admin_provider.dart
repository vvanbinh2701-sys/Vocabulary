import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../models/admin_models.dart';
import '../services/admin_auth_service.dart';
import '../services/admin_firestore_service.dart';

/// Provider quản lý trạng thái cho Admin Dashboard
/// Đọc/ghi vào CÙNG Firestore collection với User app → đồng bộ realtime
class AdminProvider extends ChangeNotifier {
  final AdminAuthService _authService;
  final AdminFirestoreService _dataService;

  AdminProvider({
    AdminAuthService? authService,
    AdminFirestoreService? dataService,
  })  : _authService = authService ?? AdminAuthService(),
        _dataService = dataService ?? AdminFirestoreService();

  // ─── Auth State ───
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  AdminUser? _currentAdmin;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  AdminUser? get currentAdmin => _currentAdmin;
  String? get errorMessage => _errorMessage;

  // ─── Navigation ───
  int _selectedSidebarIndex = 0;
  int get selectedSidebarIndex => _selectedSidebarIndex;

  String get currentRoute => sidebarItems[_selectedSidebarIndex].route;

  // ─── Sidebar Collapse ───
  bool _sidebarCollapsed = false;
  bool get sidebarCollapsed => _sidebarCollapsed;

  // ─── Real Data từ Firestore ───
  List<Vocabulary> _vocabularies = [];
  List<Vocabulary> get vocabularies => _vocabularies;

  List<Topic> _topics = [];
  List<Topic> get topics => _topics;

  List<AdminUser> _users = [];
  List<AdminUser> get users => _users;

  DashboardStats _stats = DashboardStats();
  DashboardStats get stats => _stats;

  // ─── Search ───
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ─── CRUD Loading ───
  bool _isSaving = false;
  bool get isSaving => _isSaving;

  /// Khởi tạo: kiểm tra user hiện tại có phải admin không + load data
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      final isAdmin = await _authService.checkCurrentUserIsAdmin();
      if (isAdmin) {
        _currentAdmin = await _authService.getCurrentAdmin();
        _isLoggedIn = true;
        _isAdmin = true;
        await Future.wait([
          _loadDashboardData(),
          _loadVocabularies(),
          _loadTopics(),
        ]);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Đăng nhập admin
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.adminSignIn(email: email, password: password);
      _currentAdmin = await _authService.getCurrentAdmin();
      _isLoggedIn = true;
      _isAdmin = true;
      await Future.wait([
        _loadDashboardData(),
        _loadVocabularies(),
        _loadTopics(),
      ]);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AdminAccessDeniedException {
      _errorMessage = 'Tài khoản này không có quyền truy cập Admin.';
    } catch (e) {
      _errorMessage = 'Đăng nhập thất bại: ${e.toString()}';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Đăng xuất admin
  Future<void> logout() async {
    await _authService.signOut();
    _isLoggedIn = false;
    _isAdmin = false;
    _currentAdmin = null;
    _selectedSidebarIndex = 0;
    notifyListeners();
  }

  /// Chọn menu sidebar
  void selectSidebarItem(int index) {
    if (index == sidebarItems.length) {
      // Last item = Logout
      logout();
      return;
    }
    _selectedSidebarIndex = index;
    notifyListeners();
  }

  /// Toggle sidebar collapse
  void toggleSidebar() {
    _sidebarCollapsed = !_sidebarCollapsed;
    notifyListeners();
  }

  /// Tìm kiếm
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Load dữ liệu dashboard
  Future<void> _loadDashboardData() async {
    try {
      final results = await Future.wait([
        _dataService.getStats(),
        _authService.getAllUsers(),
      ]);
      final statMap = results[0] as Map<String, int>;
      _users = results[1] as List<AdminUser>;
      _stats = DashboardStats(
        totalVocab: statMap['totalVocab'] ?? 0,
        totalTopics: statMap['totalTopics'] ?? 0,
        totalUsers: _users.length,
        totalSessions: statMap['totalSessions'] ?? 0,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi load dashboard: $e');
    }
  }

  Future<void> _loadVocabularies() async {
    try {
      _vocabularies = await _dataService.getVocabularies();
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi load vocab: $e');
    }
  }

  Future<void> _loadTopics() async {
    try {
      _topics = await _dataService.getTopics();
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi load topics: $e');
    }
  }

  Future<void> refreshDashboard() => _loadDashboardData();
  Future<void> refreshVocabularies() => _loadVocabularies();
  Future<void> refreshTopics() => _loadTopics();

  // ═══════════════════════════════════════════════════════════
  //  VOCABULARY CRUD → ghi vào Firestore, User app tự sync
  // ═══════════════════════════════════════════════════════════

  Future<void> addVocabulary(Vocabulary vocab) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _dataService.addVocabulary(vocab);
      await _loadVocabularies();
      await _loadDashboardData();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateVocabulary(Vocabulary vocab) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _dataService.updateVocabulary(vocab);
      await _loadVocabularies();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteVocabulary(String id) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _dataService.deleteVocabulary(id);
      await _loadVocabularies();
      await _loadDashboardData();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  TOPIC CRUD
  // ═══════════════════════════════════════════════════════════

  Future<void> addTopic(Topic topic) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _dataService.addTopic(topic);
      await _loadTopics();
      await _loadDashboardData();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateTopic(Topic topic) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _dataService.updateTopic(topic);
      await _loadTopics();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteTopic(String topicId) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _dataService.deleteTopic(topicId);
      await _loadTopics();
      await _loadVocabularies();
      await _loadDashboardData();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  USER MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  Future<void> refreshUsers() async {
    _users = await _authService.getAllUsers();
    notifyListeners();
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await _authService.updateUserRole(uid, newRole);
    await refreshUsers();
  }

  Future<void> updateUserStatus(String uid, String newStatus) async {
    await _authService.updateUserStatus(uid, newStatus);
    await refreshUsers();
  }
}
