import 'package:flutter/material.dart';
import 'package:partani_mobile/pages/pembeli/pembeli_page.dart';
// import 'package:partani_mobile/pages/add_product.dart';
// import 'package:partani_mobile/pages/home_page.dart';
import 'package:partani_mobile/user_login/login.dart'; // Import halaman login

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      // Menghilangkan banner debug
      initialRoute: '/', // Tentukan halaman awal
      routes: {
        '/': (context) => PembeliPage(), // Halaman login
      },
    );
  }
}
