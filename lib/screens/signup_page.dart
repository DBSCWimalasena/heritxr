import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔵 COVER IMAGE
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 260,
                  child: Image.asset(
                    'assets/images/cover.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                const Positioned(
                  top: 40,
                  right: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.more_vert),
                  ),
                ),
              ],
            ),

            // 🔵 FORM CONTAINER
            Container(
              transform: Matrix4.translationValues(0, -30, 0),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // LOGIN / SIGN UP TOGGLE
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // FORM FIELDS
                  const CustomField(label: 'Full Name'),
                  const CustomField(label: 'Email'),
                  const CustomField(label: 'Password', isPassword: true),
                  const CustomField(label: 'Confirm Password', isPassword: true),

                  const SizedBox(height: 30),

                  // SIGN UP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('Sign Up'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // LOGIN TEXT
                  const Text.rich(
                    TextSpan(
                      text: 'have account? ',
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
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

// 🔹 REUSABLE INPUT FIELD
class CustomField extends StatelessWidget {
  final String label;
  final bool isPassword;

  const CustomField({
    super.key,
    required this.label,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }
}
