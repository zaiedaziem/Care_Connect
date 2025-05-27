import 'package:flutter/material.dart';
import 'view/login_view.dart';
import 'view/register_view.dart';
import 'view/clinic_dashboard.dart';

void main() {
  runApp(CareConnectApp());
}

class CareConnectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Care Connect',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginView(),
        '/register': (context) => SignUpScreen(),
        '/dashboard': (context) => ClinicDashboard(),
      },
    );
  }
}
