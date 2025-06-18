import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/doctor_service.dart'; // Adjust the path accordingly

class DoctorListPage extends StatelessWidget {
  final DoctorService _doctorService = DoctorService();

  DoctorListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor List'),
      ),
      body: StreamBuilder<List<Doctor>>(
        stream: _doctorService.getAllDoctorsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final doctors = snapshot.data;

          if (doctors == null || doctors.isEmpty) {
            return const Center(child: Text('No doctors found.'));
          }

          return ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(doctor.imageUrl),
                  ),
                  title: Text(doctor.name),
                  subtitle: Text(doctor.specialty),
                  trailing: Text('#${doctor.id}'),
                  onTap: () {
                    // Navigate to doctor detail or edit page (optional)
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
