import 'enums.dart';

class CodingActivityModel {
  final String id;
  final String userId;
  final CodingPlatform platform;
  final CodingType type;
  final String? title;
  final int? value;
  final DifficultyLevel? difficulty;
  final String? proofPath;
  final String? proofFileName;
  final EntryStatus status;
  final String? rejectionReason;
  final String createdAt; // ISO date string

  const CodingActivityModel({
    required this.id,
    required this.userId,
    required this.platform,
    required this.type,
    this.title,
    this.value,
    this.difficulty,
    this.proofPath,
    this.proofFileName,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  String get displayValue {
    switch (type) {
      case CodingType.milestone:
        return '${value ?? 0} problems solved';
      case CodingType.contest:
        return 'Rank #${value ?? 0}${title != null ? ' in $title' : ''}';
      case CodingType.notableProblem:
        return '${difficulty?.name.toUpperCase() ?? ''} – ${title ?? ''}';
    }
  }
}
