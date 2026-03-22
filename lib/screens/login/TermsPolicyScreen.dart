import 'package:flutter/material.dart';

class TermsPolicyScreen extends StatelessWidget {
  const TermsPolicyScreen({Key? key}) : super(key: key);

  final String _termsText = """
TERMS OF POLICY

1. Pendaftaran dan Akun
------------------------
- Pengguna harus mendaftarkan akun dengan informasi yang valid dan akurat.
- Anda bertanggung jawab atas keamanan kata sandi dan data akun.

2. Privasi dan Keamanan Data
-----------------------------
- Data pribadi Anda akan disimpan dengan aman dan tidak akan dibagikan tanpa izin.
- Kami menerapkan protokol keamanan yang tinggi untuk melindungi data Anda.

3. Hak Cipta dan Konten
-----------------------
- Semua konten dalam aplikasi ini dilindungi oleh hak cipta.
- Anda tidak diperkenankan untuk mendistribusikan ulang konten tanpa izin resmi.

4. Penggunaan Aplikasi
----------------------
- Anda setuju untuk menggunakan aplikasi ini sesuai dengan peraturan dan hukum yang berlaku.
- Penyalahgunaan aplikasi dapat mengakibatkan pemblokiran akun.

5. Perubahan Terms of Policy
----------------------------
- Kami berhak mengubah Terms of Policy ini sewaktu-waktu tanpa pemberitahuan sebelumnya.
- Perubahan akan segera berlaku setelah dipublikasikan dalam aplikasi.

6. Tanggung Jawab Pengguna
--------------------------
- Anda bertanggung jawab atas seluruh aktivitas yang dilakukan melalui akun Anda.
- Kami tidak bertanggung jawab atas kehilangan data yang diakibatkan oleh kelalaian pengguna.

7. Dukungan dan Kontak
----------------------
- Jika Anda memiliki pertanyaan atau keluhan, silakan hubungi layanan pelanggan kami:
  Email: support@smkn1tangerang.sch.id
  Telepon: (021) 12345678

Dengan menggunakan aplikasi ini, Anda menyetujui seluruh syarat dan ketentuan yang tercantum di atas.
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms of Policy", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Text(
          _termsText,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
