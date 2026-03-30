import 'package:flutter/material.dart';
import 'package:medminder/models/prescription.dart';
import 'package:medminder/repositories/prescription_repository.dart';
import 'package:medminder/widgets/prescription_form.dart';
import 'package:medminder/screens/calendar_screen.dart';
import 'package:medminder/screens/prescription_detail_screen.dart';
import 'package:medminder/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //State and list for search field and its results
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  List<Prescription> filteredPrescriptions = [];

  List<Prescription> prescriptions = [];
  bool isLoading = true;

  Future<void> loadPrescriptions() async{

    setState(() { isLoading = true; });

    final loaded = await PrescriptionRepository.getPrescriptions();
    setState(() {
      prescriptions = loaded;
      filteredPrescriptions = loaded;
      isLoading = false;
    });

  }

  //Prescitpion Add form
  Future<void> _showPrescriptionFormDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrescriptionForm(),
          ),
        ),
      ),
    );

    if (!mounted) return;
    if (result == true) await loadPrescriptions();
  }

//Search Logic
void updateSearch(String query) {
  setState(() {
    searchQuery = query.toLowerCase();

    filteredPrescriptions = prescriptions.where((p) {
      return p.name.toLowerCase().contains(searchQuery);
    }).toList();

  });
}

//Confirm Prescription Deletion Modal
Future<bool> confirmDelete(Prescription prescription) async{
  
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Delete ${prescription.name}?"),
      content: Text("This action cannot be undone."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text("No"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text("Yes"),
        ),
      ],
    ),
  );

  return result ?? false;
}


  @override
  void initState(){
    super.initState();
    loadPrescriptions();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Nav Bar
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 95, 148),
        titleSpacing: 0,
        title: Row(
          children: [
            // Search Bar Placeholder
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: searchController,
                  onChanged: updateSearch,
                  decoration: const InputDecoration(
                    hintText: "Enter Prescription Name..",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Calendar Button
            IconButton(
              icon: const Icon(Icons.calendar_today, size: 36),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CalendarScreen(),
                  ),
                );
              },
            )
          ],
        ),
      ),

      //Main body
      body: Builder(
        builder: (context) {

          if (isLoading) return const Center(child: CircularProgressIndicator());
          if (prescriptions.isEmpty) return const Center(child: Text('No prescriptions match your search'));

          return ListView.builder(
            itemCount: filteredPrescriptions.length,
            itemBuilder: (context, index){

              final prescription = filteredPrescriptions[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 14, 74, 102),
                    child: Text(
                      prescription.name[0],
                      style: const TextStyle(color: Color.fromARGB(255, 223, 204, 204)),
                    ),
                  ),
                  title: Text(
                    prescription.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Next fill in ${prescription.daysUntilNextFill} days",
                    style: TextStyle(
                      color: prescription.shouldNotify ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: (){
                    // Navigate to prescription detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrescriptionDetailScreen(prescription: prescription),
                         ),
                         );                 
                  },
                  //Deletion Button
                  trailing: 
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {

                            final confirmed = await confirmDelete(prescription);

                            if (!confirmed) return;
            
                            //Run deletion logic if confirmed
                            final deletedCount = await PrescriptionRepository.deletePrescription(prescription.id!);

                            if (deletedCount > 0) {
                              // Cancel scheduled notification for the deleted prescription
                              await NotificationService().cancelNotification(prescription.id!);
                              
                              // Refresh UI 
                              setState(() {
                                prescriptions.removeWhere((p) => p.id == prescription.id);
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Deleted successfully')),
                              );
                            }
                          },
                        )
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _showPrescriptionFormDialog,
      ),
    );
  }
}
