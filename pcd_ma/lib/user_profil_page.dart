import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? user;
  bool isEditing = false;

  final nameController = TextEditingController();
  final lastnameController = TextEditingController();
  final birthdayController = TextEditingController();
  final robotTypeController = TextEditingController();
  final locationController = TextEditingController();
  final phoneController = TextEditingController();

  final String apiUrl = 'http://192.168.1.16:5000/api';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final res = await http.get(Uri.parse('$apiUrl/users/${widget.userId}'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          user = data;
          nameController.text = data['name'] ?? '';
          lastnameController.text = data['lastname'] ?? '';
          birthdayController.text = data['birthday'] ?? '';
          robotTypeController.text = data['robotType'] ?? '';
          locationController.text = data['location'] ?? '';
          phoneController.text = data['phone'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  Future<void> updateUserProfile() async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/users/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text,
          'lastname': lastnameController.text,
          'birthday': birthdayController.text,
          'robotType': robotTypeController.text,
          'location': locationController.text,
          'phone': phoneController.text,
        }),
      );
      if (response.statusCode == 200) {
        setState(() => isEditing = false);
        fetchUserProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated')),
        );
      }
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final uri = Uri.parse('$apiUrl/users/upload-image/${widget.userId}');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', picked.path));
    final res = await request.send();

    if (res.statusCode == 200) {
      fetchUserProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed')),
      );
    }
  }

  Future<void> pickBirthDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthdayController.text.isNotEmpty
          ? DateTime.tryParse(birthdayController.text) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        birthdayController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text("My Profile")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: user!['image'] != null
                      ? NetworkImage('http://192.168.1.235:5000/images/${user!['image']}')
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: user!['image'] == null ? Icon(Icons.person, size: 60) : null,
                ),
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: uploadImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  )
              ],
            ),
            SizedBox(height: 20),
            buildField("First Name", nameController),
            buildField("Last Name", lastnameController),
            buildDatePickerField("Birthdate", birthdayController),
            buildField("Robot Type", robotTypeController),
            buildField("Location", locationController),
            buildField("Phone", phoneController),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: isEditing ? updateUserProfile : () {
                setState(() => isEditing = true);
              },
              child: Text(isEditing ? 'Save Changes' : 'Edit Profile'),
            )
          ],
        ),
      ),
    );
  }

  Widget buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: !isEditing,
          fillColor: !isEditing ? Colors.grey[100] : null,
        ),
      ),
    );
  }

  Widget buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: isEditing ? pickBirthDate : null,
        child: AbsorbPointer(
          absorbing: true,
          child: TextField(
            controller: controller,
            enabled: isEditing,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
              filled: !isEditing,
              fillColor: !isEditing ? Colors.grey[100] : null,
              suffixIcon: Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
    );
  }
}