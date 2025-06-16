import 'package:flutter/material.dart';
import '../models/appointment_model.dart';

class ViewAppointmentPage extends StatefulWidget {
  const ViewAppointmentPage({super.key});

  @override
  State<ViewAppointmentPage> createState() => _ViewAppointmentPageState();
}

class _ViewAppointmentPageState extends State<ViewAppointmentPage> {
  int selectedDateIndex = 0;
  int selectedTabIndex = 0; // 0: Upcoming, 1: Completed, 2: Cancelled

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final ScrollController _dateScrollController = ScrollController();

  // Sample appointment data
  final Map<int, List<ViewAppointment>> appointmentsByDate = {
    8: [
      ViewAppointment(
        doctorName: 'Dr Luke',
        hospitalName: 'Gleanagles Hospital',
        time: '11:30AM',
      ),
    ],
    9: [
      ViewAppointment(
        doctorName: 'Dr Marcus',
        hospitalName: 'Gleanagles Hospital',
        time: '2:00PM',
      ),
      ViewAppointment(
        doctorName: 'Dr Sarah',
        hospitalName: 'Gleanagles Hospital',
        time: '3:30PM',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title:
            const Text("My Appointment", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Date Picker Row
          SizedBox(
            height: 100,
            child: Scrollbar(
              controller: _dateScrollController,
              thumbVisibility: true,
              radius: const Radius.circular(10),
              thickness: 6,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _dateScrollController,
                padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 12), // Add bottom padding for space
                child: Row(
                  children: List.generate(31, (index) {
                    int date = index + 1;
                    String day = days[index % 7];
                    bool isSelected = selectedDateIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDateIndex = index;
                        });
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              date.toString(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              day,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          // Tab Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Upcoming', 'Completed', 'Cancelled']
                .asMap()
                .entries
                .map((entry) {
              int idx = entry.key;
              String label = entry.value;
              bool isSelected = selectedTabIndex == idx;
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedTabIndex = idx;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.black : Colors.grey[300],
                ),
                child: Text(label,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black)),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Appointment Cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),

              // With this:
              children: (appointmentsByDate[selectedDateIndex + 1] ?? [])
                  .map((appointment) {
                return Card(
                  color: Colors.grey[300],
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Side: Doctor and Hospital Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.doctorName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(appointment.hospitalName),
                            ],
                          ),
                        ),

                        // Right Side: Time + Buttons
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(appointment.time),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle View
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                  ),
                                  child: const Text('View'),
                                ),
                                const SizedBox(width: 5),
                                OutlinedButton(
                                  onPressed: () {
                                    // Handle Cancel
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
