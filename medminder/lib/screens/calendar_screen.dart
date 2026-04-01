import 'package:flutter/material.dart';
import 'package:medminder/models/prescription.dart';
import 'package:medminder/repositories/prescription_repository.dart';
import 'package:medminder/screens/prescription_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Prescription> prescriptions = [];
  DateTime focusedMonth = DateTime.now();
  DateTime? selectedDay;

  @override
  void initState() {
    super.initState();
    loadPrescriptions();
  }

  Future<void> loadPrescriptions() async {
    final loaded = await PrescriptionRepository.getPrescriptions();
    setState(() {
      prescriptions = loaded;
    });
  }

  // get refills for a specific day
  List<Prescription> getRefillsForDay(DateTime day) {
    return prescriptions.where((p) {
      final fill = p.nextFillDate;
      return fill.year == day.year &&
          fill.month == day.month &&
          fill.day == day.day;
    }).toList();
  }

  // get all refills for the current focused month
  List<Prescription> getRefillsForMonth() {
    return prescriptions.where((p) {
      return p.nextFillDate.year == focusedMonth.year &&
          p.nextFillDate.month == focusedMonth.month;
    }).toList();
  }

  // red if refill is in 7 days or less, green if not
  Color getDotColor(DateTime day) {
    final refills = getRefillsForDay(day);
    for (var p in refills) {
      if (p.daysUntilNextFill <= 7) return Colors.red;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final monthRefills = getRefillsForMonth();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 95, 148),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Calendar",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // calendar card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // month navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left,
                              color: Color.fromARGB(255, 30, 95, 148)),
                          onPressed: () {
                            setState(() {
                              focusedMonth = DateTime(
                                  focusedMonth.year, focusedMonth.month - 1);
                              selectedDay = null;
                            });
                          },
                        ),
                        Text(
                          "${_monthName(focusedMonth.month)} ${focusedMonth.year}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 30, 95, 148),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right,
                              color: Color.fromARGB(255, 30, 95, 148)),
                          onPressed: () {
                            setState(() {
                              focusedMonth = DateTime(
                                  focusedMonth.year, focusedMonth.month + 1);
                              selectedDay = null;
                            });
                          },
                        ),
                      ],
                    ),
                    // day headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                          .map((d) => Text(d,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 12)))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    _buildCalendarGrid(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // list of refills for this month
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Refills in ${_monthName(focusedMonth.month)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 30, 95, 148),
                      ),
                    ),
                    const Divider(),
                    // no refills this month
                    monthRefills.isEmpty
                        ? const Text(
                            "No refills this month.",
                            style: TextStyle(color: Colors.grey),
                          )
                        : Column(
                            children: monthRefills.map((p) {
                              final isHighlighted = selectedDay != null &&
                                  p.nextFillDate.year == selectedDay!.year &&
                                  p.nextFillDate.month == selectedDay!.month &&
                                  p.nextFillDate.day == selectedDay!.day;
                              return GestureDetector(
                                onTap: () {
                                  // tap to go to detail screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PrescriptionDetailScreen(
                                              prescription: p),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    // highlight if selected day matches
                                    border: isHighlighted
                                        ? Border.all(
                                            color: const Color.fromARGB(
                                                255, 30, 95, 148),
                                            width: 2)
                                        : null,
                                    borderRadius: BorderRadius.circular(10),
                                    color: isHighlighted
                                        ? const Color.fromARGB(20, 30, 95, 148)
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.medication,
                                          color:
                                              Color.fromARGB(255, 30, 95, 148)),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          Text(
                                            "Refill on: ${p.nextFillDate.toLocal().toString().split(' ')[0]}",
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startingWeekday = firstDay.weekday % 7; // % 7 makes it start on sunday

    List<Widget> dayCells = [];

    // blank spaces before day 1
    for (int i = 0; i < startingWeekday; i++) {
      dayCells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month, day);
      final isSelected = selectedDay != null &&
          selectedDay!.year == date.year &&
          selectedDay!.month == date.month &&
          selectedDay!.day == date.day;
      final isToday = date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;
      final hasRefill = getRefillsForDay(date).isNotEmpty;
      final dotColor = getDotColor(date);

      dayCells.add(
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDay = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(255, 30, 95, 148)
                  : isToday
                      ? const Color.fromARGB(50, 30, 95, 148)
                      : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$day",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                if (hasRefill)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: dayCells,
    );
  }

  String _monthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }
}