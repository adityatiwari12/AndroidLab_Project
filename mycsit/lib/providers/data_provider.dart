import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/activity_model.dart';
import '../data/models/coding_model.dart';
import '../data/models/academic_model.dart';
import '../data/models/score_model.dart';
import '../data/models/notification_model.dart';
import '../data/models/enums.dart';
import '../data/mock/mock_data.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

const _uuid = Uuid();

// ── Activities ────────────────────────────────────────────────────────────────

class ActivitiesNotifier extends StateNotifier<List<ActivityModel>> {
  ActivitiesNotifier(String userId) : super(MockData.activitiesForUser(userId));

  void add(ActivityModel activity) {
    state = [activity, ...state];
  }

  void resubmit(String id, {String? title, String? description, String? activityDate}) {
    state = [
      for (final a in state)
        if (a.id == id && a.status == EntryStatus.rejected)
          a.copyWith(status: EntryStatus.pending, title: title, description: description, activityDate: activityDate)
        else
          a,
    ];
  }
}

final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, List<ActivityModel>>((ref) {
  final userId = ref.watch(authProvider).currentUser?.id ?? '';
  return ActivitiesNotifier(userId);
});

// ── Coding ────────────────────────────────────────────────────────────────────

class CodingNotifier extends StateNotifier<List<CodingActivityModel>> {
  CodingNotifier(String userId) : super(MockData.codingForUser(userId));

  void add(CodingActivityModel entry) {
    state = [entry, ...state];
  }
}

final codingProvider =
    StateNotifierProvider<CodingNotifier, List<CodingActivityModel>>((ref) {
  final userId = ref.watch(authProvider).currentUser?.id ?? '';
  return CodingNotifier(userId);
});

// ── Score ─────────────────────────────────────────────────────────────────────

final scoreProvider = Provider<ScoreCache>((ref) {
  final userId = ref.watch(authProvider).currentUser?.id ?? '';
  return MockData.scoreForUser(userId);
});

// ── Academics ─────────────────────────────────────────────────────────────────

final academicsProvider = Provider<List<AcademicRecord>>((ref) {
  final userId = ref.watch(authProvider).currentUser?.id ?? '';
  return MockData.academicsForUser(userId);
});

// ── Notifications ─────────────────────────────────────────────────────────────

class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier(String userId)
      : super(MockData.notificationsForUser(userId));

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>((ref) {
  final userId = ref.watch(authProvider).currentUser?.id ?? '';
  return NotificationsNotifier(userId);
});

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});

// ── Profile Links ─────────────────────────────────────────────────────────────

class ProfileLinksNotifier extends StateNotifier<Map<String, String>> {
  final String userId;

  ProfileLinksNotifier(this.userId) : super({}) {
    _load();
  }

  Future<void> _load() async {
    final links = await DatabaseService().getProfileLinks(userId);
    state = links;
  }

  Future<void> update(String platform, String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    await DatabaseService().upsertProfileLink(userId, platform, trimmed);
    state = {...state, platform: trimmed};
  }

  Future<void> remove(String platform) async {
    await DatabaseService().removeProfileLink(userId, platform);
    state = {...state}..remove(platform);
  }
}

final profileLinksProvider =
    StateNotifierProvider<ProfileLinksNotifier, Map<String, String>>((ref) {
  final userId = ref.watch(authProvider).currentUser?.id ?? '';
  return ProfileLinksNotifier(userId);
});

// ── Helpers ───────────────────────────────────────────────────────────────────

ActivityModel buildActivity({
  required String userId,
  required ActivityType type,
  required String title,
  required String description,
  required DateTime activityDate,
  String? proofPath,
  String? proofFileName,
}) {
  final dateStr = '${activityDate.year.toString().padLeft(4, '0')}-${activityDate.month.toString().padLeft(2, '0')}-${activityDate.day.toString().padLeft(2, '0')}';
  final now = DateTime.now();
  final nowStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return ActivityModel(
    id: _uuid.v4(),
    userId: userId,
    type: type,
    title: title,
    description: description,
    activityDate: dateStr,
    proofPath: proofPath,
    proofFileName: proofFileName,
    status: EntryStatus.pending,
    createdAt: nowStr,
  );
}

CodingActivityModel buildCoding({
  required String userId,
  required CodingPlatform platform,
  required CodingType type,
  String? title,
  int? value,
  DifficultyLevel? difficulty,
  String? proofPath,
  String? proofFileName,
}) {
  final now = DateTime.now();
  final nowStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return CodingActivityModel(
    id: _uuid.v4(),
    userId: userId,
    platform: platform,
    type: type,
    title: title,
    value: value,
    difficulty: difficulty,
    proofPath: proofPath,
    proofFileName: proofFileName,
    status: EntryStatus.pending,
    createdAt: nowStr,
  );
}
