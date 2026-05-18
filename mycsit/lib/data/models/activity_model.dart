import 'enums.dart';

class ActivityModel {
  final String id;
  final String userId;
  final ActivityType type;
  final String title;
  final String description;
  final String activityDate; // ISO date string YYYY-MM-DD
  final String? proofPath;
  final String? proofFileName;
  final EntryStatus status;
  final String? rejectionReason;
  final String createdAt; // ISO date string

  const ActivityModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.description = '',
    required this.activityDate,
    this.proofPath,
    this.proofFileName,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  ActivityModel copyWith({
    EntryStatus? status,
    String? rejectionReason,
    String? title,
    String? description,
    String? activityDate,
    String? proofPath,
    String? proofFileName,
  }) {
    return ActivityModel(
      id: id,
      userId: userId,
      type: type,
      title: title ?? this.title,
      description: description ?? this.description,
      activityDate: activityDate ?? this.activityDate,
      proofPath: proofPath ?? this.proofPath,
      proofFileName: proofFileName ?? this.proofFileName,
      status: status ?? this.status,
      rejectionReason: status == EntryStatus.rejected ? rejectionReason : null,
      createdAt: createdAt,
    );
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(activityDate);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return activityDate;
    }
  }
}
