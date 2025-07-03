import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/appointment_service.dart';
import '../services/doctor_service.dart';
import '../models/appointment_model.dart';
import '../models/doctor.dart';
import 'payment_screen.dart';

class HospitalBookingScreen extends StatefulWidget {
  final Appointment? appointmentToEdit;
  final String? hospitalName;

  const HospitalBookingScreen({
    super.key,
    this.appointmentToEdit,
    this.hospitalName,
  });

  @override
  _HospitalBookingScreenState createState() => _HospitalBookingScreenState();
}

class _HospitalBookingScreenState extends State<HospitalBookingScreen> {
  Doctor? selectedDoctor;
  List<Doctor> availableDoctors = [];
  bool isLoadingDoctors = true;

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final notesController = TextEditingController();
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isEditing = false;

  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.appointmentToEdit != null;
    _loadDoctors();
    _initializeForm();
  }

  Future<void> _loadDoctors() async {
    try {
      setState(() {
        isLoadingDoctors = true;
      });

      List<Doctor> doctors;

      if (widget.hospitalName != null) {
        doctors = await _doctorService.getDoctorsByClinic(widget.hospitalName!);
      } else {
        final snapshot = await _doctorService.getActiveDoctorsStream().first;
        doctors = snapshot;
      }

      setState(() {
        availableDoctors = doctors;
        isLoadingDoctors = false;
      });

      if (_isEditing && widget.appointmentToEdit != null) {
        final existingDoctorName = widget.appointmentToEdit!.doctorName;
        selectedDoctor = availableDoctors.firstWhere(
          (doctor) => doctor.fullName == existingDoctorName,
          orElse: () => availableDoctors.first,
        );
        if (selectedDoctor == null && availableDoctors.isNotEmpty) {
          selectedDoctor = availableDoctors.first;
        }
        setState(() {});
      }
    } catch (e) {
      setState(() {
        isLoadingDoctors = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load doctors: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _initializeForm() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emailController.text = user.email ?? '';
      nameController.text = user.displayName ?? '';
    }

    if (_isEditing && widget.appointmentToEdit != null) {
      final appointment = widget.appointmentToEdit!;
      nameController.text = appointment.patientName;
      emailController.text = appointment.patientEmail;
      phoneController.text = appointment.patientPhone;
      notesController.text = appointment.notes;

      final dateParts = appointment.date.split('/');
      if (dateParts.length == 3) {
        selectedDate = DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
        );
      }

      final timeParts = appointment.time.split(' ');
      if (timeParts.length == 2) {
        final time = timeParts[0].split(':');
        if (time.length == 2) {
          int hour = int.parse(time[0]);
          if (timeParts[1] == 'PM' && hour != 12) {
            hour += 12;
          }
          selectedTime = TimeOfDay(hour: hour, minute: int.parse(time[1]));
        }
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && selectedDoctor != null) {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to be logged in to book an appointment'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(_isEditing
                    ? "Updating appointment..."
                    : "Booking appointment..."),
              ],
            ),
          );
        },
      );

      try {
        Appointment appointment = Appointment(
          id: _isEditing ? widget.appointmentToEdit!.id : null,
          doctorName: selectedDoctor!.fullName,
          hospitalName: selectedDoctor!.clinic,
          time: selectedTime.format(context),
          date:
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
          status: _isEditing ? widget.appointmentToEdit!.status : 'unpaid',
          userId: userId,
          patientName: nameController.text.trim(),
          patientEmail: emailController.text.trim(),
          patientPhone: phoneController.text.trim(),
          notes: notesController.text.trim(),
          createdAt:
              _isEditing ? widget.appointmentToEdit!.createdAt : DateTime.now(),
          isPaid: _isEditing ? widget.appointmentToEdit!.isPaid : false,
          amount: _isEditing ? widget.appointmentToEdit!.amount : 50.00,
        );

        if (_isEditing) {
          await _appointmentService.updateAppointment(
            appointmentId: appointment.id!,
            updates: {
              'doctorName': appointment.doctorName,
              'hospitalName': appointment.hospitalName,
              'time': appointment.time,
              'date': appointment.date,
              'patientName': appointment.patientName,
              'patientEmail': appointment.patientEmail,
              'patientPhone': appointment.patientPhone,
              'notes': appointment.notes,
            },
          );

          Navigator.of(context).pop();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment updated successfully')),
          );
        } else {
          String appointmentId =
              await _appointmentService.bookAppointment(appointment);
          Navigator.of(context).pop();
          _showBookingConfirmation(context, appointmentId);
        }
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to ${_isEditing ? 'update' : 'book'} appointment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor')),
      );
    }
  }

  void _showBookingConfirmation(BuildContext context, String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Booked'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Your appointment at ${selectedDoctor!.clinic} is confirmed'),
                const SizedBox(height: 8),
                Text(
                    'Doctor: ${selectedDoctor!.fullName} (${selectedDoctor!.specialty})'),
                Text(
                    'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                Text('Time: ${selectedTime.format(context)}'),
                const SizedBox(height: 16),
                const Text('Payment Required',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                    'Please complete payment to secure your appointment.'),
                const SizedBox(height: 16),
                const Text('Amount: RM50.00',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Pay Later'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      amount: 50.00,
                      appointmentDetails: {
                        'hospitalName': selectedDoctor!.clinic,
                        'doctorName': selectedDoctor!.fullName,
                        'date':
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        'time': selectedTime.format(context),
                        'appointmentId': appointmentId,
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDoctorsList() {
    if (isLoadingDoctors) {
      return Container(
        height: 140,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (availableDoctors.isEmpty) {
      return Container(
        height: 140,
        child: const Center(
          child: Text(
            'No doctors available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableDoctors.length,
        itemBuilder: (context, index) {
          final doctor = availableDoctors[index];
          final isSelected = selectedDoctor?.doctorId == doctor.doctorId;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDoctor = doctor;
              });
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: doctor.imageUrl != null &&
                            doctor.imageUrl!.isNotEmpty
                        ? (doctor.imageUrl!.startsWith('data:image')
                            ? MemoryImage(
                                base64Decode(
                                  doctor.imageUrl!.split(',').last,
                                ),
                              )
                            : NetworkImage(doctor.imageUrl!) as ImageProvider)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: doctor.imageUrl == null || doctor.imageUrl!.isEmpty
                        ? Icon(Icons.person, size: 30, color: Colors.grey[600])
                        : null,
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      doctor.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      doctor.specialty,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Appointment' : 'Book Appointment'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Select Doctor',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (isLoadingDoctors)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      if (!isLoadingDoctors)
                        IconButton(
                          onPressed: _loadDoctors,
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Refresh doctors list',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  _buildDoctorsList(),
                ],
              ),
            ),
            if (selectedDoctor != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Doctor',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text('Name: ${selectedDoctor!.fullName}'),
                    Text('Specialty: ${selectedDoctor!.specialty}'),
                    Text('Clinic: ${selectedDoctor!.clinic}'),
                    if (selectedDoctor!.phone.isNotEmpty)
                      Text('Phone: ${selectedDoctor!.phone}'),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    const Text(
                      'Patient Information',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Appointment Details',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectTime(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    selectedTime.format(context),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24.0),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: selectedDoctor != null ? _submitForm : null,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _isEditing ? 'Update Appointment' : 'Confirm Booking',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
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
}
