import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFFF3EE);
  static const Color primaryDark = Color(0xFFE8521A);
  static const Color accent = Color(0xFFFF9F1C);

  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);

  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEEEEEE);
  static const Color divider = Color(0xFFF3F4F6);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color hackathon = Color(0xFF8B5CF6);
  static const Color achievement = Color(0xFFEF4444);
  static const Color certification = Color(0xFF3B82F6);
  static const Color project = Color(0xFF10B981);
  static const Color internship = Color(0xFFF59E0B);
  static const Color research = Color(0xFFEC4899);
  static const Color milestone = Color(0xFF06B6D4);
  static const Color contest = Color(0xFFFF6B35);

  static Color forType(String type) {
    switch (type) {
      case 'hackathon': return hackathon;
      case 'achievement': return achievement;
      case 'certification': return certification;
      case 'project': return project;
      case 'internship': return internship;
      case 'research': return research;
      case 'milestone': return milestone;
      case 'contest': return contest;
      default: return textSecondary;
    }
  }
}
