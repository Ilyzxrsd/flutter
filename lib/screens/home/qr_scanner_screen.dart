import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart'; // Import awesome_dialog

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String scannedData = "Belum ada data";

  @override
  void initState() {
    super.initState();
    scanQRCode(); // Mulai scan QR langsung setelah halaman terbuka
  }

  Future<void> scanQRCode() async {
    try {
      // Mulai scan QR langsung
      var result = await BarcodeScanner.scan();

      if (result.rawContent.isNotEmpty) {
        setState(() {
          scannedData = result.rawContent;
        });

        // Kirim data ke API
        sendDataToAPI(scannedData);
      }
    } catch (e) {
      setState(() {
        scannedData = "Error: $e";
      });
    }
  }

Future<void> sendDataToAPI(String baseUrl) async {
  try {
    // Ambil data siswa dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String username = prefs.getString('username') ?? "Tidak ada username";
    final String name = prefs.getString('name') ?? "Tidak ada nama";


    // Buat URL lengkap dengan parameter
    final String url = "$baseUrl?" +
        "username=${Uri.encodeComponent(username)}";

    // Kirim request ke API
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
    );

    if (response.statusCode == 201) {
      setState(() {
        scannedData = "Absensi berhasil untuk $name";
      });

      // Tampilkan dialog sukses menggunakan AwesomeDialog
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: "Berhasil!",
        desc: "Absensi berhasil untuk $name.",
        btnOkText: "OK",
        btnOkOnPress: () {
          Navigator.pushReplacementNamed(context, '/home'); // Ganti ke homescreen
        },
      ).show();
    } else {
      setState(() {
        scannedData = "Gagal mengirim data: ${response.body}";
      });

      // Tampilkan dialog gagal
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "Gagal!",
        desc: "Gagal mengirim data absensi.",
        btnOkText: "Coba Lagi",
        btnOkOnPress: () {},
      ).show();
    }
  } catch (e) {
    setState(() {
      scannedData = "Error saat mengirim data: $e";
    });

    // Tampilkan dialog error
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.leftSlide,
      title: "Error!",
      desc: "Terjadi kesalahan: $e",
      btnOkText: "Tutup",
      btnOkOnPress: () {},
    ).show();
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR Code"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              scannedData,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(), // Indikator loading selama scan
          ],
        ),
      ),
    );
  }
}
