import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String? cityName;
  bool isLoading = true;
  String currentTime = '';
  Map<String, dynamic> weatherData = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchWeather();
    _timer = Timer.periodic(Duration(minutes: 5), (Timer t) => fetchWeather());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchWeather() async {
    setState(() => isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          throw Exception('Location permission denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double latitude = position.latitude;
      double longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      cityName = placemarks.first.locality ?? 'Your Location';

      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true&hourly=relativehumidity_2m,apparent_temperature,precipitation,precipitation_probability,rain,snowfall,cloudcover,surface_pressure'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current_weather'];
        DateTime rawTime = DateTime.parse(current['time']);
        currentTime = "${rawTime.toIso8601String().substring(0, 13)}:00";

        final index = data['hourly']['time'].indexOf(currentTime);
        if (index == -1) {
          throw Exception('Current time not found in hourly data');
        }

        setState(() {
          weatherData = {
            'Temperature': {'value': current['temperature']?.toDouble(), 'unit': '°C'},
            'Apparent Temperature': {'value': data['hourly']['apparent_temperature'][index]?.toDouble(), 'unit': '°C'},
            'Humidity': {'value': data['hourly']['relativehumidity_2m'][index]?.toDouble(), 'unit': '%'},
            'Precipitation': {'value': data['hourly']['precipitation'][index]?.toDouble(), 'unit': 'mm'},
            'Precipitation Probability': {'value': data['hourly']['precipitation_probability'][index]?.toDouble(), 'unit': '%'},
            'Rain': {'value': data['hourly']['rain'][index]?.toDouble(), 'unit': 'mm'},
            'Snowfall': {'value': data['hourly']['snowfall'][index]?.toDouble(), 'unit': 'cm'},
            'Cloud Cover': {'value': data['hourly']['cloudcover'][index]?.toDouble(), 'unit': '%'},
            'Pressure': {'value': data['hourly']['surface_pressure'][index]?.toDouble(), 'unit': 'hPa'},
          };
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
        weatherData = {};
      });
    }
  }

  Widget buildWeatherCard(String title, double? value, String unit, int hoursLeft) {
    String displayValue = value != null && value.isFinite ? value.toStringAsFixed(0) : '--';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 6),
                  Text(cityName ?? "Your Location"),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16),
                      SizedBox(width: 6),
                      Text("$hoursLeft hours left")
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: CircularPercentIndicator(
                radius: 40.0,
                lineWidth: 5.0,
                percent: value != null && value.isFinite ? (value / 100).clamp(0.0, 1.0) : 0.0,
                center: Text("$displayValue$unit"),
                progressColor: Colors.green,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : weatherData.isEmpty
              ? Center(child: Text("Failed to load weather data"))
              : ListView(
                  padding: EdgeInsets.all(16),
                  children: weatherData.entries.map((entry) {
                    final title = entry.key;
                    final value = entry.value['value'];
                    final unit = entry.value['unit'];
                    return buildWeatherCard(title, value, unit, 1);
                  }).toList(),
                ),
    );
  }
}