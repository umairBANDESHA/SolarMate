// ignore: file_names
import '../../colors.dart';
import 'package:flutter/material.dart';

class InverterDetailsPage extends StatelessWidget {
  final List<Map<String, dynamic>> inverters = [
    {
      "brand": "Huawei Solar ",
      "models": [
        {
          "model": "Huawei SUN2000-30KTL-M3",
          "power_rating": "30 kW",
          "efficiency": "98.6%",
          "price_range": "₨780,000 - ₨800,000",
          "warranty": "10 years",
          "best_use_case": "Large commercial & industrial setups",
        },
        {
          "model": "Huawei SUN2000-5KTL-L1",
          "power_rating": "5 kW",
          "efficiency": "98.4%",
          "price_range": "₨225,000 - ₨240,000",
          "warranty": "10 years",
          "best_use_case": "Residential & small businesses",
        },
      ],
    },
    {
      "brand": "Fronius ",
      "models": [
        {
          "model": "Fronius 27 KW Eco System",
          "power_rating": "27 kW",
          "efficiency": "98.3%",
          "price_range": "₨612,845 - ₨631,000",
          "warranty": "5-7 years",
          "best_use_case": "Large commercial installations",
        },
        {
          "model": "Fronius Hybrid Inverter PV 3200 3KW",
          "power_rating": "3 kW",
          "efficiency": "94%",
          "price_range": "₨92,900 - ₨94,000",
          "warranty": "5-7 years",
          "best_use_case": "Small to medium homes",
        },
      ],
    },
    {
      "brand": "SolarEdge ",
      "models": [
        {
          "model": "SolarEdge SE10K",
          "power_rating": "10 kW",
          "efficiency": "98.3%",
          "price_range": "₨500,000 - ₨520,000",
          "warranty": "12 years",
          "best_use_case": "Commercial & industrial applications",
        },
        {
          "model": "SolarEdge SE3680H",
          "power_rating": "3.68 kW",
          "efficiency": "98.8%",
          "price_range": "₨180,000 - ₨195,000",
          "warranty": "12 years",
          "best_use_case": "Residential solar setups",
        },
      ],
    },
    {
      "brand": "GoodWe ",
      "models": [
        {
          "model": "GoodWe GW10K-ET",
          "power_rating": "10 kW",
          "efficiency": "98.2%",
          "price_range": "₨420,000 - ₨450,000",
          "warranty": "10 years",
          "best_use_case": "Hybrid solar installations",
        },
        {
          "model": "GoodWe GW5000D-NS",
          "power_rating": "5 kW",
          "efficiency": "97.8%",
          "price_range": "₨190,000 - ₨210,000",
          "warranty": "10 years",
          "best_use_case": "Small to medium homes",
        },
      ],
    },
    {
      "brand": "SMA ",
      "models": [
        {
          "model": "SMA Sunny Boy 5.0",
          "power_rating": "5 kW",
          "efficiency": "97.5%",
          "price_range": "₨250,000 - ₨270,000",
          "warranty": "10 years",
          "best_use_case": "Residential & small business setups",
        },
        {
          "model": "SMA Sunny Tripower 10.0",
          "power_rating": "10 kW",
          "efficiency": "98.6%",
          "price_range": "₨480,000 - ₨500,000",
          "warranty": "10 years",
          "best_use_case": "Commercial installations",
        },
      ],
    },
    {
      "brand": "Growatt ",
      "models": [
        {
          "model": "Growatt MIN 5000TL-X",
          "power_rating": "5 kW",
          "efficiency": "98.4%",
          "price_range": "₨180,000 - ₨200,000",
          "warranty": "5 years",
          "best_use_case": "Residential solar setups",
        },
        {
          "model": "Growatt MID 15KTL3-X",
          "power_rating": "15 kW",
          "efficiency": "98.7%",
          "price_range": "₨500,000 - ₨530,000",
          "warranty": "5 years",
          "best_use_case": "Commercial & industrial use",
        },
      ],
    },
    {
      "brand": "Inverex (Pvt) Ltd",
      "models": [
        {
          "model": "Inverex Nitrox 5KW",
          "power_rating": "5 kW",
          "efficiency": "97.8%",
          "price_range": "₨140,000 - ₨155,000",
          "warranty": "5 years",
          "best_use_case": "Hybrid solar solutions",
        },
        {
          "model": "Inverex Veyron 10KW",
          "power_rating": "10 kW",
          "efficiency": "98.2%",
          "price_range": "₨300,000 - ₨320,000",
          "warranty": "5 years",
          "best_use_case": "Residential & commercial setups",
        },
      ],
    },
    {
      "brand": "Schneider Electric ",
      "models": [
        {
          "model": "Schneider XW Pro 6848",
          "power_rating": "6.8 kW",
          "efficiency": "96.5%",
          "price_range": "₨450,000 - ₨470,000",
          "warranty": "10 years",
          "best_use_case": "Hybrid solar and backup power",
        },
        {
          "model": "Schneider SW 4024",
          "power_rating": "4 kW",
          "efficiency": "95.8%",
          "price_range": "₨220,000 - ₨240,000",
          "warranty": "10 years",
          "best_use_case": "Off-grid applications",
        },
      ],
    },
    {
      "brand": "ABB ",
      "models": [
        {
          "model": "ABB PVS-100-TL",
          "power_rating": "100 kW",
          "efficiency": "98.9%",
          "price_range": "₨2,500,000 - ₨2,600,000",
          "warranty": "10 years",
          "best_use_case": "Large commercial & industrial projects",
        },
        {
          "model": "ABB UNO-DM-3.3-TL",
          "power_rating": "3.3 kW",
          "efficiency": "97.6%",
          "price_range": "₨160,000 - ₨175,000",
          "warranty": "10 years",
          "best_use_case": "Residential solar setups",
        },
      ],
    },
    {
      "brand": "Delta Electronics ",
      "models": [
        {
          "model": "Delta M50A",
          "power_rating": "50 kW",
          "efficiency": "98.5%",
          "price_range": "₨1,200,000 - ₨1,250,000",
          "warranty": "10 years",
          "best_use_case": "Large-scale industrial applications",
        },
        {
          "model": "Delta RPI M10A",
          "power_rating": "10 kW",
          "efficiency": "98.2%",
          "price_range": "₨350,000 - ₨370,000",
          "warranty": "10 years",
          "best_use_case": "Commercial solar setups",
        },
      ],
    },
  ];

  InverterDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Solar Inverters",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: inverters.length,
          itemBuilder: (context, index) {
            var brand = inverters[index];
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand['brand'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...brand['models'].map<Widget>((model) {
                      return _buildModelCard(model);
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModelCard(Map<String, dynamic> model) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model['model'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          // Wrap the Row in a Container with a finite width
          SizedBox(
            width: double.infinity, // Ensure the Row has a bounded width
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  // Use Flexible instead of Expanded
                  child: _infoText("⚡ Power", model['power_rating']),
                ),
                Flexible(
                  // Use Flexible instead of Expanded
                  child: _infoText("⚙ Efficiency", model['efficiency']),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          _infoText("💰 Price", model['price_range']),
          _infoText("🛡 Warranty", model['warranty']),
          _infoText("🏠 Best Use", model['best_use_case']),
        ],
      ),
    );
  }

  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
