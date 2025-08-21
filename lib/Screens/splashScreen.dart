import 'package:flutter/material.dart';
import 'getStarted.dart'; // Import the GetStarted screen
import '../colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3500), _checkLoginInfo);
  }

  Future<void> _checkLoginInfo() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.primaryBlue, // Background color
        child: Center(
          child: Image.asset('assets/images/finalGif.gif'), // Splash GIF
        ),
      ),
    );
  }
}
// 