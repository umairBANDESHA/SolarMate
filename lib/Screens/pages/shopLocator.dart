// ryk coordinates: 28.4208° N, 70.3138° E

//  ===> PIN +Rift#cyrus@161;
// www.solarmate.com

// new mail bandesha.014 PIN ==> 343--
// Key => AlzaSyHBYEE94jiaPW5YmPvSsGDKC1stHEJyvsc
// 1.   https://newsapi.org/v2/everything?q=solarpanels&apiKey=?
// 2.   https://newsapi.org/v2/everything?q=solarpanels&from=2025-02-20&to=&sortBy=popularity&apiKey=
// 3.   https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey

// new API for location ==> AlzaSyMVqdGKGvkavXpOyMXjAZJxzKODsnJRvuD
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../colors.dart';

class ShopLocatorPage extends StatefulWidget {
  const ShopLocatorPage({super.key});

  @override
  _ShopLocatorState createState() => _ShopLocatorState();
}

class _ShopLocatorState extends State<ShopLocatorPage> {
  final String apiKey = 'AlzaSyHBYEE94jiaPW5YmPvSsGDKC1stHEJyvsc';
  bool isLoading = false;
  String error = '';
  List<dynamic> results = [];
  final TextEditingController _cityController = TextEditingController();

  double? positionLatitude;
  double? positionLongitude;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      await _getCurrentLocation();
      handleSearch();
    } else {
      setState(() {
        error = 'Location permission denied. Enter city manually.';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        positionLatitude = position.latitude;
        positionLongitude = position.longitude;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to get location. Enter city manually.';
      });
    }
  }

  Future<void> handleSearch() async {
    setState(() {
      isLoading = true;
      error = '';
      results = [];
    });

    try {
      String queryLocation = _cityController.text.trim();
      String locationString;
      String query = 'solar panel shop near me';

      if (queryLocation.isEmpty &&
          positionLatitude != null &&
          positionLongitude != null) {
        locationString = '$positionLatitude,$positionLongitude';
      } else {
        locationString = queryLocation.replaceAll(RegExp(r'\s+'), '+');
        query = 'solar panel shop in $locationString';
      }

      final apiUrl =
          'https://maps.gomaps.pro/maps/api/place/textsearch/json?query=$query&location=$locationString&key=$apiKey';

      final response = await Dio().get(apiUrl);

      setState(() {
        results = response.data['results'];
        if (results.isEmpty) {
          error =
              'No shops found for "${_cityController.text}". Try another location.';
        }
      });
    } catch (e) {
      setState(() {
        error = 'Failed to fetch results. Please try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _openGoogleMaps(double latitude, double longitude) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not open Google Maps.');
    } else {
      debugPrint('Launching Google Maps');
    }
  }

  void _callShop(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      debugPrint('Could not initiate call.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shop Locator',
          style: TextStyle(color: AppColors.accentWhite),
        ),
        backgroundColor: AppColors.primaryBlue,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Enter City Name',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: handleSearch,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.my_location, color: AppColors.accentWhite),
              onPressed: handleSearch,
              label: const Text(
                'Use My Location',
                style: TextStyle(color: AppColors.accentWhite),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 10),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.red))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    final name = item['name'] ?? 'Unknown';
                    final address = item['formatted_address'] ?? 'No address';
                    final latitude = item['geometry']['location']['lat'];
                    final longitude = item['geometry']['location']['lng'];
                    final phone = item['formatted_phone_number'] ?? '';

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: const Icon(
                          Icons.store,
                          color: AppColors.primaryBlue,
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            if (phone.isNotEmpty)
                              Text(
                                'Contact: $phone',
                                style: const TextStyle(color: Colors.black87),
                              ),
                          ],
                        ),
                        trailing: Wrap(
                          spacing: 12,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.location_on_outlined,
                                color: Colors.red,
                              ),
                              onPressed:
                                  () => _openGoogleMaps(latitude, longitude),
                            ),
                            if (phone.isNotEmpty)
                              IconButton(
                                icon: const Icon(
                                  Icons.phone,
                                  color: Colors.green,
                                ),
                                onPressed: () => _callShop(phone),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
