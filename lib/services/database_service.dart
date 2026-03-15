import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicament.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pharma_dz.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicaments (
        id INTEGER PRIMARY KEY,
        num_enr TEXT,
        code TEXT,
        cat_num TEXT,
        cat_name TEXT,
        dci TEXT,
        nom_marque TEXT,
        forme TEXT,
        dosage TEXT,
        conditionnement TEXT,
        liste TEXT,
        type TEXT,
        statut TEXT,
        laboratoire TEXT,
        pays TEXT,
        date_initial TEXT,
        date_final TEXT,
        stabilite TEXT,
        obs TEXT,
        is_favori INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_dci ON medicaments(dci)
    ''');
    await db.execute('''
      CREATE INDEX idx_nom_marque ON medicaments(nom_marque)
    ''');
    await db.execute('''
      CREATE INDEX idx_cat_num ON medicaments(cat_num)
    ''');

    // Load data from JSON asset
    final String jsonString =
        await rootBundle.loadString('assets/data/medicaments.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    final batch = db.batch();
    for (final item in jsonList) {
      final med = Medicament.fromJson(item as Map<String, dynamic>);
      batch.insert('medicaments', med.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<bool> isInitialized() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM medicaments'));
    return (count ?? 0) > 0;
  }

  Future<List<Medicament>> searchMedicaments({
    String query = '',
    String? catNum,
    String? liste,
    String? type,
    String? statut,
    bool favorisOnly = false,
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (query.isNotEmpty) {
      conditions.add(
          '(nom_marque LIKE ? OR dci LIKE ? OR code LIKE ? OR laboratoire LIKE ?)');
      final q = '%${query.toUpperCase()}%';
      args.addAll([q, q, q, q]);
    }
    if (catNum != null && catNum.isNotEmpty) {
      conditions.add('cat_num = ?');
      args.add(catNum);
    }
    if (liste != null && liste.isNotEmpty) {
      conditions.add('liste = ?');
      args.add(liste);
    }
    if (type != null && type.isNotEmpty) {
      conditions.add('type = ?');
      args.add(type);
    }
    if (statut != null && statut.isNotEmpty) {
      conditions.add('statut = ?');
      args.add(statut);
    }
    if (favorisOnly) {
      conditions.add('is_favori = 1');
    }

    final where =
        conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';
    final sql =
        'SELECT * FROM medicaments $where ORDER BY nom_marque LIMIT $limit OFFSET $offset';

    final maps = await db.rawQuery(sql, args);
    return maps.map((m) => Medicament.fromMap(m)).toList();
  }

  Future<int> countMedicaments({
    String query = '',
    String? catNum,
    String? liste,
    String? type,
    String? statut,
    bool favorisOnly = false,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (query.isNotEmpty) {
      conditions.add(
          '(nom_marque LIKE ? OR dci LIKE ? OR code LIKE ? OR laboratoire LIKE ?)');
      final q = '%${query.toUpperCase()}%';
      args.addAll([q, q, q, q]);
    }
    if (catNum != null && catNum.isNotEmpty) {
      conditions.add('cat_num = ?');
      args.add(catNum);
    }
    if (liste != null && liste.isNotEmpty) {
      conditions.add('liste = ?');
      args.add(liste);
    }
    if (type != null && type.isNotEmpty) {
      conditions.add('type = ?');
      args.add(type);
    }
    if (statut != null && statut.isNotEmpty) {
      conditions.add('statut = ?');
      args.add(statut);
    }
    if (favorisOnly) {
      conditions.add('is_favori = 1');
    }

    final where =
        conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';
    final result = await db
        .rawQuery('SELECT COUNT(*) FROM medicaments $where', args);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT cat_num, cat_name, COUNT(*) as count 
      FROM medicaments 
      GROUP BY cat_num, cat_name 
      ORDER BY cat_num
    ''');
    return result;
  }

  Future<Medicament?> getMedicamentById(int id) async {
    final db = await database;
    final maps = await db.query('medicaments', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Medicament.fromMap(maps.first);
  }

  Future<void> toggleFavori(int id, bool isFavori) async {
    final db = await database;
    await db.update(
      'medicaments',
      {'is_favori': isFavori ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Medicament?> findByBarcode(String barcode) async {
    final db = await database;
    // Search in num_enr or code fields
    final maps = await db.query(
      'medicaments',
      where: 'num_enr LIKE ? OR code LIKE ?',
      whereArgs: ['%$barcode%', '%$barcode%'],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Medicament.fromMap(maps.first);
  }

  Future<List<Medicament>> getFavoris() async {
    return searchMedicaments(favorisOnly: true, limit: 500);
  }
}
