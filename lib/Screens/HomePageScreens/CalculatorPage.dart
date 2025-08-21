import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../colors.dart';
import '../components/appliances.dart'; // Import Appliance model
import '../components/solarCalculator.dart'; // Import SolarCalculator utility
import '../components/solarResultDialoug.dart'; // Import SolarResultDialog widget
import '../components/appliances_data.dart'; // Import the appliance list

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  _SolarCalculatorPageState createState() => _SolarCalculatorPageState();
}

class _SolarCalculatorPageState extends State<CalculatorPage> {
  int _backupHours = 1;
  List<Appliance> _appliances = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _wattageController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );
  final TextEditingController _unitsController = TextEditingController();
  int _usageHours = 1;
  int _selectedCalculationMethod = 0; // 0 = appliance, 1 = units
  bool _isManualEntry = false; // Track if "Others" is selected

  @override
  void initState() {
    super.initState();
    _loadAppliances();
  }

  Future<void> _loadAppliances() async {
    final prefs = await SharedPreferences.getInstance();
    final applianceStrings = prefs.getStringList('appliances') ?? [];
    setState(() {
      _appliances =
          applianceStrings.map((str) => Appliance.fromString(str)).toList();
    });
  }

  Future<void> _saveAppliances() async {
    final prefs = await SharedPreferences.getInstance();
    final applianceStrings =
        _appliances.map((appliance) => appliance.toString()).toList();
    await prefs.setStringList('appliances', applianceStrings);
  }

  void _addAppliance() {
    if (_nameController.text.isNotEmpty && _wattageController.text.isNotEmpty) {
      try {
        int wattage = int.parse(_wattageController.text);
        setState(() {
          _appliances.add(
            Appliance(
              name: _nameController.text,
              wattage: wattage,
              quantity: int.parse(_quantityController.text),
              usageHours: _usageHours,
            ),
          );
          _nameController.clear();
          _wattageController.clear();
          _quantityController.text = '1';
          _usageHours = 1;
          _isManualEntry = false;
          _saveAppliances();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid wattage')),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
    }
  }

  void _removeAppliance(int index) {
    setState(() {
      _appliances.removeAt(index);
      _saveAppliances();
    });
  }

  void _calculateSolarSetup() {
    try {
      print(
        'Calculating with appliances: $_appliances, backupHours: $_backupHours',
      );
      final results = SolarCalculator.calculateSolarSetup(
        backupHours: _backupHours,
        appliances: _appliances,
        selectedCalculationMethod: _selectedCalculationMethod,
        unitsInput:
            _unitsController.text.isNotEmpty ? _unitsController.text : null,
        systemVoltage: 24, // Explicitly set to 24V
      );

      showDialog(
        context: context,
        builder:
            (context) => SolarResultDialog(
              results: results,
              selectedCalculationMethod: _selectedCalculationMethod,
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showAppliancePicker() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Select Appliance',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
            content: SingleChildScrollView(
              child: Column(
                children:
                    predefinedAppliances.map((appliance) {
                      return ListTile(
                        title: Text(
                          appliance['name']!,
                          style: const TextStyle(color: AppColors.darkGrey),
                        ),
                        onTap: () {
                          setState(() {
                            _nameController.text = appliance['name']!;
                            if (appliance['name'] == 'Others') {
                              _isManualEntry = true;
                              _wattageController.clear();
                            } else {
                              _isManualEntry = false;
                              String wattage =
                                  appliance['wattage']!.split('–')[0];
                              _wattageController.text = wattage;
                            }
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.buttonPurple),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Solar Calculator',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
      ),
      backgroundColor: AppColors.lightGrey,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calculation Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<int>(
                      value: _selectedCalculationMethod,
                      items: const [
                        DropdownMenuItem(
                          value: 0,
                          child: Text(
                            'Appliance-Based Calculation',
                            style: TextStyle(color: AppColors.darkGrey),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text(
                            'Unit-Based Calculation',
                            style: TextStyle(color: AppColors.darkGrey),
                          ),
                        ),
                      ],
                      onChanged:
                          (value) => setState(() {
                            _selectedCalculationMethod = value!;
                          }),
                      isExpanded: true,
                      dropdownColor: AppColors.accentWhite,
                      style: const TextStyle(color: AppColors.darkGrey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backup Hours',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'How many hours of backup power do you need?',
                      style: TextStyle(fontSize: 14, color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<int>(
                      value: _backupHours,
                      items: List.generate(
                        24,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(
                            '${index + 1} hours',
                            style: const TextStyle(color: AppColors.darkGrey),
                          ),
                        ),
                      ),
                      onChanged:
                          (value) => setState(() => _backupHours = value!),
                      isExpanded: true,
                      dropdownColor: AppColors.accentWhite,
                      style: const TextStyle(color: AppColors.darkGrey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedCalculationMethod == 0) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Appliances',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Appliance Name',
                          labelStyle: TextStyle(color: AppColors.darkGrey),
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        style: const TextStyle(color: AppColors.darkGrey),
                        onTap: _showAppliancePicker,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _wattageController,
                        keyboardType: TextInputType.number,
                        readOnly: !_isManualEntry,
                        decoration: const InputDecoration(
                          labelText: 'Wattage',
                          labelStyle: TextStyle(color: AppColors.darkGrey),
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(color: AppColors.darkGrey),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          labelStyle: TextStyle(color: AppColors.darkGrey),
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(color: AppColors.darkGrey),
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<int>(
                        value: _usageHours,
                        items: List.generate(
                          24,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text(
                              '${index + 1} hours',
                              style: const TextStyle(color: AppColors.darkGrey),
                            ),
                          ),
                        ),
                        onChanged:
                            (value) => setState(() => _usageHours = value!),
                        isExpanded: true,
                        dropdownColor: AppColors.accentWhite,
                        style: const TextStyle(color: AppColors.darkGrey),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _addAppliance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonPurple,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Add Appliance',
                          style: TextStyle(color: AppColors.accentWhite),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_appliances.isNotEmpty)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Appliances',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._appliances.asMap().entries.map(
                          (entry) => ListTile(
                            title: Text(
                              '${entry.value.name} (${entry.value.wattage}W x ${entry.value.quantity}, ${entry.value.usageHours} hours)',
                              style: const TextStyle(color: AppColors.darkGrey),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeAppliance(entry.key),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ] else ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Electricity Usage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Enter your average monthly electricity consumption in units (kWh)',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _unitsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Monthly Units (kWh)',
                          labelStyle: TextStyle(color: AppColors.darkGrey),
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(color: AppColors.darkGrey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateSolarSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPurple,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Calculate Solar Setup',
                style: TextStyle(color: AppColors.accentWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
