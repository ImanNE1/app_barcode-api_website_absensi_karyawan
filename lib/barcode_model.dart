import 'dart:convert';

// Fungsi untuk mengubah JSON string menjadi List<Barcode>
List<Barcode> barcodeFromJson(String str) =>
    List<Barcode>.from(json.decode(str).map((x) => Barcode.fromJson(x)));

class Barcode {
  final int id;
  final String name;
  final String value;
  final double latitude;
  final double longitude;
  final int radius;

  Barcode({
    required this.id,
    required this.name,
    required this.value,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  factory Barcode.fromJson(Map<String, dynamic> json) => Barcode(
    id: json["id"],
    name: json["name"],
    value: json["value"],
    latitude: double.tryParse(json["latitude"].toString()) ?? 0.0,
    longitude: double.tryParse(json["longitude"].toString()) ?? 0.0,
    radius: json["radius"],
  );
}
