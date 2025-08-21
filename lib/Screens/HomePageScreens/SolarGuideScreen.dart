import '../../colors.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class SolarGuideScreen extends StatelessWidget {
  const SolarGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Solar Panel Guide",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Colors.white, // Change icon (back arrow) color
          size: 28, // Optional: increase size to make it appear bolder
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Types of Solar Panels
            const Text(
              "Types of Solar Panels",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPanelType(
              context,
              "Monocrystalline Panels",
              "Efficiency: 18-22%\nLifespan: 25-30 years\nBest for: Limited roof space, high temperatures\nCost: Premium price (₨70,000-90,000 per kW)",
              "assets/Panels/mono_panel.png", // Add image path
            ),
            _buildPanelType(
              context,
              "Polycrystalline Panels",
              "Efficiency: 15-17%\nLifespan: 23-27 years\nBest for: Budget installations, larger roof areas\nCost: Mid-range price (₨50,000-70,000 per kW)",
              "assets/Panels/poly_panel.png", // Add image path
            ),
            _buildPanelType(
              context,
              "Thin-Film Panels",
              "Efficiency: 10-13%\nLifespan: 15-20 years\nBest for: Flexible installations, architectural integration\nCost: Lower price (₨40,000-60,000 per kW)",
              "assets/Panels/thin_film_panel.png", // Add image path
            ),

            // Sizing Your Solar System
            const SizedBox(height: 20),
            const Text(
              "Sizing Your Solar System",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSizingGuide(
              "Small Home (1-2 rooms)",
              "System: 1-2 kW\nAppliances: Fans, lights, TV, fridge\nAvg. Consumption: 3-5 kWh/day",
              Icons.home, // Icon for small home
            ),
            _buildSizingGuide(
              "Medium Home (3-4 rooms)",
              "System: 3-5 kW\nAppliances: Fans, lights, TV, fridge, ACs\nAvg. Consumption: 8-12 kWh/day",
              Icons.home_work, // Icon for medium home
            ),
            _buildSizingGuide(
              "Large Home (5+ rooms)",
              "System: 5-10 kW\nAppliances: Multiple ACs, water heater\nAvg. Consumption: 15-25 kWh/day",
              Icons.business, // Icon for large home
            ),

            // Local Factors in Pakistan
            const SizedBox(height: 20),
            const Text(
              "Important Factors in Pakistan",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInstallationTip(
              "Local Factors",
              "☀️ Higher temperatures reduce efficiency (0.3-0.5% per °C above 25°C)\n💨 Dust needs regular cleaning (every 2-4 weeks)\n🌧️ Monsoon season: Waterproofing is crucial\n⚡ Grid-Tie Regulations: Check with local electricity providers.",
            ),

            // Choosing an Installer
            const SizedBox(height: 20),
            const Text(
              "Selecting a Qualified Installer",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInstallationTip(
              "Choosing an Installer",
              "✅ Experience in Pakistan\n✅ Certifications and licenses\n✅ References and reviews\n✅ Warranty on workmanship",
            ),

            // Maintenance Tips
            const SizedBox(height: 20),
            const Text(
              "Maintaining Your Solar System",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInstallationTip(
              "Maintenance Tips",
              "💧 Regular cleaning\n🔌 Check wiring\n📊 Monitor performance\n🔋 Battery maintenance",
            ),

            // Disclaimer
            const SizedBox(height: 20),
            const Text(
              "Disclaimer",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "This guide provides general information. Consult with qualified solar professionals. Prices and specifications may vary. Local regulations and incentives are subject to change.",
              style: TextStyle(fontSize: 14),
            ),

            // Useful Links
            const SizedBox(height: 20),
            const Text(
              "Useful Links",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildLink(
              "Alternative Energy Development Board (AEDB)",
              "https://www.aedb.org",
            ),
            _buildLink("Local Electricity Provider", "https://www.example.com"),

            // Final Message
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "This guide helps homeowners understand solar energy needs in Pakistan!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget for Solar Panel Type
  Widget _buildPanelType(
    BuildContext context,
    String title,
    String details,
    String imagePath,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => openFullScreen(context, [imagePath], 0),
                child: Image.asset(
                  imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ), // Panel image
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(details, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for Sizing Guide
  Widget _buildSizingGuide(String title, String details, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: AppColors.primaryBlue), // Home icon
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(details, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for Installation Considerations
  Widget _buildInstallationTip(String title, String details) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(details, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for Useful Links
  Widget _buildLink(String text, String url) {
    return GestureDetector(
      onTap: () {
        // Open URL in browser
      },
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  // Method to open full-screen image
  void openFullScreen(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                FullScreenImage(images: images, initialIndex: initialIndex),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImage({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: images.length,
            pageController: PageController(initialPage: initialIndex),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: AssetImage(images[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
