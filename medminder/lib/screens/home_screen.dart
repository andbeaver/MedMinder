import 'package:flutter/material.dart';
import 'package:medminder/models/prescription.dart';
import 'package:medminder/repositories/prescription_repository.dart';
import 'package:medminder/widgets/prescription_form.dart';
import 'package:medminder/screens/calendar_screen.dart';
import 'package:medminder/screens/prescription_detail_screen.dart';
import 'package:medminder/services/notification_service.dart';
import 'package:medminder/theme/app_styles.dart';


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
          child: Text("Cancel"),
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

Future<void> _showDataInfoDialog() async {
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Your data"),
      content: const Text(
        "Your prescriptions are stored on this device only.\n"
        "No account is required.\n"
        "Notifications are local to your device.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}


  @override
  void initState(){
    super.initState();
    loadPrescriptions();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,

      //Nav bar
      appBar: AppBar(
        backgroundColor: AppColors.lightPrimary,
        elevation: 4,
        toolbarHeight: 68,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), 
          ),
        ),
        titleSpacing: 16,
        title: Row(
          children: [

            Image.asset(
              'assets/icon/iconTransparent.png',
              width: 36,
              height: 36,

            ),
            const SizedBox(width: 12),

            const Text(
              "MedMinder",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: _showDataInfoDialog,
          tooltip: "Data info",
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CalendarScreen(),
              ),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.calendar_month, color: Colors.white, size: 36,),
              SizedBox(height: 4,)
            ],
          ),
        ),
        const SizedBox(width: 10),
      ],
    ),

      //Main body
      body: Container(
        decoration: AppGradients.scaffoldBackground(context),
        child: Container(
          decoration: AppGradients.leftGlow(AppColors.primary),
          child: Container(
            decoration: AppGradients.rightGlow(AppColors.primary),
            child: SafeArea(
              child: Builder(
                builder: (context) {

                  if (isLoading) return const Center(child: CircularProgressIndicator());
                  if (prescriptions.isEmpty) {
                    return const Center(child: Text('No prescriptions yet'));
                  }
                  if (filteredPrescriptions.isEmpty) {
                    return const Center(child: Text('No prescriptions match your search'));
                  }

                return Column(
                  children: [
                    //Search Box
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14), 
                        side: const BorderSide(
                            color: Colors.black, 
                            width: 1.5,         
                          ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                onChanged: updateSearch,
                                decoration: const InputDecoration(
                                  hintText: "Search your prescriptions",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Prescription List
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredPrescriptions.length,
                        itemBuilder: (context, index) {
                          final prescription = filteredPrescriptions[index];

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                            shape: prescription.shouldNotify
                                ? RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(color: AppColors.warning, width: 2.5),
                                  )
                                : RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(
                                        color: AppColors.primary, width: 1.5),
                                  ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color.fromARGB(255, 14, 74, 102),
                                child: Text(
                                  prescription.name[0],
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 223, 204, 204)),
                                ),
                              ),
                              title: Text(
                                prescription.name,
                                style: AppTextStyles.cardTitle,
                              ),
                              subtitle: Text(
                                prescription.isOverdue
                                    ? "Overdue by ${prescription.daysUntilNextFill.abs()} days"
                                    : "Next fill in ${prescription.daysUntilNextFill} days",
                                style: AppTextStyles.cardSubtitle.copyWith(
                                  color: prescription.isOverdue || prescription.shouldNotify
                                      ? AppColors.warning
                                      : AppColors.filled,
                                ),
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PrescriptionDetailScreen(prescription: prescription),
                                  ),
                                );
                                if (!mounted) return;
                                await loadPrescriptions();
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirmed = await confirmDelete(prescription);
                                  if (!mounted) return;
                                  if (!confirmed) return;

                                  final deletedCount =
                                      await PrescriptionRepository.deletePrescription(
                                          prescription.id!);

                                  if (deletedCount > 0) {
                                    await NotificationService()
                                        .cancelNotification(prescription.id!);
                                    if (!mounted) return;
                                    setState(() {
                                      prescriptions.removeWhere(
                                          (p) => p.id == prescription.id);
                                    });
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Deleted successfully')),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),             
          ),
        )
      )
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _showPrescriptionFormDialog,
      child: const Icon(Icons.add),
    ),
  );
}
}
