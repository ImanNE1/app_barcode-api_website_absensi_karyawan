// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- PERUBAHAN: Import Google Fonts
import 'package:qr_flutter/qr_flutter.dart';
import 'api_service.dart';
import 'barcode_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // PERUBAHAN: Mendefinisikan tema utama aplikasi di sini
    final baseTheme = ThemeData.light(useMaterial3: true);

    return MaterialApp(
      title: 'Data Barcode',
      debugShowCheckedModeBanner: false, // Menghilangkan banner "DEBUG"
      theme: baseTheme.copyWith(
        // PERUBAHAN: Skema warna baru yang lebih elegan
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003C5A), // Warna biru navy sebagai dasar
        ),
        // PERUBAHAN: Menggunakan font 'Poppins' untuk semua teks
        textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
        // PERUBAHAN: Tema khusus untuk AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003C5A), // Warna AppBar
          foregroundColor: Colors.white, // Warna teks di AppBar (putih)
          elevation: 2,
          centerTitle: true,
        ),
        // PERUBAHAN: Tema khusus untuk Card
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const BarcodeListPage(),
    );
  }
}

class BarcodeListPage extends StatefulWidget {
  const BarcodeListPage({super.key});

  @override
  State<BarcodeListPage> createState() => _BarcodeListPageState();
}

class _BarcodeListPageState extends State<BarcodeListPage> {
  late Future<List<Barcode>> futureBarcodes;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futureBarcodes = apiService.fetchBarcodes();
  }

  // Fungsi untuk menampilkan dialog (tidak berubah)
  void _showQrDialog(BuildContext context, Barcode barcode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            barcode.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 250,
            height: 250,
            child: QrImageView(
              data: barcode.value,
              version: QrVersions.auto,
              size: 250.0,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            FilledButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk memuat ulang data dari API
  Future<void> _reloadData() async {
    setState(() {
      futureBarcodes = apiService.fetchBarcodes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Barcode Lokasi')),
      // PERUBAHAN UTAMA: Menambahkan RefreshIndicator
      body: RefreshIndicator(
        onRefresh: _reloadData, // Memanggil fungsi untuk memuat ulang data
        child: FutureBuilder<List<Barcode>>(
          future: futureBarcodes,
          builder: (context, snapshot) {
            // Jika koneksi sedang menunggu, tampilkan loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // Jika ada error
            else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            // Jika data berhasil dimuat dan tidak kosong
            else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final barcodes = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: barcodes.length,
                itemBuilder: (context, index) {
                  final barcode = barcodes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer,
                        child: const Icon(Icons.qr_code_scanner_rounded),
                      ),
                      title: Text(
                        barcode.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        // crossAxisAlignment.start membuat teks rata kiri
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Value: ${barcode.value}"),
                          Text("Radius: ${barcode.radius} meter"),
                          Text(
                            "Koordinat: ${barcode.latitude}, ${barcode.longitude}",
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        _showQrDialog(context, barcode);
                      },
                    ),
                  );
                },
              );
            }
            // Jika tidak ada data
            else {
              // Menambahkan pesan ini di tengah layar agar lebih rapi
              return const Center(child: Text('Tidak ada data barcode.'));
            }
          },
        ),
      ),
    );
  }
}
