import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Testpage extends StatefulWidget {
  const Testpage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Testpage> {
  final ratesData = {
    'solar_panels': [
      {'name': 'Jinko N-Type Bifacial | 580W', 'price': 'Rs. 30'},
      {'name': 'Canadian N-Type Double Glass | 580W', 'price': 'Rs. 33'},
      {'name': 'Longi Hi-Mo 7 Bifacial | 580W', 'price': 'Rs. 31.50'},
      {'name': 'Canadian Single Glass | 545W', 'price': 'Rs. 34'},
    ],
    'batteries': [
      {'name': 'Phoenix TX1800 | 150Ah', 'price': 'Rs. 38,000 - 42,000'},
      {'name': 'AGS SP Tall Tubular | 180Ah', 'price': 'Rs. 42,000 - 46,000'},
      {'name': 'Osaka P-180S | 150Ah', 'price': 'Rs. 37,000 - 40,000'},
    ],
    'inverters': [
      {'name': 'Tesla Vertex Pro 3.2kW', 'price': 'Rs. 90,000 - 105,000'},
      {'name': 'Growatt SPF 5000TL HVM', 'price': 'Rs. 140,000 - 160,000'},
      {'name': 'Homage Vertex HVN 5010', 'price': 'Rs. 125,000 - 135,000'},
      {'name': 'Inverex Veyron 3.2KW', 'price': 'Rs. 110,000 - 120,000'},
    ],
  };

  // Function to upload data to Firestore
  Future<void> uploadRatesToFirestore() async {
    try {
      print("Initializing Firestore...");
      final firestore = FirebaseFirestore.instance;

      print("Uploading data...");
      await firestore.collection('rates').doc('current_rates').set(ratesData);

      print("Upload success");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rates uploaded successfully')),
      );
    } catch (e, stackTrace) {
      print("Upload failed: $e\n$stackTrace");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload rates: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to Solar App',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            padding: EdgeInsets.all(constraints.maxWidth * 0.05),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Explore Solar Solutions',
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                Text(
                  'Discover the best solar panels, batteries, and inverters for your needs.',
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.045,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: constraints.maxHeight * 0.05),
                ElevatedButton(
                  onPressed: () {
                    uploadRatesToFirestore();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.1,
                      vertical: constraints.maxHeight * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: constraints.maxWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
