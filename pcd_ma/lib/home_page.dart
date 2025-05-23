import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pcd_ma/constants.dart';
import 'login_page.dart';
import 'user_profil_page.dart';
import 'weather_page.dart';

class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List detections = [];
  List diseases = [];
  int _currentIndex = 0;

  final String apiUrl = 'http://192.168.1.16:5000/api';
  final String detectionsFetchUrl = 'http://192.168.1.16:8000/detections';
  final String detectionUrl = 'http://192.168.1.16:8000/predict';

  @override
  void initState() {
    super.initState();
    fetchDetections();
    fetchDiseases();
  }

  Future<void> fetchDiseases() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/diseases'));
      if (response.statusCode == 200) {
        setState(() {
          diseases = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching diseases: $e');
    }
  }

  Future<void> fetchDetections() async {
    try {
      final detectRes = await http.get(Uri.parse('$detectionsFetchUrl?userId=${widget.userId}'));
      setState(() {
        detections = jsonDecode(detectRes.body);
      });
    } catch (e) {
      print('Error fetching detections: $e');
    }
  }

  Future<void> deleteDetection(String filename) async {
    await http.delete(Uri.parse('$detectionsFetchUrl/$filename'));
    fetchDetections();
  }

  Future<void> detectDiseaseFromImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) return;

    final request = http.MultipartRequest('POST', Uri.parse(detectionUrl));
    request.fields['userId'] = widget.userId;
    request.files.add(await http.MultipartFile.fromPath('image', pickedFile.path));

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final result = jsonDecode(resBody);
      final prediction = result['prediction'];

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Detection Result"),
          content: Text("Disease detected: $prediction"),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("OK"))],
        ),
      );

      fetchDetections();
    } else {
      print("Detection failed: ${response.statusCode}");
    }
  }

  void showDiseaseDetails(Map item) {
    final imagePath = item['image'] != null
        ? 'http://192.168.1.16:5000/images/${item['image']}'
        : null;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              if (imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    imagePath,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          item['title'] ?? 'Disease',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 20),
                      if (item['description'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text(item['description'], style: TextStyle(fontSize: 14)),
                            SizedBox(height: 16),
                          ],
                        ),
                      if (item['recommendation'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Recommendation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text(item['recommendation'], style: TextStyle(fontSize: 14)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close", style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHorizontalList(List items, String type) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final title = type == 'disease' ? item['title'] : item['prediction'];
          final imagePath = type == 'disease'
              ? item['image'] != null
                  ? 'http://192.168.1.16:5000/images/${item['image']}'
                  : null
              : item['filename'] != null
                  ? 'http://192.168.1.16:8000/images/${item['filename']}'
                  : null;

          return GestureDetector(
            onTap: () => type == 'disease' ? showDiseaseDetails(item) : null,
            child: Container(
              width: 160,
              margin: EdgeInsets.only(right: 10),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      child: imagePath != null
                          ? Image.network(imagePath, width: 160, height: 160, fit: BoxFit.cover)
                          : Container(
                              width: 160,
                              height: 160,
                              color: Colors.grey[300],
                              child: Center(child: Icon(Icons.image, size: 40)),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Text(
                        title ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (type != 'disease')
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteDetection(item['filename']),
                        ),
                      )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  Widget buildHomeBody() {
    return RefreshIndicator(
      onRefresh: fetchDetections,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 180,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage('lib/images/plant_banner.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => detectDiseaseFromImage(ImageSource.camera),
              icon: Icon(Icons.camera_alt, color: Colors.white),
              label: Text("Diagnose from Camera", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primaryColor,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => detectDiseaseFromImage(ImageSource.gallery),
              icon: Icon(Icons.photo_library, color: Colors.white),
              label: Text("Diagnose from Gallery", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primaryColor,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 30),
            Text('Common Plant Diseases', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            buildHorizontalList(diseases, 'disease'),
            SizedBox(height: 30),
            Text('Your Detections', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            buildHorizontalList(detections, 'detection'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHomeBody(),
      WeatherPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Green Eye'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: {'userId': widget.userId},
              );
            },
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Constants.primaryColor,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Weather'),
        ],
      ),
    );
  }
}