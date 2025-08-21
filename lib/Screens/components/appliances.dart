// models/appliance.dart
class Appliance {
  String name;
  int wattage;
  int quantity;
  int usageHours;

  Appliance({
    required this.name,
    required this.wattage,
    required this.quantity,
    required this.usageHours,
  });

  factory Appliance.fromString(String str) {
    final parts = str.split('|');
    return Appliance(
      name: parts[0],
      wattage: int.parse(parts[1]),
      quantity: int.parse(parts[2]),
      usageHours: int.parse(parts[3]),
    );
  }

  @override
  String toString() {
    return '$name|$wattage|$quantity|$usageHours';
  }
}
