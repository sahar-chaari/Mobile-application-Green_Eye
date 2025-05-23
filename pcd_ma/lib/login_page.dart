import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'registration.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool stayLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoggedInStatus();
  }

  Future<void> checkLoggedInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('userId');
    if (storedUserId != null) {
      Navigator.pushReplacementNamed(context, '/home', arguments: {'userId': storedUserId});
    }
  }

  Future<void> loginUser(BuildContext context) async {
    String? token = await AuthService.login(emailController.text, passwordController.text);
    if (token != null) {
      final res = await http.get(Uri.parse('http://192.168.1.16:5000/api/users/by-email/${emailController.text}'));
      if (res.statusCode == 200) {
        final userId = jsonDecode(res.body)['userId'];
        if (stayLoggedIn) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
        }
        Navigator.pushReplacementNamed(context, '/home', arguments: {'userId': userId});
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F8F9),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(180),
              bottomRight: Radius.circular(180),
            ),
            child: Image.asset(
              'lib/images/background.jpg',
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome Back", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Log in to your account", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  SizedBox(height: 28),
                  _buildRoundedInput(emailController, "User Name"),
                  SizedBox(height: 18),
                  _buildRoundedInput(passwordController, "Password", obscure: true),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: stayLoggedIn,
                        onChanged: (val) => setState(() => stayLoggedIn = val ?? false),
                      ),
                      Text("Stay logged in"),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => loginUser(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB9CEC6),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: StadiumBorder(),
                      ),
                      child: Text("Log In", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage())),
                        child: Text("Signup", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedInput(TextEditingController controller, String hint, {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(40),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
      ),
    );
  }
}