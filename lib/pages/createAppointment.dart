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

class _HospitalBookingScreenState extends State<HospitalBookingScreen>
    with TickerProviderStateMixin {
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

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.appointmentToEdit != null;

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _loadDoctors();
    _initializeForm();

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    notesController.dispose();
    super.dispose();
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
      _showErrorSnackBar('Failed to load doctors: ${e.toString()}');
    }
  }

  void _initializeForm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emailController.text = user.email ?? '';
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        nameController.text = user.displayName!;
      } else {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data['name'] != null) {
            nameController.text = data['name'];
          }
        }
      }
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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
        _showErrorSnackBar('You need to be logged in to book an appointment');
        return;
      }

      _showLoadingDialog();

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
          _showSuccessSnackBar('Appointment updated successfully');
        } else {
          String appointmentId =
              await _appointmentService.bookAppointment(appointment);
          Navigator.of(context).pop();
          _showBookingConfirmation(context, appointmentId);
        }
      } catch (e) {
        Navigator.of(context).pop();
        _showErrorSnackBar(
            'Failed to ${_isEditing ? 'update' : 'book'} appointment: ${e.toString()}');
      }
    } else if (selectedDoctor == null) {
      _showErrorSnackBar('Please select a doctor');
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                ),
                const SizedBox(width: 20),
                Text(
                  _isEditing
                      ? "Updating appointment..."
                      : "Booking appointment...",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE57373),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showBookingConfirmation(BuildContext context, String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6C63FF),
                  Color(0xFF9C27B0),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Appointment Booked!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clinic: ${selectedDoctor!.clinic}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Doctor: ${selectedDoctor!.fullName}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        'Specialty: ${selectedDoctor!.specialty}',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8), fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        'Time: ${selectedTime.format(context)}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Payment Required',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Complete payment to secure your appointment',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Amount: RM50.00',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Proceed to Payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassMorphicContainer({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildDoctorsList() {
    if (isLoadingDoctors) {
      return Container(
        height: 160,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
          ),
        ),
      );
    }

    if (availableDoctors.isEmpty) {
      return Container(
        height: 160,
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

    // Option 1: Improved Horizontal Scrolling with better physics
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(), // Better scroll physics
        padding: const EdgeInsets.symmetric(horizontal: 4), // Add padding
        itemCount: availableDoctors.length,
        itemBuilder: (context, index) {
          final doctor = availableDoctors[index];
          final isSelected = selectedDoctor?.doctorId == doctor.doctorId;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 140,
            margin: const EdgeInsets.only(right: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                    )
                  : null,
              color: isSelected ? null : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFF6C63FF).withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isSelected ? 15 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20.0),
                onTap: () {
                  setState(() {
                    selectedDoctor = doctor;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundImage: doctor.imageUrl != null &&
                                  doctor.imageUrl!.isNotEmpty
                              ? (doctor.imageUrl!.startsWith('data:image')
                                  ? MemoryImage(
                                      base64Decode(
                                        doctor.imageUrl!.split(',').last,
                                      ),
                                    )
                                  : NetworkImage(doctor.imageUrl!)
                                      as ImageProvider)
                              : null,
                          backgroundColor: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey[100],
                          child: doctor.imageUrl == null ||
                                  doctor.imageUrl!.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 32,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[600],
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        doctor.fullName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        doctor.specialty,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.0,
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FF),
              Color(0xFFE8F0FF),
              Color(0xFFF0E8FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Color(0xFF6C63FF)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _isEditing ? 'Edit Appointment' : 'Book Appointment',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Doctor Selection Section
                          _buildGlassMorphicContainer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF6C63FF),
                                            Color(0xFF9C27B0)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.local_hospital,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Select Doctor',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isLoadingDoctors)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF6C63FF)),
                                        ),
                                      ),
                                    if (!isLoadingDoctors)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6C63FF)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: IconButton(
                                          onPressed: _loadDoctors,
                                          icon: const Icon(Icons.refresh,
                                              color: Color(0xFF6C63FF)),
                                          tooltip: 'Refresh doctors list',
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildDoctorsList(),
                              ],
                            ),
                          ),

                          // Selected Doctor Info
                          if (selectedDoctor != null)
                            _buildGlassMorphicContainer(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF6C63FF).withOpacity(0.1),
                                      const Color(0xFF9C27B0).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF6C63FF)
                                        .withOpacity(0.2),
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF6C63FF),
                                                Color(0xFF9C27B0)
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.verified_user,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Selected Doctor',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                            color: Color(0xFF2D3748),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInfoRow(Icons.person, 'Name',
                                        selectedDoctor!.fullName),
                                    _buildInfoRow(Icons.medical_services,
                                        'Specialty', selectedDoctor!.specialty),
                                    _buildInfoRow(Icons.location_on, 'Clinic',
                                        selectedDoctor!.clinic),
                                    if (selectedDoctor!.phone.isNotEmpty)
                                      _buildInfoRow(Icons.phone, 'Phone',
                                          selectedDoctor!.phone),
                                  ],
                                ),
                              ),
                            ),

                          // Patient Information Form
                          _buildGlassMorphicContainer(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF6C63FF),
                                              Color(0xFF9C27B0)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.person_outline,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Patient Information',
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  _buildCustomTextField(
                                    controller: nameController,
                                    labelText: 'Full Name',
                                    icon: Icons.person,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCustomTextField(
                                    controller: emailController,
                                    labelText: 'Email',
                                    icon: Icons.email,
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
                                  const SizedBox(height: 16),
                                  _buildCustomTextField(
                                    controller: phoneController,
                                    labelText: 'Phone Number',
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Appointment Details
                          _buildGlassMorphicContainer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF6C63FF),
                                            Color(0xFF9C27B0)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.schedule,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Appointment Details',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateTimeCard(
                                        icon: Icons.calendar_today,
                                        label: 'Date',
                                        value:
                                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                        onTap: () => _selectDate(context),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildDateTimeCard(
                                        icon: Icons.access_time,
                                        label: 'Time',
                                        value: selectedTime.format(context),
                                        onTap: () => _selectTime(context),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildCustomTextField(
                                  controller: notesController,
                                  labelText: 'Additional Notes',
                                  icon: Icons.note,
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),

                          // Submit Button
                          Container(
                            margin: const EdgeInsets.all(16),
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: selectedDoctor != null
                                    ? const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF6C63FF),
                                          Color(0xFF9C27B0)
                                        ],
                                      )
                                    : null,
                                color: selectedDoctor == null
                                    ? Colors.grey[300]
                                    : null,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: selectedDoctor != null
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF6C63FF)
                                              .withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: selectedDoctor != null
                                      ? _submitForm
                                      : null,
                                  child: Center(
                                    child: Text(
                                      _isEditing
                                          ? 'Update Appointment'
                                          : 'Confirm Booking',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: selectedDoctor != null
                                            ? Colors.white
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF6C63FF)),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5568),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
