import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:partani_mobile/components/component%20pembeli/bottombar_pembeli.dart';
import 'package:partani_mobile/user_login/login.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class RiwayatPesananPembeliPage extends StatefulWidget {
  @override
  _RiwayatPesananPembeliPageState createState() =>
      _RiwayatPesananPembeliPageState();
}

class _RiwayatPesananPembeliPageState extends State<RiwayatPesananPembeliPage> {
  List<Map<String, dynamic>> pesananPembeli = [];
  late String token;

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    String apiUrl =
        'https://projek.cloud/api/pesanan/pembeli'; // Sesuaikan dengan URL yang benar
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          pesananPembeli = json
              .decode(response.body)
              .cast<Map<String, dynamic>>()
              .where((pesanan) => pesanan['status'].toString() != '1')
              .toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      // Tambahkan penanganan kesalahan jika diperlukan
    }
  }

  Future<void> initializeTokenAndRole(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? '';
      if (prefs.getString('role') != 'pembeli') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  void _showPesananDetail(Map<String, dynamic> pesanan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background color to white
          title: Text('Detail Pesanan'),
          content: SingleChildScrollView(
            // Added to prevent bottom overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: Text('Nama Penjual')),
                    Expanded(flex: 2, child: Text(': ${pesanan['penjual']}')),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: Text('Alamat Pengirim')),
                    Expanded(
                        flex: 2, child: Text(': ${pesanan['alamat_penjual']}')),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: Text('Nomor Telepon')),
                    Expanded(
                        flex: 2,
                        child: Text(': ${pesanan['nomor_telepon_penjual']}')),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: Text('Status')),
                    Expanded(
                      flex: 1,
                      child: Text(
                        ': ${_getStatusText(pesanan['status'])}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(
                        5.0), // Optional: Adds rounded corners
                  ),
                  padding:
                      EdgeInsets.all(10.0), // Adds padding inside the container
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Deskripsi Pesanan'),
                      Divider(),
                      Text('${pesanan['nama_produk']}'),
                      Text(
                          'Harga per ${pesanan['satuan']} = Rp. ${pesanan['harga']}'),
                      Text(
                          '${pesanan['harga']} x ${pesanan['jumlah']} = Rp. ${pesanan['total_harga']}'),
                      Divider(),
                      Text('Total =  Rp. ${pesanan['total_harga']}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  String phoneNumber = pesanan['nomor_telepon_penjual'];
                  final Uri whatsApp = Uri.parse('https://wa.me/$phoneNumber');
                  launchUrl(whatsApp);
                },
                icon: Icon(
                  Icons.chat,
                  color: Colors.white,
                ),
                label: Text('Hubungi Penjual Sekarang'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF64AA54), // Text color
                ),
              ),
            ),
          ],
        );
      },
    );
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
        title: Text('Riwayat Pesanan'),
      ),
      body: pesananPembeli.isEmpty
          ? Center(
              child: Text(
                'Tidak ada pesanan',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: pesananPembeli.length,
              itemBuilder: (BuildContext context, int index) {
                final pesanan = pesananPembeli[index];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Warna latar belakang pemisah
                        borderRadius: BorderRadius.circular(8), // Radius field
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [],
                      ),
                    ),
                    Card(
                      color: Color.fromARGB(255, 255, 255, 255),
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () {
                              _showPesananDetail(pesanan);
                            },
                            leading: pesanan['gambar'] != null
                                ? FadeInImage.assetNetwork(
                                    placeholder: 'assets/images/dummy.png',
                                    image: pesanan['gambar'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/dummy.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/images/dummy.png',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                            title: Text(pesanan['nama_produk'] ?? ''),
                            subtitle: Text(
                              'Total Harga: Rp. ${pesanan['total_harga']}\n'
                              'Jumlah Pesanan: ${pesanan['jumlah']} ${pesanan['satuan']}\n'
                              'Status: ${_getStatusText(pesanan['status'])}',
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
      bottomNavigationBar: BottombarPembeli(), // Tambahkan navbar di sini
    );
  }

  String _getStatusText(String status) {
    if (status == '1') {
      return 'Pesanan Dibuat';
    } else if (status == '2') {
      return 'Pesanan Dibatalkan';
    } else if (status == '3') {
      return 'Pesanan Diterima';
    } else if (status == '4') {
      return 'Pesanan Ditolak Oleh Penjual';
    } else {
      return 'Status Tidak Dikenali';
    }
  }
}
