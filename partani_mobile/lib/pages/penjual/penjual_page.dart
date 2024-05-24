import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:partani_mobile/components/component%20penjual/bottombar_penjual.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:partani_mobile/pages/profile%20user/profile_page.dart';
import 'package:partani_mobile/user_login/login.dart';
import 'package:partani_mobile/pages/penjual/manage_product.dart';
import 'package:partani_mobile/pages/penjual/pesanan_page.dart';
import 'package:partani_mobile/pages/penjual/riwayat_pesananpenjual.dart';

class PenjualPage extends StatefulWidget {
  @override
  _PenjualPageState createState() => _PenjualPageState();
}

class _PenjualPageState extends State<PenjualPage> {
  int _selectedIndex = 0;
  int _jumlahPesananMasuk = 0;
  int _jumlahPesananDikonfirmasi = 0;
  late String token; // deklarasikan token

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
    token = prefs.getString('token') ?? '';

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

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      // Tambahkan pengecekan token sebelum logout
      String apiUrl = 'http://10.0.2.2:8000/api/user/logout';
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
        );

        if (response.statusCode == 200) {
          prefs.remove('token');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          print('Gagal logout: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void _onCardTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PesananPenjualPage(),
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RiwayatPesananPenjualPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Penjual Page'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout, // ubah onPressed menjadi logout()
          ),
        ],
      ),
      bottomNavigationBar: BottombarPenjual(),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: <Widget>[
          _buildCard(
              'Pesanan yang baru masuk', _jumlahPesananMasuk.toString(), 0),
          _buildCard(
              'Pesanan dikonfirmasi', _jumlahPesananDikonfirmasi.toString(), 1),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String subtitle, int index) {
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
        child: InkWell(
          onTap: () => _onCardTapped(index), // Navigasi ke halaman yang sesuai
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
            ),
          ),
        ),
      ),
    );
  }
}
