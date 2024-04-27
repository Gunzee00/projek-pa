import 'package:flutter/material.dart';
import 'package:partani_mobile/user_login/register_pembeli.dart'; // Ubah sesuai dengan import halaman pendaftaran pembeli
// Import halaman pendaftaran penjual jika ada
import 'package:partani_mobile/user_login/register_penjual.dart'; // Import halaman pendaftaran penjual

class RolePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Sebagai'),
      ),
      body: Center(
        child: Column(
          // Menggunakan Column untuk mengelompokkan logo, teks, dan tombol
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              height: 200, // Atur tinggi logo
              width: 200, // Atur lebar logo
            ), // Menambahkan logo di atas teks dan tombol
            SizedBox(height: 20), // Menambahkan jarak antara logo dan teks
            Text(
              'Daftar sebagai', // Teks di bawah logo
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20), // Menambahkan jarak antara teks dan tombol
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RegisterPembeliPage()), // Ubah sesuai dengan halaman pendaftaran pembeli
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF64AA54), // Text color
                  ),
                  child: Text('Pembeli'),
                ),
                SizedBox(width: 20), // Menambahkan jarak antara tombol
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RegisterPenjualPage()), // Ubah sesuai dengan halaman pendaftaran penjual
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF64AA54),
                    backgroundColor: Colors.white, // Text color
                    side: BorderSide(color: Color(0xFF64AA54)), // Border color
                  ),
                  child: Text('Penjual'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RolePage(),
  ));
}
