import '../components/appliances.dart';

class SolarCalculator {
  static Map<String, dynamic> calculateSolarSetup({
    required int backupHours,
    required List<Appliance> appliances,
    required int selectedCalculationMethod,
    required String? unitsInput,
    int systemVoltage = 24, // Default to 24V
  }) {
    // Validation
    if (selectedCalculationMethod == 1 &&
        (unitsInput == null || unitsInput.isEmpty)) {
      throw Exception('Please enter monthly units');
    }
    if (selectedCalculationMethod == 0 && appliances.isEmpty) {
      throw Exception('Please add at least one appliance');
    }

    // Common calculation constants
    const double averageDailySunHours = 5;
    const double systemEfficiency = 0.8;
    const double batteryDischargeRate = 0.5;
    const int batteryCapacityAh = 150; // Exide NS185

    int totalWattHours = 0;
    String calculationMethod = '';

    if (selectedCalculationMethod == 0) {
      for (var appliance in appliances) {
        totalWattHours +=
            appliance.wattage * appliance.quantity * appliance.usageHours;
      }
      calculationMethod = 'Based on ${appliances.length} appliances';
    } else {
      double monthlyUnits = double.parse(unitsInput!);
      totalWattHours = ((monthlyUnits * 1000) / 30).round();
      calculationMethod = 'Based on $monthlyUnits monthly units';
    }

    // Debug logging
    print(
      'Inputs: totalWattHours=$totalWattHours, backupHours=$backupHours, '
      'systemVoltage=$systemVoltage, appliances=$appliances',
    );

    // edit thesee
    //    // Solar Panels Calculation
    int solarPanelWattage =
        (totalWattHours / (averageDailySunHours * systemEfficiency)).ceil();
    int solarPanelQuantity = (solarPanelWattage / 580).ceil();

    // Batteries Calculation
    // Determine system voltage based on load
    if (totalWattHours <= 1000) {
      systemVoltage = 12;
    } else if (totalWattHours <= 5500) {
      systemVoltage = 24;
    } else {
      systemVoltage = 48;
    }

    // Batteries Calculation
    int batteryCapacityRequiredAh =
        ((totalWattHours * backupHours) /
                (systemVoltage * batteryDischargeRate))
            .ceil();
    int batteryQuantity =
        (batteryCapacityRequiredAh / batteryCapacityAh).ceil();

    // Inverter Size Calculation
    int inverterSize = 0;
    if (selectedCalculationMethod == 0 && appliances.isNotEmpty) {
      inverterSize =
          (appliances
                      .map(
                        (appliance) => appliance.wattage * appliance.quantity,
                      )
                      .reduce((a, b) => a > b ? a : b) *
                  1.2)
              .ceil();
    } else {
      if (totalWattHours < 2000) {
        inverterSize = 1000;
      } else if (totalWattHours < 4000) {
        inverterSize = 3000;
      } else if (totalWattHours < 6000) {
        inverterSize = 5000;
      } else if (totalWattHours < 8000) {
        inverterSize = 7000;
      } else if (totalWattHours < 10000) {
        inverterSize = 10000;
      }
    }

    return {
      'totalWattHours': totalWattHours,
      'calculationMethod': calculationMethod,
      'inverterSize': inverterSize,
      'solarPanelQuantity': solarPanelQuantity,
      'batteryQuantity': batteryQuantity,
      'batteryCapacityAh': batteryCapacityAh,
      'systemSize': (inverterSize / 1000).toStringAsFixed(1),
      'systemVoltage': systemVoltage,
    };
  }
}
