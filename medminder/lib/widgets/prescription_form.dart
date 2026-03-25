
import 'package:flutter/material.dart';
import 'package:medminder/models/prescription.dart';
import 'package:medminder/repositories/prescription_repository.dart';

class PrescriptionForm extends StatefulWidget {
  const PrescriptionForm({super.key});

  @override
  State<PrescriptionForm> createState() => _PrescriptionFormState();
}

class _PrescriptionFormState extends State<PrescriptionForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String prescriptionNumber = '';
  String pharmacyName = '';
  DateTime lastFilledDate = DateTime.now();
  int supplyDays = 30;
  int noticeDays = 5;
  String deliveryMethod = 'Pickup';

  void _save() async{
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Handle form submission, e.g., save to database
      final prescription = Prescription(
        name: name,
        prescriptionNumber: prescriptionNumber,
        pharmacyName: pharmacyName,
        lastFilledDate: lastFilledDate,
        supplyDays: supplyDays,
        noticeDays: noticeDays,
        deliveryMethod: deliveryMethod
      );

      await PrescriptionRepository.addPrescription(prescription);
      Navigator.of(context).pop(true); // Return true to indicate a new prescription was added
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Prescription Name'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                initialValue: prescriptionNumber,
                decoration: const InputDecoration(labelText: 'Prescription Number'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a prescription number' : null,
                onSaved: (value) => prescriptionNumber = value!,
              ),
              TextFormField(
                initialValue: pharmacyName,
                decoration: const InputDecoration(labelText: 'Pharmacy Name'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a pharmacy name' : null,
                onSaved: (value) => pharmacyName = value!,
              ),
              TextFormField(
                initialValue: supplyDays.toString(),
                decoration: const InputDecoration(labelText: 'Supply Days'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || int.tryParse(value) == null ? 'Please enter a valid number' : null,
                onSaved: (value) => supplyDays = int.parse(value!),
              ),
              TextFormField(
                initialValue: noticeDays.toString(),
                decoration: const InputDecoration(labelText: 'Notice Days'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || int.tryParse(value) == null ? 'Please enter a valid number' : null,
                onSaved: (value) => noticeDays = int.parse(value!),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Delivery Method'),
                initialValue: deliveryMethod,
                onChanged: (value) => setState(() => deliveryMethod = value!),
                onSaved: (value) => deliveryMethod = value!,
                validator: (value) => value == null || value.isEmpty ? 'Please select a delivery method' : null,
                items: const [
                  DropdownMenuItem(value: 'Pickup', child: Text('Pickup')),
                  DropdownMenuItem(value: 'Mail', child: Text('Mail')),
                ],
              ),
              TextFormField(
                initialValue: lastFilledDate.toLocal().toString().split(' ')[0],
                decoration: const InputDecoration(labelText: 'Last Filled Date'),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: lastFilledDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => lastFilledDate = picked);
                  }
                },
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // Return false to indicate no new prescription was added
                    child: const Text('Cancel'),
                  ),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Prescription'),
                ),
            ]
    )]
          )
        ),
      )
    ); 
  }
}