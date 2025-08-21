import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:newsample/Screens/components/chatbot.dart';
import '../../colors.dart';

class ResourcesPage extends StatelessWidget {
  ResourcesPage({super.key});

  final List<Map<String, String>> policies = [
    {
      "title": "Net Metering (NEPRA)",
      "description":
          "Net metering allows selling extra electricity to the grid. Only for 3-phase meters up to 1MW. NEPRA approval required.",
      "url": "https://www.nepra.org.pk/licensing/Net-Metering",
    },
    {
      "title": "Tax On Solar Panels",
      "description":
          "Panels, batteries, and inverters are often exempted to reduce cost.",
      "url": "https://maxgreenenergy.com.pk/tax-on-solar-panels-pakistan/",
    },
    {
      "title": "Alternative Energy Policy 2019",
      "description":
          "Targets 30% renewable energy by 2030. Incentives and ease of doing business included.",
      "url": "https://www.aedb.org/policies/alternative-energy-policy-2019",
    },
    {
      "title": "Solar Financing (SBP)",
      "description":
          "SBP offers low-interest loans for domestic/commercial solar setups.",
      "url": "https://www.sbp.org.pk/smefd/circulars/2021/C7.htm",
    },
    {
      "title": "Feed-in Tariff Programs",
      "description":
          "Some programs offer fixed payments for solar power supplied to grid.",
      "url": "https://www.nepra.org.pk/Feedin-Tariff",
    },
  ];

  final List<Map<String, String>> faqs = [
    {
      "q": "How much power does a 3-bedroom house need?",
      "a":
          "Typically, a 3-bedroom house needs 3-5 kW solar setup depending on appliance usage and backup hours.",
    },
    {
      "q": "How many panels are needed for 5kW?",
      "a":
          "You'll need around 13–15 panels of 400W each to reach 5kW capacity, depending on efficiency and location.",
    },
    {
      "q": "How long do batteries last?",
      "a":
          "Lead-acid batteries last around 2-3 years, while lithium-ion batteries can last 8-10 years with proper usage.",
    },
    {
      "q": "Is net metering available for single phase meters?",
      "a":
          "No, currently net metering in Pakistan is only approved for 3-phase meters with up to 1MW systems.",
    },
    {
      "q": "What type of inverter is best?",
      "a":
          "Hybrid inverters are recommended as they can work with batteries and the grid, giving flexibility in energy usage.",
    },
    {
      "q": "How to apply for net metering?",
      "a":
          "You need to submit an application to your regional DISCO, along with system specs, drawings, and inverter certificate.",
    },
    {
      "q": "Can solar panels run ACs?",
      "a":
          "Yes, but you need sufficient capacity and preferably hybrid systems with batteries to handle the load during night.",
    },
    {
      "q": "What is the cost of a 3kW solar setup?",
      "a":
          "A 3kW system with basic battery backup and hybrid inverter may cost around PKR 550,000 to 700,000.",
    },
    {
      "q": "Are solar systems reliable during winters?",
      "a":
          "Yes, though generation is slightly reduced. A battery system ensures consistent performance.",
    },
    {
      "q": "Which batteries are best for solar?",
      "a":
          "Lithium-ion batteries offer longer life, faster charging, and higher depth of discharge than lead-acid ones.",
    },
  ];

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resources", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Government Policies",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...policies.map(
            (p) => Card(
              elevation: 2,
              child: ListTile(
                title: Text(
                  p['title']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['description']!),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _launchURL(p['url']!),
                      child: Text(
                        p['url']!,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 32),
          const Text(
            "Frequently Asked Questions",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...faqs.map(
            (faq) => Card(
              elevation: 1,
              child: ExpansionTile(
                title: Text(faq['q']!),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(faq['a']!),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10), // extra space to avoid FAB overlap
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatbotWebView()),
              );
            },
            icon: const Icon(Icons.chat_rounded, color: AppColors.accentWhite),
            label: const Text(
              "Ask SolarMate AI",
              style: TextStyle(
                color: AppColors.accentWhite,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
