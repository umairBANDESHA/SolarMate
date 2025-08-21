import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:newsample/Screens/auth/forgotpassword.dart';
import 'package:newsample/Screens/auth/registration.dart';
// screens
import './screens/splashScreen.dart';
import './screens/getStarted.dart';
import './screens/auth/login.dart';
import './Screens/home.dart';
import './Screens/pages/homePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/getStarted': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/forgotPassword': (context) => const ForgotPasswordPage(),
        '/homePage': (context) => HomePage(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
