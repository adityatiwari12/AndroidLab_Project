import '../models/enums.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';
import '../models/coding_model.dart';
import '../models/academic_model.dart';
import '../models/score_model.dart';
import '../models/notification_model.dart';

class MockData {
  MockData._();

  // ── Roster ──────────────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> roster = [
    {'rollNumber': '09', 'fullName': 'Aditya Tiwari', 'class': 'CSIT1', 'year': 2, 'id': 'user-09'},
    {'rollNumber': '12', 'fullName': 'Akshay Khanna', 'class': 'CSIT1', 'year': 2, 'id': 'user-12'},
    {'rollNumber': '23', 'fullName': 'Anvesh Trivedi', 'class': 'CSIT1', 'year': 2, 'id': 'user-23'},
    {'rollNumber': '24', 'fullName': 'Aryan Singh Bhadoria', 'class': 'CSIT1', 'year': 2, 'id': 'user-24'},
  ];

  static Map<String, dynamic>? findRoster(String rollNumber) {
    try {
      return roster.firstWhere((r) => r['rollNumber'] == rollNumber);
    } catch (_) {
      return null;
    }
  }

  static UserModel userFromRoster(Map<String, dynamic> r) => UserModel(
        id: r['id'] as String,
        rollNumber: r['rollNumber'] as String,
        fullName: r['fullName'] as String,
        classGroup: r['class'] as String,
        year: r['year'] as int,
      );

  // ── Leaderboard ─────────────────────────────────────────────────────────────
  static List<Map<String, dynamic>> get leaderboard => [
        {'rank': 1, 'userId': 'user-24', 'fullName': 'Aryan Singh Bhadoria', 'rollNumber': '24', 'class': 'CSIT1', 'year': 2, 'total': 79.63, 'hackathon': 85.0, 'project': 75.0, 'academic': 82.5, 'coding': 70.0},
        {'rank': 2, 'userId': 'user-23', 'fullName': 'Anvesh Trivedi', 'rollNumber': '23', 'class': 'CSIT1', 'year': 2, 'total': 72.50, 'hackathon': 72.5, 'project': 65.0, 'academic': 87.5, 'coding': 60.0},
        {'rank': 3, 'userId': 'user-09', 'fullName': 'Aditya Tiwari', 'rollNumber': '09', 'class': 'CSIT1', 'year': 2, 'total': 65.25, 'hackathon': 67.5, 'project': 50.0, 'academic': 85.0, 'coding': 52.5},
        {'rank': 4, 'userId': 'user-12', 'fullName': 'Akshay Khanna', 'rollNumber': '12', 'class': 'CSIT1', 'year': 2, 'total': 55.88, 'hackathon': 55.0, 'project': 45.0, 'academic': 77.5, 'coding': 40.0},
      ];

  // ── Scores ──────────────────────────────────────────────────────────────────
  static final Map<String, ScoreCache> _scores = {
    'user-09': const ScoreCache(userId: 'user-09', totalScore: 65.25, hackathonScore: 67.5, projectScore: 50.0, academicScore: 85.0, codingScore: 52.5),
    'user-12': const ScoreCache(userId: 'user-12', totalScore: 55.88, hackathonScore: 55.0, projectScore: 45.0, academicScore: 77.5, codingScore: 40.0),
    'user-23': const ScoreCache(userId: 'user-23', totalScore: 72.50, hackathonScore: 72.5, projectScore: 65.0, academicScore: 87.5, codingScore: 60.0),
    'user-24': const ScoreCache(userId: 'user-24', totalScore: 79.63, hackathonScore: 85.0, projectScore: 75.0, academicScore: 82.5, codingScore: 70.0),
  };

  static ScoreCache scoreForUser(String userId) => _scores[userId] ?? ScoreCache.empty;

  // ── Activities ──────────────────────────────────────────────────────────────
  static final Map<String, List<ActivityModel>> _activities = {
    'user-09': [
      ActivityModel(id: 'act-09-1', userId: 'user-09', type: ActivityType.hackathon, title: 'Smart India Hackathon 2024', description: 'Built an AI-powered crop disease detection app for farmers.', activityDate: '2024-08-15', proofPath: null, status: EntryStatus.approved, createdAt: '2024-08-16'),
      ActivityModel(id: 'act-09-2', userId: 'user-09', type: ActivityType.certification, title: 'Python for Data Science (Coursera)', description: 'Completed IBM Python for Data Science professional certificate.', activityDate: '2024-07-20', proofPath: null, status: EntryStatus.approved, createdAt: '2024-07-22'),
      ActivityModel(id: 'act-09-3', userId: 'user-09', type: ActivityType.achievement, title: 'AITR Tech Fest 2024 – 1st Place', description: 'Won first prize in Project Exhibition at college tech fest.', activityDate: '2024-10-05', proofPath: null, status: EntryStatus.approved, createdAt: '2024-10-06'),
      ActivityModel(id: 'act-09-4', userId: 'user-09', type: ActivityType.project, title: 'Personal Portfolio Website', description: 'Built a full-stack portfolio with React and Node.js.', activityDate: '2025-01-15', proofPath: null, status: EntryStatus.pending, createdAt: '2025-01-16'),
      ActivityModel(id: 'act-09-5', userId: 'user-09', type: ActivityType.research, title: 'Blockchain in Healthcare – Research Paper', description: 'Survey paper on blockchain applications in medical record management.', activityDate: '2025-02-10', proofPath: null, status: EntryStatus.rejected, rejectionReason: 'Please provide DOI or published journal link as proof.', createdAt: '2025-02-11'),
      ActivityModel(id: 'act-09-6', userId: 'user-09', type: ActivityType.certification, title: 'AWS Cloud Practitioner Essentials', description: 'AWS foundational cloud certification.', activityDate: '2025-03-01', proofPath: null, status: EntryStatus.pending, createdAt: '2025-03-02'),
    ],
    'user-12': [
      ActivityModel(id: 'act-12-1', userId: 'user-12', type: ActivityType.certification, title: 'Java Programming – NPTEL', description: 'NPTEL 12-week Java certification with silver medal.', activityDate: '2024-11-30', proofPath: null, status: EntryStatus.approved, createdAt: '2024-12-01'),
      ActivityModel(id: 'act-12-2', userId: 'user-12', type: ActivityType.project, title: 'Library Management System', description: 'Desktop application for library in C++ with file I/O.', activityDate: '2025-01-10', proofPath: null, status: EntryStatus.pending, createdAt: '2025-01-11'),
    ],
    'user-23': [
      ActivityModel(id: 'act-23-1', userId: 'user-23', type: ActivityType.hackathon, title: 'Flipkart Grid 6.0', description: 'Qualified Level 2 of Flipkart Grid e-commerce hackathon.', activityDate: '2024-09-20', proofPath: null, status: EntryStatus.approved, createdAt: '2024-09-21'),
      ActivityModel(id: 'act-23-2', userId: 'user-23', type: ActivityType.internship, title: 'Web Development Intern – TechCorp', description: '2-month internship building React dashboards.', activityDate: '2024-06-01', proofPath: null, status: EntryStatus.approved, createdAt: '2024-08-05'),
      ActivityModel(id: 'act-23-3', userId: 'user-23', type: ActivityType.achievement, title: 'Google DSC Core Team Member', description: 'Selected as core team member for GDSC AITR chapter.', activityDate: '2024-08-10', proofPath: null, status: EntryStatus.approved, createdAt: '2024-08-11'),
    ],
    'user-24': [
      ActivityModel(id: 'act-24-1', userId: 'user-24', type: ActivityType.hackathon, title: 'HackWithInfy 2024', description: 'Reached semi-finals in Infosys national hackathon.', activityDate: '2024-07-05', proofPath: null, status: EntryStatus.approved, createdAt: '2024-07-06'),
      ActivityModel(id: 'act-24-2', userId: 'user-24', type: ActivityType.internship, title: 'ML Intern – AIIMS Bhopal', description: 'Research internship on medical image segmentation using deep learning.', activityDate: '2024-05-15', proofPath: null, status: EntryStatus.approved, createdAt: '2024-08-01'),
      ActivityModel(id: 'act-24-3', userId: 'user-24', type: ActivityType.achievement, title: 'GATE 2025 Qualified', description: 'Qualified GATE 2025 CS paper with score 612.', activityDate: '2025-02-20', proofPath: null, status: EntryStatus.approved, createdAt: '2025-03-05'),
    ],
  };

  static List<ActivityModel> activitiesForUser(String userId) =>
      List.from(_activities[userId] ?? []);

  // ── Coding Activities ────────────────────────────────────────────────────────
  static final Map<String, List<CodingActivityModel>> _coding = {
    'user-09': [
      CodingActivityModel(id: 'cod-09-1', userId: 'user-09', platform: CodingPlatform.leetcode, type: CodingType.milestone, value: 250, status: EntryStatus.approved, createdAt: '2024-11-10'),
      CodingActivityModel(id: 'cod-09-2', userId: 'user-09', platform: CodingPlatform.codeforces, type: CodingType.milestone, value: 100, status: EntryStatus.approved, createdAt: '2024-12-05'),
      CodingActivityModel(id: 'cod-09-3', userId: 'user-09', platform: CodingPlatform.leetcode, type: CodingType.contest, title: 'Biweekly Contest 128', value: 1502, status: EntryStatus.approved, createdAt: '2024-12-21'),
      CodingActivityModel(id: 'cod-09-4', userId: 'user-09', platform: CodingPlatform.leetcode, type: CodingType.contest, title: 'Weekly Contest 394', value: 890, status: EntryStatus.pending, createdAt: '2025-04-06'),
      CodingActivityModel(id: 'cod-09-5', userId: 'user-09', platform: CodingPlatform.leetcode, type: CodingType.notableProblem, title: 'Merge K Sorted Lists', difficulty: DifficultyLevel.hard, status: EntryStatus.approved, createdAt: '2025-01-12'),
    ],
    'user-12': [
      CodingActivityModel(id: 'cod-12-1', userId: 'user-12', platform: CodingPlatform.leetcode, type: CodingType.milestone, value: 80, status: EntryStatus.approved, createdAt: '2025-01-05'),
    ],
    'user-23': [
      CodingActivityModel(id: 'cod-23-1', userId: 'user-23', platform: CodingPlatform.leetcode, type: CodingType.milestone, value: 320, status: EntryStatus.approved, createdAt: '2024-10-15'),
      CodingActivityModel(id: 'cod-23-2', userId: 'user-23', platform: CodingPlatform.codeforces, type: CodingType.contest, title: 'Div 2 Round 949', value: 312, status: EntryStatus.approved, createdAt: '2024-11-20'),
      CodingActivityModel(id: 'cod-23-3', userId: 'user-23', platform: CodingPlatform.codechef, type: CodingType.milestone, value: 150, status: EntryStatus.approved, createdAt: '2025-02-01'),
    ],
    'user-24': [
      CodingActivityModel(id: 'cod-24-1', userId: 'user-24', platform: CodingPlatform.leetcode, type: CodingType.milestone, value: 450, status: EntryStatus.approved, createdAt: '2024-09-10'),
      CodingActivityModel(id: 'cod-24-2', userId: 'user-24', platform: CodingPlatform.codeforces, type: CodingType.milestone, value: 200, status: EntryStatus.approved, createdAt: '2024-10-20'),
      CodingActivityModel(id: 'cod-24-3', userId: 'user-24', platform: CodingPlatform.codeforces, type: CodingType.contest, title: 'Div 1 Round 947', value: 156, status: EntryStatus.approved, createdAt: '2025-01-08'),
    ],
  };

  static List<CodingActivityModel> codingForUser(String userId) =>
      List.from(_coding[userId] ?? []);

  // ── Academic Records ─────────────────────────────────────────────────────────
  static final Map<String, List<AcademicRecord>> _academics = {
    'user-09': [
      AcademicRecord(userId: 'user-09', semester: 1, cgpa: 8.0, totalClasses: 120, attended: 98, subjects: const [
        SubjectMark(subjectName: 'Data Structures & Algorithms', marksObtained: 82, maxMarks: 100),
        SubjectMark(subjectName: 'Mathematics – I', marksObtained: 79, maxMarks: 100),
        SubjectMark(subjectName: 'Engineering Physics', marksObtained: 70, maxMarks: 100),
        SubjectMark(subjectName: 'Environmental Science', marksObtained: 88, maxMarks: 100),
        SubjectMark(subjectName: 'English Communication', marksObtained: 75, maxMarks: 100),
      ]),
      AcademicRecord(userId: 'user-09', semester: 2, cgpa: 8.5, totalClasses: 110, attended: 102, subjects: const [
        SubjectMark(subjectName: 'Object Oriented Programming (Java)', marksObtained: 88, maxMarks: 100),
        SubjectMark(subjectName: 'Mathematics – II', marksObtained: 82, maxMarks: 100),
        SubjectMark(subjectName: 'Statistics & Probability', marksObtained: 80, maxMarks: 100),
        SubjectMark(subjectName: 'Digital Logic Design', marksObtained: 82, maxMarks: 100),
        SubjectMark(subjectName: 'Python Programming', marksObtained: 92, maxMarks: 100),
      ]),
    ],
    'user-12': [
      AcademicRecord(userId: 'user-12', semester: 1, cgpa: 7.5, totalClasses: 120, attended: 85, subjects: const [
        SubjectMark(subjectName: 'Data Structures & Algorithms', marksObtained: 71, maxMarks: 100),
        SubjectMark(subjectName: 'Mathematics – I', marksObtained: 74, maxMarks: 100),
        SubjectMark(subjectName: 'Engineering Physics', marksObtained: 68, maxMarks: 100),
      ]),
      AcademicRecord(userId: 'user-12', semester: 2, cgpa: 8.0, totalClasses: 110, attended: 90, subjects: const [
        SubjectMark(subjectName: 'Object Oriented Programming (Java)', marksObtained: 80, maxMarks: 100),
        SubjectMark(subjectName: 'Mathematics – II', marksObtained: 78, maxMarks: 100),
      ]),
    ],
    'user-23': [
      AcademicRecord(userId: 'user-23', semester: 1, cgpa: 8.7, totalClasses: 120, attended: 108, subjects: const [
        SubjectMark(subjectName: 'Data Structures & Algorithms', marksObtained: 90, maxMarks: 100),
        SubjectMark(subjectName: 'Mathematics – I', marksObtained: 85, maxMarks: 100),
        SubjectMark(subjectName: 'Engineering Physics', marksObtained: 78, maxMarks: 100),
      ]),
      AcademicRecord(userId: 'user-23', semester: 2, cgpa: 8.8, totalClasses: 110, attended: 105, subjects: const [
        SubjectMark(subjectName: 'Object Oriented Programming (Java)', marksObtained: 92, maxMarks: 100),
        SubjectMark(subjectName: 'Statistics & Probability', marksObtained: 84, maxMarks: 100),
      ]),
    ],
    'user-24': [
      AcademicRecord(userId: 'user-24', semester: 1, cgpa: 8.2, totalClasses: 120, attended: 115, subjects: const [
        SubjectMark(subjectName: 'Data Structures & Algorithms', marksObtained: 84, maxMarks: 100),
        SubjectMark(subjectName: 'Mathematics – I', marksObtained: 80, maxMarks: 100),
      ]),
      AcademicRecord(userId: 'user-24', semester: 2, cgpa: 8.3, totalClasses: 110, attended: 108, subjects: const [
        SubjectMark(subjectName: 'Object Oriented Programming (Java)', marksObtained: 86, maxMarks: 100),
        SubjectMark(subjectName: 'Machine Learning Fundamentals', marksObtained: 89, maxMarks: 100),
      ]),
    ],
  };

  static List<AcademicRecord> academicsForUser(String userId) =>
      _academics[userId] ?? [];

  // ── Notifications ─────────────────────────────────────────────────────────────
  static final Map<String, List<NotificationModel>> _notifications = {
    'user-09': [
      NotificationModel(id: 'n-09-1', userId: 'user-09', title: 'Account Approved', body: 'Welcome to MyCSIT! Your account is now active.', type: NotificationType.account, isRead: true, createdAt: DateTime(2024, 7, 1)),
      NotificationModel(id: 'n-09-2', userId: 'user-09', title: 'Activity Approved', body: "'Smart India Hackathon 2024' has been approved. Keep it up!", type: NotificationType.activityApproved, isRead: true, createdAt: DateTime(2024, 8, 20)),
      NotificationModel(id: 'n-09-3', userId: 'user-09', title: 'Activity Approved', body: "'AITR Tech Fest 2024 – 1st Place' has been approved.", type: NotificationType.activityApproved, isRead: true, createdAt: DateTime(2024, 10, 8)),
      NotificationModel(id: 'n-09-4', userId: 'user-09', title: 'Coding Approved', body: 'Your LeetCode milestone (250 problems) has been approved!', type: NotificationType.coding, isRead: true, createdAt: DateTime(2024, 11, 12)),
      NotificationModel(id: 'n-09-5', userId: 'user-09', title: 'Activity Rejected', body: "'Blockchain Research Paper' was rejected. Reason: Provide DOI or published journal link as proof.", type: NotificationType.activityRejected, isRead: false, createdAt: DateTime(2025, 2, 15)),
      NotificationModel(id: 'n-09-6', userId: 'user-09', title: 'Under Review', body: "'Personal Portfolio Website' has been submitted and is under review.", type: NotificationType.general, isRead: false, createdAt: DateTime(2025, 1, 16)),
    ],
    'user-12': [
      NotificationModel(id: 'n-12-1', userId: 'user-12', title: 'Account Approved', body: 'Welcome to MyCSIT! Your account is now active.', type: NotificationType.account, isRead: true, createdAt: DateTime(2024, 7, 5)),
      NotificationModel(id: 'n-12-2', userId: 'user-12', title: 'Activity Approved', body: "'Java Programming – NPTEL' certification has been approved.", type: NotificationType.activityApproved, isRead: true, createdAt: DateTime(2024, 12, 5)),
    ],
    'user-23': [
      NotificationModel(id: 'n-23-1', userId: 'user-23', title: 'Account Approved', body: 'Welcome to MyCSIT! Your account is now active.', type: NotificationType.account, isRead: true, createdAt: DateTime(2024, 7, 2)),
      NotificationModel(id: 'n-23-2', userId: 'user-23', title: 'Activity Approved', body: "'Flipkart Grid 6.0' has been approved.", type: NotificationType.activityApproved, isRead: true, createdAt: DateTime(2024, 9, 25)),
      NotificationModel(id: 'n-23-3', userId: 'user-23', title: 'Activity Approved', body: "'Web Development Intern – TechCorp' internship has been approved.", type: NotificationType.activityApproved, isRead: false, createdAt: DateTime(2024, 8, 10)),
    ],
    'user-24': [
      NotificationModel(id: 'n-24-1', userId: 'user-24', title: 'Account Approved', body: 'Welcome to MyCSIT! Your account is now active.', type: NotificationType.account, isRead: true, createdAt: DateTime(2024, 6, 30)),
      NotificationModel(id: 'n-24-2', userId: 'user-24', title: 'Activity Approved', body: "'HackWithInfy 2024' has been approved. Great work!", type: NotificationType.activityApproved, isRead: true, createdAt: DateTime(2024, 7, 10)),
      NotificationModel(id: 'n-24-3', userId: 'user-24', title: 'Coding Approved', body: 'Your LeetCode milestone (450 problems) has been approved!', type: NotificationType.coding, isRead: false, createdAt: DateTime(2025, 1, 3)),
    ],
  };

  static List<NotificationModel> notificationsForUser(String userId) =>
      List.from(_notifications[userId] ?? []);
}
