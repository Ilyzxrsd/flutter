import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/event.dart'; // Impor model Event

class EventDetailScreen extends StatelessWidget {
  final Event event;

  EventDetailScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          event.judul,
          style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white, // Gaya sesuai dengan tema aplikasi
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul event
              Text(
                event.judul,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              
              // Tanggal event
              Text(
                event.tanggal,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700], // Sesuaikan warna tanggal
                ),
              ),
              SizedBox(height: 20),
              
              // Gambar event dengan error handling
              event.gambar.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: event.gambar,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(color: Colors.teal),
                      ),
                      errorWidget: (context, url, error) {
                        print('Error loading image: $error');
                        return Center(
                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        );
                      },
                    )
                  : Center(
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
              SizedBox(height: 20),

              // Deskripsi event
              Text(
                event.isi,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
