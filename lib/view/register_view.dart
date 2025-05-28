import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

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
        leading: const BackButton(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sign Up',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            buildTextField(Icons.person, 'Enter your name'),
            const SizedBox(height: 16),
            buildTextField(Icons.email, 'Enter your email'),
            const SizedBox(height: 16),
            buildPasswordField(),
            const SizedBox(height: 16),
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
                      const Text('I agree to the medidoc '),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Terms of Service',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                      const Text(' and '),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: agreeToTerms ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const Spacer(),
            Center(
              child: GestureDetector(
                onTap: () {
                  // Add navigation to LoginView if needed
                },
                child: const Text.rich(
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
            const SizedBox(height: 24),
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
        fillColor: const Color(0xFFF5F5F5),
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
        prefixIcon: const Icon(Icons.lock),
        hintText: 'Enter your password',
        suffixIcon: IconButton(
          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
