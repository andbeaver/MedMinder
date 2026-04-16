import 'package:flutter/material.dart';
import 'package:medminder/models/prescription.dart';
import 'package:medminder/repositories/prescription_repository.dart';
import 'package:medminder/theme/app_styles.dart';
import 'package:medminder/widgets/gradient_body.dart';


class PrescriptionDetailScreen extends StatefulWidget {
  final Prescription prescription;

  const PrescriptionDetailScreen({super.key, required this.prescription});

  @override
  State<PrescriptionDetailScreen> createState() => _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  late Prescription prescription;

 //Text Editing Controllers for Update funciontality
  late TextEditingController presciptionNumberController = 
        TextEditingController(text: prescription.prescriptionNumber); 
  bool isEditingNumber = false;    

  late TextEditingController pharmacyController =
      TextEditingController(text: prescription.pharmacyName);
  bool isEditingPharmacy = false;

  late TextEditingController deliveryController =
      TextEditingController(text: prescription.deliveryMethod);      
  bool isEditingDelivery = false;

  late TextEditingController supplyDaysController =
      TextEditingController(text: prescription.supplyDays.toString());
  bool isEditingSupplyDays = false;

  late TextEditingController noticeDaysController =
      TextEditingController(text: prescription.noticeDays.toString()); 
  bool isEditingNoticeDays = false;


  @override
  void initState() {
    super.initState();
    prescription = widget.prescription;
    
    TextEditingController(text: prescription.prescriptionNumber);
   
  }

  // reset last filled date to today
  Future<void> markAsRefilled() async {
    setState(() {
      prescription.lastFilledDate = DateTime.now();
    });
    await PrescriptionRepository.updatePrescription(prescription);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Marked as refilled!")),
    );

  }


  //Helper for date picker
  Future<void> _pickLastFilledDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: prescription.lastFilledDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) return;

    setState(() {
      prescription.lastFilledDate = selectedDate;
    });

    await PrescriptionRepository.updatePrescription(prescription);
  }



@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    extendBodyBehindAppBar: true,

    appBar: AppBar(
      backgroundColor: AppColors.lightPrimary,
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 4,
      toolbarHeight: 68,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20), 
        ),
        ),
      title: Text(
        prescription.name,
        style: const TextStyle(color: Colors.white),
      ),
    ),

   
  body: GradientBody(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ───────────────────────
        // Prescription info card
        // ───────────────────────
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildEditableDetailRow(
                  icon: Icons.numbers,
                  label: "Prescription Number",
                  controller: presciptionNumberController,
                  isEditing: isEditingNumber,
                  onEdit: () {
                    setState(() => isEditingNumber = true);
                  },
                  onCancel: () {
                    setState(() {
                      presciptionNumberController.text =
                          prescription.prescriptionNumber ?? "";
                      isEditingNumber = false;
                    });
                  },
                  onSave: () async {
                    prescription.prescriptionNumber =
                        presciptionNumberController.text;
                    await PrescriptionRepository.updatePrescription(prescription);
                    setState(() => isEditingNumber = false);
                  },
                ),

                const Divider(),

                _buildEditableDetailRow(
                  icon: Icons.local_pharmacy,
                  label: "Pharmacy",
                  controller: pharmacyController,
                  isEditing: isEditingPharmacy,
                  onEdit: () {
                    setState(() => isEditingPharmacy = true);
                  },
                  onCancel: () {
                    setState(() {
                      pharmacyController.text =
                          prescription.pharmacyName ?? "";
                      isEditingPharmacy = false;
                    });
                  },
                  onSave: () async {
                    prescription.pharmacyName = pharmacyController.text;
                    await PrescriptionRepository.updatePrescription(prescription);
                    setState(() => isEditingPharmacy = false);
                  },
                ),

                const Divider(),

                _buildEditableDetailRow(
                  icon: Icons.local_shipping,
                  label: "Delivery",
                  controller: deliveryController,
                  isEditing: isEditingDelivery,
                  onEdit: () {
                    setState(() => isEditingDelivery = true);
                  },
                  onCancel: () {
                    setState(() {
                      deliveryController.text =
                          prescription.deliveryMethod;
                      isEditingDelivery = false;
                    });
                  },
                  onSave: () async {
                    prescription.deliveryMethod = deliveryController.text;
                    await PrescriptionRepository.updatePrescription(prescription);
                    setState(() => isEditingDelivery = false);
                  },
                ),

                const Divider(),

                _buildDatePickerRow(
                  Icons.calendar_today,
                  "Last Filled",
                  prescription.lastFilledDate,
                  _pickLastFilledDate,
                ),

                const Divider(),

                _buildEditableDetailRow(
                  icon: Icons.medication,
                  label: "Supply Days",
                  controller: supplyDaysController,
                  isEditing: isEditingSupplyDays,
                  onEdit: () {
                    setState(() => isEditingSupplyDays = true);
                  },
                  onCancel: () {
                    setState(() {
                      supplyDaysController.text =
                          prescription.supplyDays.toString();
                      isEditingSupplyDays = false;
                    });
                  },
                  onSave: () async {
                    final parsed = int.tryParse(supplyDaysController.text);
                    if (parsed == null || parsed <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a valid number above 0"),
                        ),
                      );
                      return;
                    }
                    prescription.supplyDays = parsed;
                    await PrescriptionRepository.updatePrescription(prescription);
                    setState(() => isEditingSupplyDays = false);
                  },
                ),

                const Divider(),

                _buildEditableDetailRow(
                  icon: Icons.notifications,
                  label: "Notice Days",
                  controller: noticeDaysController,
                  isEditing: isEditingNoticeDays,
                  onEdit: () {
                    setState(() => isEditingNoticeDays = true);
                  },
                  onCancel: () {
                    setState(() {
                      noticeDaysController.text =
                          prescription.noticeDays.toString();
                      isEditingNoticeDays = false;
                    });
                  },
                  onSave: () async {
                    final parsed = int.tryParse(noticeDaysController.text);
                    if (parsed == null || parsed <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a valid number above 0"),
                        ),
                      );
                      return;
                    }
                    prescription.noticeDays = parsed;
                    await PrescriptionRepository.updatePrescription(prescription);
                    setState(() => isEditingNoticeDays = false);
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.event,
                  "Next Fill Date",
                  prescription.nextFillDate
                      .toLocal()
                      .toString()
                      .split(' ')[0],
                ),
                const Divider(),
                _buildRefillRow(prescription),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: markAsRefilled,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text(
              "Mark as Refilled",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
           
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
            ),

          ),
        ),
      ],
    ),
  ),
    
  );

}
//Static info row
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 30, 95, 148), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

//Editiable info row
  Widget _buildEditableDetailRow({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onSave,
    required VoidCallback onCancel,
  }) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: const Color.fromARGB(255, 30, 95, 148), size: 24),
        const SizedBox(width: 12),

        /// Label
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),

        /// Value / Editor
        Expanded(
          flex: 4,
          child: isEditing
              ? TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: UnderlineInputBorder(),
                  ),
                )
              : Text(
                  controller.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),

        const SizedBox(width: 8),

        /// Action icons
        isEditing
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: onSave,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onCancel,
                  ),
                ],
              )
            : IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: onEdit,
              ),
      ],
    ),
  );
}

//Date picker row for last filled date
  Widget _buildDatePickerRow(
    IconData icon,
    String label,
    DateTime value,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 30, 95, 148), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          Text(
            value.toLocal().toString().split(' ')[0],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }


  // refill countdown with color
  Widget _buildRefillRow(Prescription prescription) {
    Color statusColor;
    if (prescription.daysUntilNextFill <= prescription.noticeDays) {
      statusColor = Colors.red;
    } else if (prescription.daysUntilNextFill <= prescription.noticeDays * 2) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.timer, color: statusColor, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Days Until Refill",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          Text(
            "${prescription.daysUntilNextFill} days",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}