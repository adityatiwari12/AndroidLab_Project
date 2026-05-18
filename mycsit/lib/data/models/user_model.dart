class UserModel {
  final String id;
  final String rollNumber;
  final String fullName;
  final String classGroup;
  final int year;
  final String status;
  final String role;

  const UserModel({
    required this.id,
    required this.rollNumber,
    required this.fullName,
    required this.classGroup,
    required this.year,
    this.status = 'active',
    this.role = 'student',
  });

  String get firstName => fullName.split(' ').first;

  String get displayClass => '$classGroup – Year $year';

  String get avatarInitials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}
