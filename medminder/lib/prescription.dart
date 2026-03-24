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

  bool get shouldNotify => daysUntilNextFill <= noticeDays;

  Prescription({
    this.id, 
    required this.name, 
    required this.prescriptionNumber, 
    required this.pharmacyName, 
    required this.lastFilledDate, 
    required this.supplyDays, 
    required this.noticeDays, 
    required this.deliveryMethod
    });
}