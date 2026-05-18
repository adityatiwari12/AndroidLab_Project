class SubjectMark {
  final String subjectName;
  final int marksObtained;
  final int maxMarks;

  const SubjectMark({
    required this.subjectName,
    required this.marksObtained,
    required this.maxMarks,
  });

  double get percentage => marksObtained / maxMarks * 100;
}

class AcademicRecord {
  final String userId;
  final int semester;
  final double cgpa;
  final List<SubjectMark> subjects;
  final int totalClasses;
  final int attended;

  const AcademicRecord({
    required this.userId,
    required this.semester,
    required this.cgpa,
    this.subjects = const [],
    this.totalClasses = 0,
    this.attended = 0,
  });

  double get attendancePercentage =>
      totalClasses > 0 ? attended / totalClasses * 100 : 0;
}
