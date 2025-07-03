import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/appointment_service.dart';
import '../models/appointment_model.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  late Future<List<Appointment>> _appointmentsFuture;
  String _selectedFilter = 'All';

  static const _filterOptions = [
    'All',
    'Pending',
    'Confirmed',
    'Cancelled',
    'Completed'
  ];
  static const _primaryColor = Color(0xFF1976D2);
  static const _accentColor = Color(0xFF42A5F5);
  static const _backgroundColor = Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    setState(() {
      _appointmentsFuture = _appointmentService.getAllAppointments();
    });
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      await _appointmentService.updateAppointmentStatus(id, status);
      _showSnackBar('Status updated to $status', _primaryColor);
      _loadAppointments();
    } catch (e) {
      _showSnackBar('Update failed: ${e.toString()}', Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Appointment> _filterAppointments(List<Appointment> appointments) {
    if (_selectedFilter == 'All') return appointments;
    return appointments
        .where((a) => a.status.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  Color _getStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'confirmed' => Colors.green,
      'pending' => Colors.orange,
      'cancelled' => Colors.redAccent,
      'completed' => _accentColor,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterDropdown(),
          Expanded(child: _buildAppointmentsList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Doctor Appointments',
          style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryColor, _accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadAppointments,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<String>(
        value: _selectedFilter,
        decoration: InputDecoration(
          labelText: 'Filter by Status',
          labelStyle: const TextStyle(color: _primaryColor),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: _filterOptions
            .map((value) => DropdownMenuItem(value: value, child: Text(value)))
            .toList(),
        onChanged: (value) => setState(() => _selectedFilter = value!),
        icon: const Icon(Icons.filter_list, color: _primaryColor),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return RefreshIndicator(
      onRefresh: () async => _loadAppointments(),
      color: _primaryColor,
      child: FutureBuilder<List<Appointment>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryColor),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final appointments = _filterAppointments(snapshot.data ?? []);

          if (appointments.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) =>
                _buildAppointmentCard(appointments[index]),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('Error: $error',
              style: const TextStyle(color: Colors.redAccent)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAppointments,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No appointments found',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(appointment),
            const SizedBox(height: 12),
            _buildDoctorInfo(appointment),
            const SizedBox(height: 12),
            _buildAppointmentDetails(appointment),
            const SizedBox(height: 12),
            _buildContactInfo(appointment),
            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildNotesSection(appointment.notes),
            ],
            const SizedBox(height: 16),
            _buildActionButtons(appointment),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(Appointment appointment) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appointment.patientName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(appointment.hospitalName,
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
        Chip(
          backgroundColor: _getStatusColor(appointment.status),
          label: Text(appointment.status.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildDoctorInfo(Appointment appointment) {
    return Text('${appointment.doctorName}',
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: _primaryColor));
  }

  Widget _buildAppointmentDetails(Appointment appointment) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(appointment.date),
        const SizedBox(width: 16),
        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(appointment.time),
      ],
    );
  }

  Widget _buildContactInfo(Appointment appointment) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.email, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
                child: Text(appointment.patientEmail,
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.phone, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(appointment.patientPhone),
            const Spacer(),
            Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
            Text('RM${appointment.amount.toStringAsFixed(2)}'),
            const SizedBox(width: 8),
            Icon(appointment.isPaid ? Icons.check_circle : Icons.pending,
                size: 16,
                color: appointment.isPaid ? Colors.green : Colors.orange),
            const SizedBox(width: 4),
            Text(appointment.isPaid ? 'Paid' : 'Unpaid',
                style: TextStyle(
                    color: appointment.isPaid ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection(String notes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notes:',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(notes),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Appointment appointment) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: appointment.status.toLowerCase() == 'confirmed'
                ? null
                : () => _updateStatus(appointment.id!, 'confirmed'),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Confirm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: appointment.status.toLowerCase() == 'cancelled'
                ? null
                : () => _updateStatus(appointment.id!, 'cancelled'),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Cancel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}
