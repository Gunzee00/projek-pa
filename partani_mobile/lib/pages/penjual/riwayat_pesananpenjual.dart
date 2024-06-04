import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/component penjual/bottombar_penjual.dart';

class RiwayatPesananPenjualPage extends StatefulWidget {
  @override
  _RiwayatPesananPenjualPageState createState() =>
      _RiwayatPesananPenjualPageState();
}

class _RiwayatPesananPenjualPageState extends State<RiwayatPesananPenjualPage> {
  List<Map<String, dynamic>> pesananPenjual = [];
  late String token;

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    String apiUrl =
        'https://projek.cloud/api/pesanan/penjual'; // Sesuaikan dengan URL yang benar
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          pesananPenjual = json
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

  void _konfirmasiPesanan(String idPesanan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    String apiUrl =
        'https://projek.cloud/api/pesanan/konfirmasi/$idPesanan'; // Sesuaikan dengan URL yang benar
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        fetchData(); // Ambil ulang data setelah mengkonfirmasi pesanan
      } else {
        throw Exception('Failed to confirm order');
      }
    } catch (e) {
      print('Error: $e');
      // Tambahkan penanganan kesalahan jika diperlukan
    }
  }

  void _tolakPesanan(String idPesanan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    String apiUrl =
        'https://projek.cloud/api/pesanan/tolak/$idPesanan'; // Sesuaikan dengan URL yang benar
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        fetchData(); // Ambil ulang data setelah menolak pesanan
      } else {
        throw Exception('Failed to reject order');
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
        title: Text('Riwayat Pesanan'),
      ),
      bottomNavigationBar: BottombarPenjual(),
      body: pesananPenjual.isEmpty
          ? Center(
              child: Text(
                'Tidak ada pesanan',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: pesananPenjual.length,
              itemBuilder: (BuildContext context, int index) {
                final pesanan = pesananPenjual[index];
                final String status = pesanan['status'].toString();

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
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
                            imageErrorBuilder: (context, error, stackTrace) {
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Jumlah Pesanan:  ${pesanan['jumlah']} ${pesanan['satuan']} '),
                        Text(
                            'Total Harga: Rp. ${pesanan['total_harga'].toString()}'),
                        Text('Status: ${_getStatusText(status)}'),
                        if (status ==
                            '1') // Menampilkan tombol hanya jika status adalah 'Pesanan Dibuat'
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  _konfirmasiPesanan(
                                      pesanan['id_pesanan'].toString());
                                },
                                child: Text('Konfirmasi'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _tolakPesanan(
                                      pesanan['id_pesanan'].toString());
                                },
                                child: Text('Tolak'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
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
                    Expanded(flex: 2, child: Text('Nama Pembeli')),
                    Expanded(flex: 2, child: Text(': ${pesanan['pembeli']}')),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: Text('Alamat Penjual')),
                    Expanded(
                        flex: 2, child: Text(': ${pesanan['alamat_pembeli']}')),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: Text('Nomor Telepon')),
                    Expanded(
                        flex: 2,
                        child: Text(': ${pesanan['nomor_telepon_pembeli']}')),
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
                // Text(
                //   'Status: ${_getStatusText(pesanan['status'])}',
                //   style: TextStyle(fontWeight: FontWeight.bold),
                // ),
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
                  String phoneNumber = pesanan['nomor_telepon_pembeli'];
                  final Uri whatsApp = Uri.parse('https://wa.me/+62$phoneNumber');
                  launchUrl(whatsApp);
                },
                icon: Icon(
                  Icons.chat,
                  color: Colors.white,
                ),
                label: Text('Hubungi Pembeli Sekarang'),
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

  String _getStatusText(String status) {
    switch (status) {
      case '1':
        return 'Pesanan Dibuat';
      case '2':
        return 'Pesanan Dibatalkan';
      case '3':
        return 'Pesanan Diterima';
      case '4':
        return 'Pesanan Ditolak Oleh Penjual';
      default:
        return 'Status Tidak Dikenali';
    }
  }
}
