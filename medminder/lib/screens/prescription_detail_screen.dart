import 'package:flutter/material.dart';
import 'package:medminder/models/prescription.dart';
import 'package:medminder/repositories/prescription_repository.dart';

class PrescriptionDetailScreen extends StatefulWidget {
  final Prescription prescription;

  const PrescriptionDetailScreen({super.key, required this.prescription});

  @override
  State<PrescriptionDetailScreen> createState() => _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  late Prescription prescription;

  @override
  void initState() {
    super.initState();
    prescription = widget.prescription;
  }

  // reset last filled date to today
  Future<void> markAsRefilled() async {
    setState(() {
      prescription.lastFilledDate = DateTime.now();
    });
    await PrescriptionRepository.updatePrescription(prescription);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Marked as refilled!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 95, 148),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          prescription.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // prescription info card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.numbers, "Prescription Number", prescription.prescriptionNumber ?? "N/A"),
                    const Divider(),
                    _buildDetailRow(Icons.local_pharmacy, "Pharmacy", prescription.pharmacyName ?? "N/A"),
                    const Divider(),
                    _buildDetailRow(Icons.local_shipping, "Delivery Method", prescription.deliveryMethod),
                    const Divider(),
                    _buildDetailRow(Icons.calendar_today, "Last Filled", prescription.lastFilledDate.toLocal().toString().split(' ')[0]),
                    const Divider(),
                    _buildDetailRow(Icons.medication, "Supply Days", "${prescription.supplyDays} days"),
                    const Divider(),
                    _buildDetailRow(Icons.notifications, "Notice Days", "${prescription.noticeDays} days"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // refill info card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.event, "Next Fill Date", prescription.nextFillDate.toLocal().toString().split(' ')[0]),
                    const Divider(),
                    _buildRefillRow(prescription),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // mark as refilled button
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
                  backgroundColor: const Color.fromARGB(255, 30, 95, 148),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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