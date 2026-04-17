class Prescription {
  int? id;
  String name;
  String? prescriptionNumber;
  String? pharmacyName;
  DateTime lastFilledDate;
  int supplyDays;
  int noticeDays;
  String deliveryMethod;

  DateTime get nextFillDate {
      return lastFilledDate.add(Duration(days: supplyDays));
  }

  int get daysUntilNextFill {
    return nextFillDate.difference(DateTime.now()).inDays;
  }

  bool get isOverdue => daysUntilNextFill < 0;

  bool get shouldNotify => daysUntilNextFill <= noticeDays;

  Prescription({
    this.id, 
    required this.name, 
    this.prescriptionNumber, 
    required this.pharmacyName, 
    required this.lastFilledDate, 
    required this.supplyDays, 
    required this.noticeDays, 
    required this.deliveryMethod
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'prescriptionNumber': prescriptionNumber,
      'pharmacyName': pharmacyName,
      'lastFilledDate': lastFilledDate.toIso8601String(),
      'supplyDays': supplyDays,
      'noticeDays': noticeDays,
      'deliveryMethod': deliveryMethod,
    };
  }

  static Prescription fromMap(Map<String, dynamic> map) {
    return Prescription(
      id: map['id'],
      name: map['name'],
      prescriptionNumber: map['prescriptionNumber'],
      pharmacyName: map['pharmacyName'],
      lastFilledDate: DateTime.parse(map['lastFilledDate']),
      supplyDays: map['supplyDays'],
      noticeDays: map['noticeDays'],
      deliveryMethod: map['deliveryMethod'],
    );
  }

  // Not sure if this is needed, but it can be helpful for debugging
  @override
  String toString() {
    return 'Prescription{id: $id, name: $name, prescriptionNumber: $prescriptionNumber, pharmacyName: $pharmacyName, lastFilledDate: $lastFilledDate, supplyDays: $supplyDays, noticeDays: $noticeDays, deliveryMethod: $deliveryMethod}';
  }

  
}

// Future<void> insertPrescription(Prescription prescription) async {
//   // Get a reference to the database.
//   final db = await database;

//   await db.insert(
//     'prescriptions',
//     prescription.toMap(),
//     conflictAlgorithm: ConflictAlgorithm.replace,
//   );
