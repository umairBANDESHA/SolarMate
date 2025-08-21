import 'package:flutter/material.dart';
import '../../colors.dart';

class SolarResultDialog extends StatelessWidget {
  final Map<String, dynamic> results;
  final int selectedCalculationMethod;

  const SolarResultDialog({
    super.key,
    required this.results,
    required this.selectedCalculationMethod,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Solar Setup Results',
        style: TextStyle(color: AppColors.primaryBlue),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              results['calculationMethod'],
              style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Daily Consumption:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${results['totalWattHours']}Wh',
              style: const TextStyle(color: AppColors.darkGrey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recommended System:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${results['systemSize']}kW system',
              style: const TextStyle(color: AppColors.darkGrey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Solar Panels:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${results['solarPanelQuantity']} panels (580W each)',
              style: const TextStyle(color: AppColors.darkGrey),
            ),
            const SizedBox(height: 10),
            const Text(
              'Batteries:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${results['batteryQuantity']} batteries (150Ah, ${results['systemVoltage']}V each)',
              style: const TextStyle(color: AppColors.darkGrey),
            ),

            // Text(
            //   'One battery can support ${results['singleBatteryWh'].toStringAsFixed(0)}Wh '
            //   'for ${(results['singleBatteryHours'] * results['batteryQuantity']).toStringAsFixed(1)} hours.',
            //   style: const TextStyle(color: AppColors.darkGrey, fontSize: 12),
            // ),
            const SizedBox(height: 10),
            if (selectedCalculationMethod == 0) ...[
              const Text(
                'Inverter Size:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${results['inverterSize']}W',
                style: const TextStyle(color: AppColors.darkGrey),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'OK',
            style: TextStyle(color: AppColors.buttonPurple),
          ),
        ),
      ],
    );
  }
}
