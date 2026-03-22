import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart'; // Import yang diperlukan

class NewsEventScreen extends StatefulWidget {
  @override
  _NewsEventScreenState createState() => _NewsEventScreenState();
}

class _NewsEventScreenState extends State<NewsEventScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String eventStatus = 'Coming Soon';
  String eventType = 'news'; // Defaultnya 'news'
  List<Map<String, dynamic>> newsEvents = [];
  Uint8List? selectedImageBytes;

  void _onEventTypeChanged(String? value) {
    setState(() {
      eventType = value ?? 'news';
    });
  }

  // Fungsi untuk memilih gambar event
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        selectedImageBytes = result.files.first.bytes;
      });
    } else {
      print('No file selected');
    }
  }

  // Fungsi untuk memilih tanggal
  Future<void> _pickDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        dateController.text = "${selectedDate.toLocal()}".split(' ')[0]; // Format ke yyyy-mm-dd
      });
    }
  }

  // Fungsi untuk mengirim data event ke backend (API POST)
  Future<void> _uploadNewsEvent() async {
    if (selectedImageBytes == null) {
      print("Gambar belum dipilih");
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://ilyasa.fazrilsh.com/api/events'),
      );

      // Tambahkan field ke request
      request.fields['title'] = titleController.text;
      request.fields['description'] = descController.text;
      request.fields['location'] = locationController.text;
      request.fields['status'] = eventStatus;
      request.fields['is_news'] = (eventType == 'news') ? '1' : '0';
      request.fields['is_event'] = (eventType == 'event') ? '1' : '0';
      request.fields['date'] = dateController.text;

      // Tambahkan file gambar ke request
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        selectedImageBytes!,
        filename: 'event_image.jpg', // Nama file gambar
        contentType: MediaType('image', 'jpeg'),
      ));

      // Kirim request
      var response = await request.send();

      print("Response Status: ${response.statusCode}");

      if (response.statusCode == 201) {
        print("Event berhasil ditambahkan");
        _fetchNewsEvents(); // Refresh data
        setState(() {
          titleController.clear();
          descController.clear();
          locationController.clear();
          dateController.clear();
          selectedImageBytes = null;
        });
      } else {
        print("Gagal menambahkan event. Status: ${response.statusCode}");
        print(await response.stream.bytesToString()); // Print response body jika ada error
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Fungsi untuk mengambil data event dari backend (API GET)
  Future<void> _fetchNewsEvents() async {
    try {
      final response = await http.get(Uri.parse('https://ilyasa.fazrilsh.com/api/events'));
      if (response.statusCode == 200) {
        final List<dynamic> eventList = jsonDecode(response.body);
        if (eventList != null && eventList.isNotEmpty) {
          setState(() {
            newsEvents = eventList.map((event) {
              return {
                "title": event["judul"] ?? 'No Title',
                "description": event["isi"] ?? 'No Description',
                "status": event["status_event"] ?? 'Coming Soon',
                "location": event["lokasi"] ?? 'No Location',
                "image": event["gambar"] ?? '', // URL gambar
              };
            }).toList();
          });
        } else {
          print("No events found.");
        }
      } else {
        print("Gagal memuat data event. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error saat memuat data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNewsEvents(); // Ambil data saat halaman dimuat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Berita & Event")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Title Field
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Judul Berita/Event",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            SizedBox(height: 12),

            // Event Description Field
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: "Deskripsi",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 12),

            // Event Location Field
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: "Lokasi",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            SizedBox(height: 12),

            // Date Picker Field
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Tanggal Event",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: _pickDate,
            ),
            SizedBox(height: 12),

            // Event Status Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Status Event:"),
                DropdownButton<String>(
                  value: eventStatus,
                  onChanged: (String? newValue) {
                    setState(() {
                      eventStatus = newValue ?? 'Coming Soon'; // Default value if null
                    });
                  },
                  items: <String>['Coming Soon', 'Berlangsung']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Event Type Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tipe Event:"),
                DropdownButton<String>(
                  value: eventType,
                  onChanged: _onEventTypeChanged,
                  items: <String>['news', 'event']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value == 'news' ? 'Berita' : 'Event'),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),

            // File Picker Button
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text("Pilih Gambar Event"),
            ),
            SizedBox(height: 10),

            // Display Selected Image (if any)
            selectedImageBytes != null
                ? Image.memory(
                    selectedImageBytes!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  )
                : Text("Tidak ada gambar yang dipilih"),

            SizedBox(height: 20),

            // Add Event Button
            ElevatedButton(
              onPressed: _uploadNewsEvent,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                backgroundColor: Colors.blue,
              ),
              child: Text("Tambah Berita/Event"),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
