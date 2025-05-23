import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
class AddCollectionPage extends StatefulWidget {
  @override
  _AddCollectionPageState createState() => _AddCollectionPageState();
}

class _AddCollectionPageState extends State<AddCollectionPage> {
  // Your other variables...

  Future<void> predictDisease() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.16:8000/predict'), // ⚠️ Replace with your Python backend IP
      );
      request.files.add(await http.MultipartFile.fromPath('image', pickedFile.path));

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      print("Prediction result: $resBody");

      // You can show this in UI or extract useful data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Collection")),
      body: Center(
        child: ElevatedButton(
          onPressed: predictDisease,
          child: Text("Capture and Predict"),
        ),
      ),
    );
  }
}
