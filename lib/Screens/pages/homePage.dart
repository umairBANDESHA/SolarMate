import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newsample/Screens/components/chatbot.dart';
import 'package:newsample/Screens/testPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../HomePageScreens/CalculatorPage.dart';
import '../HomePageScreens/Resources.dart';
import '../HomePageScreens/SolarGuideScreen.dart';
import '../HomePageScreens/inverterDetails.dart';
import '../../colors.dart';

// import '../testPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _apiKey = '3cae4faf39b331d5155b2eea78f62d89';
  final String lat = "28.42";
  final String lon = "70.31";
  late String apiUrl;

  User? user;
  bool isLoading = true;
  bool isEditing = false;
  String? name;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    apiUrl =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$_apiKey";
    fetchWeatherData();

    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    user = _auth.currentUser;

    bool isUserLoggedIn() {
      final user = FirebaseAuth.instance.currentUser;
      return user != null;
    }

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // Fetch user profile details
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user!.email).get();
      setState(() {
        if (userDoc.exists) {
          name = userDoc['name'];
          print(name);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  String sunrise = "--";
  String sunset = "--";
  String weatherCondition = "--";
  String minTemp = "";
  String maxTemp = "";
  String sunhours = "--";
  String cloudCoverage = '';
  String uv = '';

  bool _hasCheckedTime = false;
  bool _useNightGradient = false;

  Future<void> fetchWeatherData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final sys = data['sys'];
        final main = data['main'];
        final weather = data['weather'][0];
        final clouds = data['clouds']['all'];
        final uvIndex = data['uvi']; // If your API has this
        final sunriseTime = DateTime.fromMillisecondsSinceEpoch(
          sys['sunrise'] * 1000,
        );
        final sunsetTime = DateTime.fromMillisecondsSinceEpoch(
          sys['sunset'] * 1000,
        );
        final daylight = sunsetTime.difference(sunriseTime);

        setState(() {
          sunrise = formatTime(sys['sunrise']);
          sunset = formatTime(sys['sunset']);
          sunhours =
              '${daylight.inHours} h ${daylight.inMinutes.remainder(60)} m';
          weatherCondition = weather['description'].toString().toUpperCase();
          cloudCoverage = '$clouds% Cloud Cover';
          uv = uvIndex.toString(); // Only if available in your API
        });

        // print(
        //   "Weather: $weatherCondition | Sunhours: $sunhours | Clouds: $cloudCoverage",
        // );
      }
    } catch (e) {
      print("Weather fetch error: $e");
    }
  }

  Future<Map<String, dynamic>?> fetchRatesFromFirestore() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('rates')
              .doc('current_rates')
              .get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      print("Error fetching rates: $e");
    }
    return null;
  }

  String formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}";
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  LinearGradient _getWeatherGradient(String condition) {
    condition = condition.toLowerCase();

    // One-time night mode override
    if (!_hasCheckedTime) {
      int hour = DateTime.now().hour;
      _useNightGradient = hour < 6 || hour > 18;
      _hasCheckedTime = true;
    }

    if (_useNightGradient) {
      return const LinearGradient(
        colors: [
          Color(0xFF1A1A2E), // Dark navy
          Color(0xFF0F3460), // Deeper blue
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }

    // -- Your existing weather-based logic continues here --

    if (condition.contains('cloud') || condition.contains('overcast')) {
      return const LinearGradient(
        colors: [
          Color.fromARGB(255, 33, 79, 150),
          Color.fromARGB(255, 100, 150, 200),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (condition.contains('sun') || condition.contains('clear')) {
      return const LinearGradient(
        colors: [
          Color.fromARGB(255, 255, 200, 0),
          Color.fromARGB(255, 255, 120, 0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return const LinearGradient(
        colors: [
          Color.fromARGB(255, 70, 90, 120),
          Color.fromARGB(255, 150, 170, 190),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (condition.contains('snow') || condition.contains('fog')) {
      return const LinearGradient(
        colors: [
          Color.fromARGB(255, 200, 220, 240),
          Color.fromARGB(255, 120, 150, 190),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (condition.contains('thunder') || condition.contains('storm')) {
      return const LinearGradient(
        colors: [
          Color.fromARGB(255, 40, 40, 80),
          Color.fromARGB(255, 80, 80, 120),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      return const LinearGradient(
        colors: [
          Color.fromARGB(255, 33, 79, 150),
          Color.fromARGB(255, 134, 134, 134),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: Text(
          name ?? 'User',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return FutureBuilder<Map<String, dynamic>?>(
              future: fetchRatesFromFirestore(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error loading rates"));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text("No rate data available"));
                }

                final ratesData = snapshot.data!;

                return SingleChildScrollView(
                  padding: EdgeInsets.all(constraints.maxWidth * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWeatherCard(constraints),
                      SizedBox(height: constraints.maxHeight * 0.03),
                      _buildFeatureGrid(constraints),
                      SizedBox(height: constraints.maxHeight * 0.03),
                      _buildRatesSection(constraints, ratesData),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeatherCard(BoxConstraints constraints) {
    return Container(
      padding: EdgeInsets.all(constraints.maxWidth * 0.04),
      width: constraints.maxWidth,
      decoration: BoxDecoration(
        gradient: _getWeatherGradient(weatherCondition),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weather Condition + Cloud Coverage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                weatherCondition,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: constraints.maxWidth * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                cloudCoverage,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: constraints.maxWidth * 0.035,
                ),
              ),
            ],
          ),
          SizedBox(height: constraints.maxHeight * 0.015),

          // Sunrise & Sunset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sunrise',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: constraints.maxWidth * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    sunrise,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: constraints.maxWidth * 0.04,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Sunset',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: constraints.maxWidth * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    sunset,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: constraints.maxWidth * 0.04,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: constraints.maxHeight * 0.015),

          // Sun Hours
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'Sunlight Duration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: constraints.maxWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    sunhours,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: constraints.maxWidth * 0.04,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BoxConstraints constraints) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: constraints.maxWidth * 0.04,
      mainAxisSpacing: constraints.maxHeight * 0.02,
      children: [
        _buildFeatureCard(
          "Solar Guide",
          Icons.light_mode,
          constraints,
          context,
        ),
        _buildFeatureCard(
          "Inverter Details",
          Icons.electrical_services,
          constraints,
          context,
        ),
        _buildFeatureCard("Calculator", Icons.calculate, constraints, context),
        _buildFeatureCard("Resources", Icons.menu_book, constraints, context),
      ],
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    BoxConstraints constraints,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        if (title == "Solar Guide") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SolarGuideScreen()),
          );
        } else if (title == "Inverter Details") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InverterDetailsPage()),
          );
        } else if (title == "Calculator") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CalculatorPage()),
          );
        } else if (title == "Resources") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResourcesPage()),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(constraints.maxWidth * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.blueAccent,
              size: constraints.maxWidth * 0.12,
            ),
            SizedBox(height: constraints.maxHeight * 0.01),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: constraints.maxWidth * 0.04,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatesSection(
    BoxConstraints constraints,
    Map<String, dynamic> ratesData,
  ) {
    return Container(
      padding: EdgeInsets.all(constraints.maxWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRateCategory(
            "Solar Panels Rates",
            constraints,
            List<Widget>.from(
              (ratesData['solar_panels'] as List).map(
                (item) =>
                    _buildRateRow(item['name'], item['price'], constraints),
              ),
            ),
          ),
          SizedBox(height: constraints.maxHeight * 0.02),
          _buildRateCategory(
            "Batteries Rates",
            constraints,
            List<Widget>.from(
              (ratesData['batteries'] as List).map(
                (item) =>
                    _buildRateRow(item['name'], item['price'], constraints),
              ),
            ),
          ),
          SizedBox(height: constraints.maxHeight * 0.02),
          _buildRateCategory(
            "Inverters Rates",
            constraints,
            List<Widget>.from(
              (ratesData['inverters'] as List).map(
                (item) =>
                    _buildRateRow(item['name'], item['price'], constraints),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateCategory(
    String title,
    BoxConstraints constraints,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: constraints.maxWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.01),
        ...items,
      ],
    );
  }

  Widget _buildRateRow(String title, String price, BoxConstraints constraints) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.008),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.035,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              price,
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.035,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
