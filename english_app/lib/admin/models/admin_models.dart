import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho người dùng trong admin
class AdminUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String status;
  final DateTime createdAt;
  final String? avatarUrl;
  final String? phone;

  AdminUser({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'user',
    this.status = 'active',
    required this.createdAt,
    this.avatarUrl,
    this.phone,
  });

  bool get isAdmin => role == 'admin';

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUser(
      uid: doc.id,
      name: data['name'] ?? data['displayName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      avatarUrl: data['avatarUrl'],
      phone: data['phone'],
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (phone != null) 'phone': phone,
      };
}

/// Model thống kê cho dashboard
class DashboardStats {
  final int totalVocab;
  final int totalTopics;
  final int totalUsers;
  final int totalSessions;

  DashboardStats({
    this.totalVocab = 0,
    this.totalTopics = 0,
    this.totalUsers = 0,
    this.totalSessions = 0,
  });
}

/// Model cho mục điều hướng sidebar
class SidebarItem {
  final String title;
  final IconData icon;
  final String route;

  const SidebarItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

/// Danh sách các mục sidebar mặc định
const List<SidebarItem> sidebarItems = [
  SidebarItem(
      title: 'Dashboard', icon: Icons.dashboard_rounded, route: 'dashboard'),
  SidebarItem(
      title: 'Vocabulary', icon: Icons.menu_book_rounded, route: 'vocabulary'),
  SidebarItem(title: 'Topics', icon: Icons.folder_rounded, route: 'topics'),
  SidebarItem(title: 'Images', icon: Icons.image_rounded, route: 'images'),
  SidebarItem(title: 'Users', icon: Icons.people_rounded, route: 'users'),
  SidebarItem(
      title: 'Statistics', icon: Icons.bar_chart_rounded, route: 'statistics'),
  SidebarItem(
      title: 'Settings', icon: Icons.settings_rounded, route: 'settings'),
];

/// Activity log item
class ActivityItem {
  final String action;
  final String user;
  final String target;
  final DateTime timestamp;

  ActivityItem({
    required this.action,
    required this.user,
    required this.target,
    required this.timestamp,
  });
}
