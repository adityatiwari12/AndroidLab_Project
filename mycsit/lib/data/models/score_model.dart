class ScoreCache {
  final String userId;
  final double totalScore;
  final double hackathonScore;
  final double projectScore;
  final double academicScore;
  final double codingScore;

  const ScoreCache({
    required this.userId,
    required this.totalScore,
    required this.hackathonScore,
    required this.projectScore,
    required this.academicScore,
    required this.codingScore,
  });

  static const empty = ScoreCache(
    userId: '',
    totalScore: 0,
    hackathonScore: 0,
    projectScore: 0,
    academicScore: 0,
    codingScore: 0,
  );
}
