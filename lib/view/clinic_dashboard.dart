import 'package:flutter/material.dart';

class ClinicDashboard extends StatelessWidget {
  const ClinicDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome, User'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search Bar
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue,
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search clinics...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📅 Dashboard Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _DashboardButton(
                    icon: Icons.calendar_today,
                    label: 'Appointment',
                    onTap: () {
                      // TODO: Add navigation or action
                    },
                  ),
                  const SizedBox(width: 16),
                  _DashboardButton(
                    icon: Icons.favorite,
                    label: 'Health Tips',
                    onTap: () {
                      // TODO: Add navigation or action
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 🏥 Top Clinics
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Top Clinics',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                children: const [
                  _ClinicCard(
                    name: 'Gleneagles Hospital',
                    location: '900m away',
                    imageUrl: 'images/glene.png',
                  ),
                  _ClinicCard(
                    name: 'Columbia Asia Hospital',
                    location: '1.5km away',
                    imageUrl: 'images/columbia.jpg',
                  ),
                  _ClinicCard(
                    name: 'Klinik Keluarga i-SIHAT',
                    location: '2km away',
                    imageUrl: 'images/keluarga.png',
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

class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClinicCard extends StatelessWidget {
  final String name;
  final String location;
  final String imageUrl;

  const _ClinicCard({
    required this.name,
    required this.location,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
