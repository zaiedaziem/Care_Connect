class Appointment {
  final String doctorName;
  final String hospitalName;
  final String time;
  final String date;
  final String status; // 'Upcoming', 'Completed', 'Cancelled'
  final String imageUrl;

  Appointment({
    required this.doctorName,
    required this.hospitalName,
    required this.time,
    required this.date,
    required this.status,
    required this.imageUrl,
  });
}
