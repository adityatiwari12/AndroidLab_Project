import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/mock/mock_data.dart';

class AuthNotifier extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Returns null on success, error message on failure.
  String? login(String rollNumber, String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    final entry = MockData.findRoster(rollNumber.trim());
    if (entry == null) {
      return 'Roll number not found. Check your roll number or register.';
    }
    _currentUser = MockData.userFromRoster(entry);
    notifyListeners();
    return null;
  }

  /// Returns null on success, error message on failure.
  String? register({
    required String rollNumber,
    required String fullName,
    required String password,
    required String confirmPassword,
  }) {
    if (password != confirmPassword) return 'Passwords do not match.';
    if (password.length < 6) return 'Password must be at least 6 characters.';

    final entry = MockData.findRoster(rollNumber.trim());
    if (entry == null) {
      return 'Roll number not in records. Contact your faculty coordinator.';
    }
    // Skip pending — prototype goes directly to active
    _currentUser = MockData.userFromRoster(entry);
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

final authProvider = ChangeNotifierProvider<AuthNotifier>(
  (ref) => AuthNotifier(),
);
