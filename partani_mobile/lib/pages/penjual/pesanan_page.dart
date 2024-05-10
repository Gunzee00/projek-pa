import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:partani_mobile/pages/penjual/manage_product.dart'; // Import ManageProductPage
import 'package:partani_mobile/pages/profile%20user/profile_page.dart';
import 'package:partani_mobile/pages/penjual/penjual_page.dart'; // Import PenjualPage

class PesananPage extends StatefulWidget {
  @override
  _PesananPageState createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  List<Map<String, dynamic>> pesananMasuk = [];
  late String token;
  int _selectedIndex = 2; // Set index for bottom bar

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    String apiUrl =
        'http://10.0.2.2:8000/api/pesanan/penjual'; // Sesuaikan dengan URL yang benar
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          pesananMasuk =
              json.decode(response.body).cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      // Tambahkan penanganan kesalahan jika diperlukan
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesanan Masuk'),
      ),
      body: pesananMasuk.isEmpty
          ? Center(
              child: Text(
                'Tidak ada pesanan masuk',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: pesananMasuk.length,
              itemBuilder: (BuildContext context, int index) {
                final pesanan = pesananMasuk[index];
                // Tentukan status pesanan
                String status;
                if (pesanan['status'] == 1) {
                  status = 'Pesanan Dibuat';
                } else if (pesanan['status'] == 2) {
                  status = 'Pesanan Diproses';
                } else {
                  status = 'Pesanan Dibuat';
                }

                // Tambahkan pembatas jika pemesan berbeda dengan pesanan sebelumnya
                Widget separator = SizedBox(height: 10);
                if (index > 0 &&
                    pesanan['pembeli'] != pesananMasuk[index - 1]['pembeli']) {
                  separator = Column(
                    children: [
                      SizedBox(height: 20),
                      Divider(
                        color: Colors.grey,
                        height: 10,
                        thickness: 2,
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    separator,
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pembeli: ${pesanan['pembeli']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Status: $status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          ListTile(
                            leading: Image.asset(
                              'assets/images/image.jpeg', // Menggunakan gambar dari assets
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(pesanan['nama_produk'] ?? ''),
                            subtitle: Text(
                                'Total Harga: Rp. ${pesanan['total_harga']}'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
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
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PenjualPage()),
        );
      } else if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManageProductPage()),
        );
      } else if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      }
    });
  }
}
