import 'package:flutter/material.dart';
import 'package:pcd_ma/constants.dart';
import '../services/api_services.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final lastnameController = TextEditingController();
  final birthdayController = TextEditingController();
  final robotTypeController = TextEditingController();
  final locationController = TextEditingController();
  final phoneController = TextEditingController();

  void pickBirthDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      birthdayController.text = picked.toIso8601String().split('T').first;
    }
  }

  void registerUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email and password are required')),
      );
      return;
    }

    final payload = {
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
      'name': nameController.text,
      'lastname': lastnameController.text,
      'birthday': birthdayController.text,
      'robotType': robotTypeController.text,
      'location': locationController.text,
      'phone': phoneController.text,
    };

    final success = await ApiService.registerWithDetails(payload);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful ✅')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed ❌')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F8F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ Same rounded image header as LoginPage
            ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(180),
                bottomRight: Radius.circular(180),
              ),
              child: Image.asset(
                'lib/images/background.jpg',
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.3,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),

                  buildInputField(emailController, "Email", Icons.email),
                  buildInputField(nameController, "First Name", Icons.person),
                  buildInputField(lastnameController, "Last Name", Icons.person_outline),
                  buildDateField("Birthdate", birthdayController),
                  buildInputField(robotTypeController, "Robot Type", Icons.android),
                  buildInputField(locationController, "Location", Icons.location_on),
                  buildInputField(phoneController, "Phone", Icons.phone),
                  buildInputField(passwordController, "Password", Icons.lock, obscure: true),

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      minimumSize: Size(double.infinity, 55),
                    ),
                    child: Text("Sign Up", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        ),
                        child: Text("Login", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: pickBirthDate,
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: label,
              prefixIcon: Icon(Icons.calendar_today),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}