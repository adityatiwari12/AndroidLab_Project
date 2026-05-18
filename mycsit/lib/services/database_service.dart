import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/models/activity_model.dart';
import '../data/models/coding_model.dart';
import '../data/models/enums.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mycsit.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS activities');
    await db.execute('DROP TABLE IF EXISTS coding_activities');
    await db.execute('DROP TABLE IF EXISTS uploaded_files');
    await db.execute('DROP TABLE IF EXISTS profile_links');
    await _onCreate(db, newVersion);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        activityDate TEXT NOT NULL,
        proofPath TEXT,
        proofFileName TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        rejectionReason TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE coding_activities (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        platform TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT,
        value INTEGER,
        difficulty TEXT,
        proofPath TEXT,
        proofFileName TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE uploaded_files (
        id TEXT PRIMARY KEY,
        entityId TEXT NOT NULL,
        entityType TEXT NOT NULL,
        fileName TEXT NOT NULL,
        filePath TEXT NOT NULL,
        mimeType TEXT,
        sizeBytes INTEGER,
        uploadedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE profile_links (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        platform TEXT NOT NULL,
        url TEXT NOT NULL,
        UNIQUE(userId, platform)
      )
    ''');
  }

  // ── Activities ──────────────────────────────────────────────────────────────

  Future<void> insertActivity(ActivityModel activity) async {
    final db = await database;
    await db.insert('activities', {
      'id': activity.id,
      'userId': activity.userId,
      'type': activity.type.name,
      'title': activity.title,
      'description': activity.description,
      'activityDate': activity.activityDate,
      'proofPath': activity.proofPath,
      'proofFileName': activity.proofFileName,
      'status': activity.status.name,
      'rejectionReason': activity.rejectionReason,
      'createdAt': activity.createdAt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ActivityModel>> getActivitiesForUser(String userId) async {
    final db = await database;
    final rows = await db.query('activities', where: 'userId = ?', whereArgs: [userId], orderBy: 'createdAt DESC');
    return rows.map(_rowToActivity).toList();
  }

  Future<void> updateActivityStatus(String id, EntryStatus status, {String? rejectionReason}) async {
    final db = await database;
    final map = {'status': status.name};
    if (rejectionReason != null) map['rejectionReason'] = rejectionReason;
    await db.update('activities', map, where: 'id = ?', whereArgs: [id]);
  }

  ActivityModel _rowToActivity(Map<String, dynamic> row) {
    return ActivityModel(
      id: row['id'] as String,
      userId: row['userId'] as String,
      type: ActivityType.values.firstWhere((e) => e.name == row['type'], orElse: () => ActivityType.achievement),
      title: row['title'] as String,
      description: row['description'] as String? ?? '',
      activityDate: row['activityDate'] as String,
      proofPath: row['proofPath'] as String?,
      proofFileName: row['proofFileName'] as String?,
      status: EntryStatus.values.firstWhere((e) => e.name == row['status'], orElse: () => EntryStatus.pending),
      rejectionReason: row['rejectionReason'] as String?,
      createdAt: row['createdAt'] as String,
    );
  }

  // ── Coding Activities ───────────────────────────────────────────────────────

  Future<void> insertCodingActivity(CodingActivityModel coding) async {
    final db = await database;
    await db.insert('coding_activities', {
      'id': coding.id,
      'userId': coding.userId,
      'platform': coding.platform.name,
      'type': coding.type.name,
      'title': coding.title,
      'value': coding.value,
      'difficulty': coding.difficulty?.name,
      'proofPath': coding.proofPath,
      'proofFileName': coding.proofFileName,
      'status': coding.status.name,
      'createdAt': coding.createdAt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CodingActivityModel>> getCodingForUser(String userId) async {
    final db = await database;
    final rows = await db.query('coding_activities', where: 'userId = ?', whereArgs: [userId], orderBy: 'createdAt DESC');
    return rows.map(_rowToCoding).toList();
  }

  CodingActivityModel _rowToCoding(Map<String, dynamic> row) {
    return CodingActivityModel(
      id: row['id'] as String,
      userId: row['userId'] as String,
      platform: CodingPlatform.values.firstWhere((e) => e.name == row['platform'], orElse: () => CodingPlatform.other),
      type: CodingType.values.firstWhere((e) => e.name == row['type'], orElse: () => CodingType.milestone),
      title: row['title'] as String?,
      value: row['value'] as int?,
      difficulty: row['difficulty'] != null ? DifficultyLevel.values.firstWhere((e) => e.name == row['difficulty'], orElse: () => DifficultyLevel.medium) : null,
      proofPath: row['proofPath'] as String?,
      proofFileName: row['proofFileName'] as String?,
      status: EntryStatus.values.firstWhere((e) => e.name == row['status'], orElse: () => EntryStatus.pending),
      createdAt: row['createdAt'] as String,
    );
  }

  // ── File Records ────────────────────────────────────────────────────────────

  Future<void> saveFileRecord({
    required String id,
    required String entityId,
    required String entityType,
    required String fileName,
    required String filePath,
    String? mimeType,
    int? sizeBytes,
  }) async {
    final db = await database;
    await db.insert('uploaded_files', {
      'id': id,
      'entityId': entityId,
      'entityType': entityType,
      'fileName': fileName,
      'filePath': filePath,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'uploadedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ── Profile Links ───────────────────────────────────────────────────────────

  Future<Map<String, String>> getProfileLinks(String userId) async {
    final db = await database;
    final rows = await db.query('profile_links', where: 'userId = ?', whereArgs: [userId]);
    return {for (final r in rows) r['platform'] as String: r['url'] as String};
  }

  Future<void> upsertProfileLink(String userId, String platform, String url) async {
    final db = await database;
    await db.insert('profile_links', {
      'id': '$userId-$platform',
      'userId': userId,
      'platform': platform,
      'url': url,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeProfileLink(String userId, String platform) async {
    final db = await database;
    await db.delete('profile_links', where: 'userId = ? AND platform = ?', whereArgs: [userId, platform]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
