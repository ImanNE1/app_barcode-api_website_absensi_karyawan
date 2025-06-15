import 'package:http/http.dart' as http;
import 'barcode_model.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.1.2:8000/api';

  Future<List<Barcode>> fetchBarcodes() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/barcodes'));

      if (response.statusCode == 200) {
        return barcodeFromJson(response.body);
      } else {
        throw Exception('Gagal memuat data barcodes');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
