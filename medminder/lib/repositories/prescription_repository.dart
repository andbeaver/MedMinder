import 'package:medminder/models/prescription.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PrescriptionRepository {

  static Future<Database> _getDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'medminder.db');

    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS  prescriptions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            prescriptionNumber TEXT,
            pharmacyName TEXT,
            lastFilledDate TEXT,
            supplyDays INTEGER,
            noticeDays INTEGER,
            deliveryMethod TEXT
          )
        ''');

        await db.insert('prescriptions',{
        'name': 'Test Prescription',
        'prescriptionNumber': '12345',
        'pharmacyName': 'Test Pharmacy',
        'lastFilledDate': DateTime.now().toIso8601String(),
        'supplyDays': 30,
        'noticeDays': 5,
        'deliveryMethod': 'Pickup',
      });

      await db.insert('prescriptions',{
        'name': 'Test Prescription 2',
        'prescriptionNumber': 'ht346',
        'pharmacyName': 'Lawtons',
        'lastFilledDate': DateTime.now().toIso8601String(),
        'supplyDays': 90,
        'noticeDays': 14,
        'deliveryMethod': 'Mail',
      });

      },
    );

    return database;
  }

  // Get all prescriptions from the database
  static Future<List<Prescription>> getPrescriptions() async {
    try {
      final db = await _getDatabase();
      final result = await db.query('prescriptions');
      return result.map((map) => Prescription.fromMap(map)).toList();
    } catch (e, st) {
      print('Error querying prescriptions: $e');
      print(st);
      return <Prescription>[];
    }
  }

  // Insert a new prescription into the database
  static Future<int> addPrescription(Prescription prescription) async {
    final db = await _getDatabase();
    return await db.insert('prescriptions', prescription.toMap());
  }

  // Update a prescription
  static Future<int> updatePrescription(Prescription prescription) async {
    final db = await _getDatabase();
    return await db.update(
      'prescriptions',
      prescription.toMap(),
      where: 'id = ?',
      whereArgs: [prescription.id],
    );
  }

  // Delete a prescription
  static Future<int> deletePrescription(int id) async {
    final db = await _getDatabase();
    return await db.delete(
      'prescriptions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
}