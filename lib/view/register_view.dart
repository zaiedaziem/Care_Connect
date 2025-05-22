import 'package:flutter/material.dart';

void main() {
  runApp(SignUpApp());
}

class SignUpApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignUpScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool agreeToTerms = false;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign Up',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            buildTextField(Icons.person, 'Enter your name'),
            SizedBox(height: 16),
            buildTextField(Icons.email, 'Enter your email'),
            SizedBox(height: 16),
            buildPasswordField(),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      agreeToTerms = value!;
                    });
                  },
                ),
                Expanded(
                  child: Wrap(
                    children: [
                      Text('I agree to the medidoc '),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Terms of Service',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                      Text(' and '),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: agreeToTerms ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                'Sign Up',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Spacer(),
            Center(
              child: GestureDetector(
                onTap: () {},
                child: Text.rich(
                  TextSpan(
                    text: "Don’t have an account? ",
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(color: Colors.teal),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget buildTextField(IconData icon, String hintText) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildPasswordField() {
    return TextField(
      obscureText: obscurePassword,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        hintText: 'Enter your password',
        suffixIcon: IconButton(
          icon:
              Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
