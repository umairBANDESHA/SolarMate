import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // OpenWeather API Key (Replace with your own)
  final String apiKey = "YOUR_API_KEY";
  final String city = "Karachi"; // Change to your city
  final String apiUrl =
      "https://api.openweathermap.org/data/2.5/weather?q=Karachi&appid=YOUR_API_KEY&units=metric";

  String sunrise = "";
  String sunset = "";
  String weatherCondition = "";
  String minTemp = "";
  String maxTemp = "";

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sys = data['sys'];
        final main = data['main'];
        final weather = data['weather'][0];

        setState(() {
          sunrise = formatTime(sys['sunrise']);
          sunset = formatTime(sys['sunset']);
          weatherCondition = weather['description'].toString().toUpperCase();
          minTemp = "${main['temp_min']}°C";
          maxTemp = "${main['temp_max']}°C";
        });
      } else {
        print("Error: Failed to load weather data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  String formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${dateTime.hour}:${dateTime.minute} ${dateTime.hour >= 12 ? 'PM' : 'AM'}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather Info")),
      body: Center(
        child:  Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.iconGrey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(LucideIcons.cloudSun, color: Colors.white, size: 40),
              Text(
                weatherCondition,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(children: [
                const Icon(LucideIcons.sunrise, color: Colors.white),
                Text(sunrise, style: const TextStyle(color: Colors.white))
              ]),
              Column(children: [
                const Icon(LucideIcons.sunset, color: Colors.white),
                Text(sunset, style: const TextStyle(color: Colors.white))
              ]),
            ],
          ),
          Divider(color: Colors.white.withOpacity(0.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Min: $minTemp", style: const TextStyle(color: Colors.white)),
              Text("Max: $maxTemp", style: const TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    )),
    );
  }

  TextStyle textStyle() {
    return const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  }
}
