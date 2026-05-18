enum ActivityType { hackathon, achievement, certification, project, internship, research }

enum CodingType { milestone, contest, notableProblem }

enum CodingPlatform { leetcode, codeforces, codechef, other }

enum DifficultyLevel { easy, medium, hard }

enum EntryStatus { pending, approved, rejected }

extension ActivityTypeX on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.hackathon: return 'Hackathon';
      case ActivityType.achievement: return 'Achievement';
      case ActivityType.certification: return 'Certification';
      case ActivityType.project: return 'Project';
      case ActivityType.internship: return 'Internship';
      case ActivityType.research: return 'Research';
    }
  }
}

extension CodingTypeX on CodingType {
  String get label {
    switch (this) {
      case CodingType.milestone: return 'Milestone';
      case CodingType.contest: return 'Contest';
      case CodingType.notableProblem: return 'Notable Problem';
    }
  }
}

extension CodingPlatformX on CodingPlatform {
  String get label {
    switch (this) {
      case CodingPlatform.leetcode: return 'LeetCode';
      case CodingPlatform.codeforces: return 'Codeforces';
      case CodingPlatform.codechef: return 'CodeChef';
      case CodingPlatform.other: return 'Other';
    }
  }
}

extension EntryStatusX on EntryStatus {
  String get label {
    switch (this) {
      case EntryStatus.pending: return 'Pending';
      case EntryStatus.approved: return 'Approved';
      case EntryStatus.rejected: return 'Rejected';
    }
  }
}
