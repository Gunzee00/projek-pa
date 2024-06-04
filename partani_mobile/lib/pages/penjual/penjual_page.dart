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
  late String token = '';
  late String role = '';
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    initializeTokenAndRole();
    _fetchData();
  }

  Future<void> initializeTokenAndRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? '';
      role = prefs.getString('role') ?? '';
      if (role != 'penjual') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    try {
      final masukResponse = await http.get(
        Uri.parse('https://projek.cloud/api/pesanan/count/masuk'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (masukResponse.statusCode == 200) {
        final data = json.decode(masukResponse.body);
        setState(() {
          _jumlahPesananMasuk = data['jumlah_pesanan_masuk'];
        });
      }

      final dikonfirmasiResponse = await http.get(
        Uri.parse('https://projek.cloud/api/pesanan/count/dikonfirmasi'),
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

  Future<void> _fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('token') ?? '';

    final url = Uri.parse('https://projek.cloud/api/user/profile');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userInfo = json.decode(response.body);
      });
    } else {
      print("Gagal menampilkan profil");
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      String apiUrl = 'https://projek.cloud/api/user/logout';
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
          prefs.remove('role');
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
            onPressed: logout,
          ),
        ],
      ),
      bottomNavigationBar: BottombarPenjual(),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children: <Widget>[
                  _buildCard(
                    'Pesanan yang baru masuk',
                    _jumlahPesananMasuk.toString(),
                    0,
                  ),
                  _buildCard(
                    'Pesanan dikonfirmasi',
                    _jumlahPesananDikonfirmasi.toString(),
                    1,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageProductPage()),
                );
              },
              child: _SampleCard(
                cardName: 'Manajemen Produk',
                icon: Icons.dashboard_customize_sharp,
                iconColor: Color(0xFF64AA54),
              ),
            ),
            SizedBox(height: 20.0),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PesananPenjualPage()),
                );
              },
              child: _SampleCard(
                cardName: 'Pesanan',
                icon: Icons.receipt,
                iconColor: Color(0xFF64AA54),
              ),
            ),
            SizedBox(height: 20.0),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RiwayatPesananPenjualPage()),
                );
              },
              child: _SampleCard(
                cardName: 'Riwayat Pesanan',
                icon: Icons.history_sharp,
                iconColor: Color(0xFF64AA54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String subtitle, int index) {
    return Card(
      color: Colors.white,
      child: InkWell(
        onTap: () => _onCardTapped(index),
        child: Center(
          child: ListTile(
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            subtitle: Text(
              subtitle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _SampleCard extends StatelessWidget {
  const _SampleCard({
    required this.cardName,
    required this.icon,
    required this.iconColor,
  });
  final String cardName;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: iconColor,
            ),
            SizedBox(height: 8.0),
            Text(
              cardName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
