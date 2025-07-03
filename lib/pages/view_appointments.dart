import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/appointment_service.dart';
import '../models/appointment_model.dart';
import '../models/hospital.dart';
import 'createAppointment.dart';

class ViewAppointmentsScreen extends StatefulWidget {
  const ViewAppointmentsScreen({super.key});

  @override
  _ViewAppointmentsScreenState createState() => _ViewAppointmentsScreenState();
}

class _ViewAppointmentsScreenState extends State<ViewAppointmentsScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  late Future<List<Appointment>> _appointmentsFuture;
  String? _userEmail;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Confirmed',
    'Pending',
    'Cancelled',
    'Completed'
  ];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userEmail = user.email;
      _appointmentsFuture =
          _appointmentService.getAppointmentsByEmail(_userEmail!);
    } else {
      _appointmentsFuture = Future.value([]);
    }
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    try {
      await _appointmentService.deleteAppointment(appointmentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment deleted successfully')),
      );
      setState(() {
        _loadAppointments();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete appointment: ${e.toString()}')),
      );
    }
  }

  void _confirmDelete(String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this appointment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAppointment(appointmentId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _editAppointment(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HospitalBookingScreen(
          appointmentToEdit: appointment,
        ),
      ),
    ).then((_) {
      setState(() {
        _loadAppointments();
      });
    });
  }

  List<Appointment> _filterAppointments(List<Appointment> appointments) {
    if (_selectedFilter == 'All') return appointments;
    return appointments
        .where((appointment) =>
            appointment.status.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        centerTitle: true,
      ),
      body: _userEmail == null
          ? const Center(
              child: Text('Please sign in to view your appointments'),
            )
          : Column(
              children: [
                // Status Filter Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    decoration: InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                    ),
                    items: _filterOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _loadAppointments();
                      });
                    },
                    child: FutureBuilder<List<Appointment>>(
                      future: _appointmentsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final appointments =
                            _filterAppointments(snapshot.data ?? []);

                        if (appointments.isEmpty) {
                          return const Center(
                            child: Text('No appointments found'),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = appointments[index];
                            return _buildAppointmentCard(appointment);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    appointment.hospitalName,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editAppointment(appointment),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(appointment.id!),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              appointment.doctorName,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16.0),
                const SizedBox(width: 8.0),
                Text(appointment.date),
                const SizedBox(width: 16.0),
                const Icon(Icons.access_time, size: 16.0),
                const SizedBox(width: 8.0),
                Text(appointment.time),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16.0),
                const SizedBox(width: 8.0),
                Text('RM${appointment.amount.toStringAsFixed(2)}'),
                const SizedBox(width: 16.0),
                const Icon(Icons.payment, size: 16.0),
                const SizedBox(width: 8.0),
                Text(appointment.isPaid ? 'Paid' : 'Unpaid'),
                const Spacer(),
                Chip(
                  backgroundColor: _getStatusColor(appointment.status),
                  label: Text(
                    appointment.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(appointment.notes),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
