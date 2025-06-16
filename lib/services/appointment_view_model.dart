// import 'package:flutter/material.dart';
// import '../models/appointment_model.dart';

// class AppointmentViewModel extends ChangeNotifier {
//   final List<Appointment> _appointments = [
//     Appointment(
//       doctorName: "Dr Marcus",
//       hospitalName: "Gleaneagles Hospital",
//       time: "11:30AM",
//       date: "8", // could use ISO date in real app
//       status: "Upcoming",
//       imageUrl: "https://i.imgur.com/fakeMarcus.jpg",
//     ),
//     Appointment(
//       doctorName: "Dr Maria",
//       hospitalName: "KPJ Ampang Puteri",
//       time: "12:30PM",
//       date: "9",
//       status: "Upcoming",
//       imageUrl: "https://i.imgur.com/fakeMaria.jpg",
//     ),
//     Appointment(
//       doctorName: "Dr Luke",
//       hospitalName: "Gleaneagles Hospital",
//       time: "11:30AM",
//       date: "8",
//       status: "Completed",
//       imageUrl: "https://i.imgur.com/fakeLuke.jpg",
//     ),
//   ];

//   String _selectedDate = "8";
//   String _selectedTab = "Upcoming";

//   List<Appointment> get filteredAppointments => _appointments
//       .where((a) => a.date == _selectedDate && a.status == _selectedTab)
//       .toList();

//   String get selectedDate => _selectedDate;
//   String get selectedTab => _selectedTab;

//   void setDate(String date) {
//     _selectedDate = date;
//     notifyListeners();
//   }

//   void setTab(String tab) {
//     _selectedTab = tab;
//     notifyListeners();
//   }

//   void cancelAppointment(Appointment appointment) {
//     appointment.status = "Cancelled";
//     notifyListeners();
//   }
// }
