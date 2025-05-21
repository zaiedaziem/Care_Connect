// main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(HospitalApp());
}

class HospitalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Malaysia Hospitals',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: HospitalListScreen(),
      routes: {
        '/hospital1': (context) => HospitalBookingScreen(hospitalId: 1),
        '/hospital2': (context) => HospitalBookingScreen(hospitalId: 2),
        '/hospital3': (context) => HospitalBookingScreen(hospitalId: 3),
      },
    );
  }
}

// Model classes
class Hospital {
  final int id;
  final String name;
  final String location;
  final String imageUrl;
  final String description;
  final String contact;
  final List<Doctor> doctors;

  Hospital({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.description,
    required this.contact,
    required this.doctors,
  });
}

class Doctor {
  final int id;
  final String name;
  final String specialty;
  final String imageUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
  });
}

// Sample data
final List<Hospital> hospitals = [
  Hospital(
    id: 1,
    name: 'Hospital Kuala Lumpur',
    location: 'Kuala Lumpur',
    imageUrl: 'assets/images/hkl.png',
    description:
        'Hospital Kuala Lumpur is one of the largest government hospitals in Malaysia, located in the heart of the capital city. It offers a wide range of specialist services and serves as a major referral and teaching hospital with advanced medical facilities and affordable care for the public.',
    contact: '+60 3-2615 5555',
    doctors: [
      Doctor(
          id: 101,
          name: 'Dr. Ahmad Razak',
          specialty: 'Cardiology',
          imageUrl: 'assets/images/muzam.jpeg'),
      Doctor(
          id: 102,
          name: 'Dr. Siti Norazah',
          specialty: 'Neurology',
          imageUrl: 'assets/images/drprmpn.jpeg'),
      Doctor(
          id: 103,
          name: 'Dr. Chong Wei',
          specialty: 'Orthopedics',
          imageUrl: 'assets/images/stone.jpeg'),
    ],
  ),
  Hospital(
    id: 2,
    name: 'Sunway Medical Centre',
    location: 'Kuala lumpur',
    imageUrl: 'assets/images/sunway.png',
    description:
        'Sunway Medical Centre, located in Bandar Sunway, is a leading private hospital offering comprehensive medical services with a focus on innovation and patient safety. It is part of the Sunway Education and Healthcare Group and is affiliated with top global medical institutions.',
    contact: '+60 4-222 7800',
    doctors: [
      Doctor(
          id: 201,
          name: 'Dr. Lee Mei Ling',
          specialty: 'Oncology',
          imageUrl: 'assets/images/drprmpn.jpeg'),
      Doctor(
          id: 202,
          name: 'Dr. Rajesh Kumar',
          specialty: 'Pediatrics',
          imageUrl: 'assets/images/muzam.jpeg'),
      Doctor(
          id: 203,
          name: 'Dr. Nora Ismail',
          specialty: 'Dermatology',
          imageUrl: 'assets/images/drprmpn.jpeg'),
    ],
  ),
  Hospital(
    id: 3,
    name: 'Gleneagles Hospital ',
    location: 'Kuala Lumpur',
    imageUrl: 'assets/images/gleanagles.png',
    description:
        'Gleneagles Hospital Kuala Lumpur is a premier private hospital known for its high-quality healthcare services, modern technology, and personalized patient care. It specializes in cardiology, oncology, orthopedics, and other critical care disciplines, serving both local and international patients.',
    contact: '+60 7-225 3000',
    doctors: [
      Doctor(
          id: 301,
          name: 'Dr. Tan Chee Keong',
          specialty: 'Dermatology',
          imageUrl: 'assets/images/drprmpn.jpeg'),
      Doctor(
          id: 302,
          name: 'Dr. Nurul Huda',
          specialty: 'Gynecology',
          imageUrl: 'assets/images/drprmpn.jpeg'),
      Doctor(
          id: 303,
          name: 'Dr. Andrew Lim',
          specialty: 'Gastroenterology',
          imageUrl: 'assets/images/stone.jpeg'),
    ],
  ),
];

// Hospital List Screen (Page 1)
class HospitalListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Malaysia Hospitals'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: hospitals.length,
          itemBuilder: (context, index) {
            final hospital = hospitals[index];
            return HospitalCard(hospital: hospital);
          },
        ),
      ),
    );
  }
}

// Hospital Card Widget for the List
class HospitalCard extends StatelessWidget {
  final Hospital hospital;

  const HospitalCard({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/hospital${hospital.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
              child: Image.asset(
                hospital.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.local_hospital,
                          size: 80, color: Colors.grey[500]),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital.name,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16.0, color: Colors.blue),
                      SizedBox(width: 4.0),
                      Text(
                        hospital.location,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '${hospital.doctors.length} Doctors Available',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/hospital${hospital.id}');
                    },
                    child: Text('Book Appointment'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Hospital Booking Screen (Pages 2-4, one for each hospital)
class HospitalBookingScreen extends StatefulWidget {
  final int hospitalId;

  HospitalBookingScreen({required this.hospitalId});

  @override
  _HospitalBookingScreenState createState() => _HospitalBookingScreenState();
}

class _HospitalBookingScreenState extends State<HospitalBookingScreen> {
  late Hospital hospital;
  Doctor? selectedDoctor;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final notesController = TextEditingController();
  DateTime selectedDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay selectedTime = TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    hospital = hospitals.firstWhere((h) => h.id == widget.hospitalId);
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
      lastDate: DateTime.now().add(Duration(days: 90)),
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

  void _submitForm() {
    if (_formKey.currentState!.validate() && selectedDoctor != null) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Appointment Confirmed'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Thank you for booking an appointment at ${hospital.name}.'),
                  SizedBox(height: 8),
                  Text(
                      'Doctor: ${selectedDoctor!.name} (${selectedDoctor!.specialty})'),
                  Text(
                      'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  Text('Time: ${selectedTime.format(context)}'),
                  SizedBox(height: 8),
                  Text(
                      'We will send a confirmation to ${emailController.text}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HospitalListScreen()),
                  );
                },
              ),
            ],
          );
        },
      );
    } else if (selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a doctor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hospital.name),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hospital info section
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(hospital.imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      hospital.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.white, size: 16.0),
                        SizedBox(width: 4.0),
                        Text(
                          hospital.location,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.white, size: 16.0),
                        SizedBox(width: 4.0),
                        Text(
                          hospital.contact,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Hospital description
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    hospital.description,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            // Doctors section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Doctor',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: hospital.doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = hospital.doctors[index];
                        final isSelected = selectedDoctor?.id == doctor.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDoctor = doctor;
                            });
                          },
                          child: Container(
                            width: 120,
                            margin: EdgeInsets.only(right: 12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey[300]!,
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage(doctor.imageUrl),
                                  backgroundColor: Colors.grey[300],
                                  onBackgroundImageError:
                                      (exception, stackTrace) {},
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  doctor.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.0,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  doctor.specialty,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Booking form
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectTime(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    selectedTime.format(context),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: 'Additional Notes',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 24.0),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(
                          'Confirm Booking',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
