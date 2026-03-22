import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeveloperFeedbackForm extends StatefulWidget {
  @override
  _DeveloperFeedbackFormState createState() => _DeveloperFeedbackFormState();
}

class _DeveloperFeedbackFormState extends State<DeveloperFeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String name = prefs.getString('name') ?? 'Siswa Tanpa Nama';
      String kelas = prefs.getString('kelas') ?? 'Kelas Tidak Diketahui';
      String feedback = _feedbackController.text.trim();

      // Kirim data ke API Laravel
      try {
        final response = await http.post(
          Uri.parse('https://ilyasa.fazrilsh.com/api/feedback'),
          body: {
            'name': name,
            'kelas': kelas,
            'feedback': feedback,
          },
        );

        if (response.statusCode == 200) {
          // Tampilkan dialog sukses
          AwesomeDialog(
            context: context,
            dialogType: DialogType.noHeader,
            animType: AnimType.scale,
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.network(
                  'https://assets9.lottiefiles.com/packages/lf20_touohxv0.json',
                  width: 150,
                  height: 150,
                  fit: BoxFit.fill,
                ),
                SizedBox(height: 10),
                Text(
                  'Terima Kasih!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Masukan Anda telah kami terima.\nMari bersama mewujudkan aplikasi yang lebih inspiratif dan menyenangkan!',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            btnOkOnPress: () {},
          ).show();

          // Bersihkan input setelah pengiriman
          _feedbackController.clear();
        } else {
          // Tampilkan error jika gagal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengirim masukan, coba lagi nanti!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kirim Masukan ke Developer'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sampaikan Masukan Anda',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Bantu kami menyempurnakan aplikasi dengan masukan, kritik, atau saran yang konstruktif.',
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: _feedbackController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Tulis masukan Anda di sini...',
                        hintText: 'Contoh: "Tolong tambahkan fitur X agar lebih menarik!"',
                        labelStyle: TextStyle(color: Colors.blueGrey[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey[700]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Masukan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitFeedback,
                        icon: Icon(Icons.send),
                        label: Text('Kirim Masukan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}