import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:partani_mobile/pages/profile%20user/profile_page.dart';
import 'package:partani_mobile/user_login/login.dart';
import 'manage_product.dart'; // Import halaman Manage Product
import 'pesanan_page.dart'; // Import halaman Pesanan Page
import 'package:shared_preferences/shared_preferences.dart';

class PenjualPage extends StatefulWidget {
  @override
  _PenjualPageState createState() => _PenjualPageState();
}

class _PenjualPageState extends State<PenjualPage> {
  int _selectedIndex = 0;
  int _jumlahPesananMasuk = 0;
  int _jumlahPesananDikonfirmasi = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData(); // Panggil _fetchData() setiap kali terjadi perubahan dependensi
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    try {
      final masukResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/pesanan/count/masuk'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (masukResponse.statusCode == 200) {
        final data = json.decode(masukResponse.body);
        setState(() {
          _jumlahPesananMasuk = data['jumlah_pesanan_masuk'];
        });
      }

      final dikonfirmasiResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/pesanan/count/dikonfirmasi'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (dikonfirmasiResponse.statusCode == 200) {
        final data = json.decode(dikonfirmasiResponse.body);
        setState(() {
          _jumlahPesananDikonfirmasi = data['jumlah_pesanan_dikonfirmasi'];
        });
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManageProductPage()),
        );
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PesananPenjualPage()), // Navigasi ke PesananPage
        );
      } else if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfilePage()), // Navigasi ke PesananPage
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Penjual Page'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Color(0xFF64AA54),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business, color: Color(0xFF64AA54)),
            label: 'Manajemen Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt, color: Color(0xFF64AA54)),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Color(0xFF64AA54)),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF64AA54),
        onTap: _onItemTapped,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: <Widget>[
          _buildCard('Pesanan yang baru masuk', _jumlahPesananMasuk.toString()),
          _buildCard(
              'Pesanan dikonfirmasi', _jumlahPesananDikonfirmasi.toString()),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Card(
        color: Colors.white, // set card color to white
        child: Center(
          child: ListTile(
            title: Text(
              title,
              textAlign: TextAlign.center, // center align the title
            ),
            subtitle: Text(
              subtitle,
              textAlign: TextAlign.center, // center align the subtitle
            ),
            // Tambahkan onTap untuk menavigasi ke halaman detail pesanan jika diperlukan
          ),
        ),
      ),
    );
  }
}
