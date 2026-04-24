import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/discovered_cell.dart';
import '../models/track_point.dart';
import '../models/trip.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();
  Database? _db;

  Future<void> init() async {
    final root = await getDatabasesPath();
    _db = await openDatabase(
      p.join(root, 'black_world_map.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE trips(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            started_at TEXT NOT NULL,
            ended_at TEXT,
            distance_meters REAL NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE track_points(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            trip_id INTEGER NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            accuracy REAL NOT NULL,
            speed REAL NOT NULL,
            recorded_at TEXT NOT NULL,
            FOREIGN KEY(trip_id) REFERENCES trips(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE discovered_cells(
            cell_key TEXT PRIMARY KEY,
            lat_index INTEGER NOT NULL,
            lng_index INTEGER NOT NULL,
            discovered_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS discovered_cells(
              cell_key TEXT PRIMARY KEY,
              lat_index INTEGER NOT NULL,
              lng_index INTEGER NOT NULL,
              discovered_at TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  Database get db {
    final database = _db;
    if (database == null) throw StateError('Database not initialized');
    return database;
  }

  Future<int> createTrip(String name) => db.insert('trips', {
        'name': name,
        'started_at': DateTime.now().toIso8601String(),
        'distance_meters': 0.0,
      });

  Future<void> finishTrip(int tripId, double distanceMeters) => db.update(
        'trips',
        {'ended_at': DateTime.now().toIso8601String(), 'distance_meters': distanceMeters},
        where: 'id = ?',
        whereArgs: [tripId],
      );

  Future<List<Trip>> loadTrips() async {
    final rows = await db.query('trips', orderBy: 'started_at DESC');
    return rows.map(Trip.fromMap).toList();
  }

  Future<Trip?> activeTrip() async {
    final rows = await db.query('trips', where: 'ended_at IS NULL', limit: 1);
    return rows.isEmpty ? null : Trip.fromMap(rows.first);
  }

  Future<void> addTrackPoint(TrackPoint point) => db.insert('track_points', point.toMap());

  Future<List<TrackPoint>> loadPoints({int? tripId}) async {
    final rows = await db.query(
      'track_points',
      where: tripId == null ? null : 'trip_id = ?',
      whereArgs: tripId == null ? null : [tripId],
      orderBy: 'recorded_at ASC',
    );
    return rows.map(TrackPoint.fromMap).toList();
  }

  Future<void> upsertCells(Iterable<DiscoveredCell> cells) async {
    final batch = db.batch();
    for (final cell in cells) {
      batch.insert('discovered_cells', cell.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<List<DiscoveredCell>> loadCells() async {
    final rows = await db.query('discovered_cells');
    return rows.map(DiscoveredCell.fromMap).toList();
  }
}
