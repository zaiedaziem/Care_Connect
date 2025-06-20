import 'doctor.dart';

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

final List<Hospital> hospitals = [
  Hospital(
    id: 1,
    name: 'Hospital Kuala Lumpur',
    location: 'Kuala Lumpur',
    imageUrl: 'images/hkl.png',
    description:
        'Hospital Kuala Lumpur is one of the largest government hospitals in Malaysia, located in the heart of the capital city. It offers a wide range of specialist services and serves as a major referral and teaching hospital with advanced medical facilities and affordable care for the public.',
    contact: '+60 3-2615 5555',
    doctors: [
      Doctor(
          fullName: 'Dr. Ahmad Razak',
          specialty: 'Cardiology',
          clinic: 'Hiok',
          email: 'f',
          phone: '09',
          imageUrl: 'images/muzam.jpeg'),
      Doctor(
          fullName: 'Dr. Siti Norazah',
          specialty: 'Neurology',
          clinic: 'Hiok',
          email: 'f',
          phone: '09',
          imageUrl: 'images/drprmpn.jpeg'),
      Doctor(
          fullName: 'Dr. Chong Wei',
          specialty: 'Orthopedics',
          clinic: 'Hiok',
          email: 'f',
          phone: '09',
          imageUrl: 'images/stone.jpeg'),
    ],
  ),
  Hospital(
    id: 2,
    name: 'Sunway Medical Centre',
    location: 'Kuala lumpur',
    imageUrl: 'images/sunway.png',
    description:
        'Sunway Medical Centre, located in Bandar Sunway, is a leading private hospital offering comprehensive medical services with a focus on innovation and patient safety. It is part of the Sunway Education and Healthcare Group and is affiliated with top global medical institutions.',
    contact: '+60 4-222 7800',
    doctors: [
      Doctor(
          fullName: 'Dr. Lee Mei Ling',
          specialty: 'Oncology',
          clinic: 'Hiok',
          email: 'f',
          phone: '09',
          imageUrl: 'images/drprmpn.jpeg'),
      Doctor(
          fullName: 'Dr. Rajesh Kumar',
          specialty: 'Pediatrics',
          clinic: 'Hiok',
          email: 'f',
          phone: '09',
          imageUrl: 'images/muzam.jpeg'),
      Doctor(
          fullName: 'Dr. Nora Ismail',
          specialty: 'Dermatology',
          clinic: 'Hiok',
          email: 'f',
          phone: '09',
          imageUrl: 'images/drprmpn.jpeg'),
    ],
  ),
  Hospital(
    id: 3,
    name: 'Gleneagles Hospital ',
    location: 'Kuala Lumpur',
    imageUrl: 'images/gleanagles.png',
    description:
        'Gleneagles Hospital Kuala Lumpur is a premier private hospital known for its high-quality healthcare services, modern technology, and personalized patient care. It specializes in cardiology, oncology, orthopedics, and other critical care disciplines, serving both local and international patients.',
    contact: '+60 7-225 3000',
    doctors: [
      Doctor(
          fullName: 'Dr. Tan Chee Keong',
          specialty: 'Dermatology',
          clinic: 'Hiok',
          email: 'f',
          phone: '09',
          imageUrl: 'images/drprmpn.jpeg'),
      Doctor(
          fullName: 'Dr. Nurul Huda',
          specialty: 'Gynecology',
          clinic: 'Hiok',
          email: 'f',
          phone: '09',
          imageUrl: 'images/drprmpn.jpeg'),
      Doctor(
          fullName: 'Dr. Andrew Lim',
          specialty: 'Gastroenterology',
          clinic: 'Hiok',
          email: 'f',
          phone: '09',
          imageUrl: 'images/stone.jpeg'),
    ],
  ),
];
