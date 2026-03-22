import 'package:flutter/material.dart';

const Color primaryBackgroundColor = Color(0xFFF1F5F9); // Putih kebiruan lembut, modern dan menenangkan
const Color primaryAccentColor = Color(0xFF6200EE); // Ungu cerah, elegan dan memberikan aksen kuat
const Color secondaryAccentColor = Color(0xFF03DAC6); // Teal terang yang menyegarkan
const Color overlayBackgroundColor = Color(0xFFE0E0E0); // Abu-abu netral yang lembut
const Color textPrimaryColor = Color(0xFF212121); // Abu-abu gelap untuk teks utama, mudah dibaca
const Color secondaryBackgroundColor = Color(0xFFE8F4FA); // Biru muda sangat lembut, memberikan kesan sejuk
const Color greyTextColor = Color(0xFF757575); // Abu-abu sedang, lembut untuk teks pendukung
const Color sliderBackgroundColor = Color(0xFFFFFFFF); // Putih bersih untuk kontras tinggi dengan slider
const Color profileAvatarBackgroundColor = Color(0xFFBB86FC); // Ungu pastel lembut, cocok untuk avatar
const Color profileAvatarIconColor = Color(0xFF6200EE); // Ungu gelap untuk ikon, memberikan kesan berani
const Color activeDotColor = Color(0xFF6200EE); // Ungu cerah sebagai indikator aktif
const Color inactiveDotColor = Color(0xFFBDBDBD); // Abu-abu terang untuk indikator non-aktif
const Color qrMenuItemColor = Color(0xFF03DAC6); // Teal terang untuk QR menu, memberikan nuansa fresh
const Color eventMenuItemColor = Color(0xFF1DE9B6); // Teal yang lebih terang untuk event menu
const Color leaderboardMenuItemColor = Color(0xFFFFD600); // Kuning cerah, memberikan aksen ceria untuk leaderboard
const Color quizMenuItemColor = Color(0xFFFF5722); // Oranye cerah yang energik untuk quiz menu

// Warna tambahan dari kode dashboard
const Color cardBackgroundColor = primaryAccentColor; // Menggunakan warna ungu cerah
const Color sidebarBackgroundColor = primaryAccentColor; // Sama dengan warna AppBar
const Color sidebarIconColor = secondaryAccentColor; // Teal untuk ikon di sidebar
const Color sidebarTextColor = Colors.white; // Putih untuk teks di sidebar
const Color dashboardTileTextColor = Colors.white; // Warna teks pada tile dashboard

// Padding dan radius
const EdgeInsets globalPadding = EdgeInsets.all(16.0);
const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(16));

// Konstanta lain untuk teks default
const TextStyle titleTextStyle = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.bold,
  color: textPrimaryColor,
);

const TextStyle tileTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: dashboardTileTextColor,
);

