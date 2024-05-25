import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:partani_mobile/components/component%20penjual/bottombar_penjual.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PesananPenjualPage extends StatefulWidget {
  @override
  _PesananPenjualPageState createState() => _PesananPenjualPageState();
}

class _PesananPenjualPageState extends State<PesananPenjualPage> {
  List<Map<String, dynamic>> pesananPenjual = [];
  late String token;

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
          pesananPenjual = json
              .decode(response.body)
              .cast<Map<String, dynamic>>()
              .where((pesanan) => pesanan['status'].toString() == '1')
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
        'http://10.0.2.2:8000/api/pesanan/konfirmasi/$idPesanan'; // Sesuaikan dengan URL yang benar
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
        'http://10.0.2.2:8000/api/pesanan/tolak/$idPesanan'; // Sesuaikan dengan URL yang benar
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
        title: Text('Pesanan Masuk'),
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
                    leading: Image.asset(
                      'assets/images/image.jpeg',
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
          title: Text('Detail Pesanan'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pembeli: ${pesanan['pembeli']}'),
              Text('Nama Produk: ${pesanan['nama_produk']}'),
              Text(
                  'Jumlah: ${pesanan['jumlah'].toString()} ${pesanan['satuan']}'),
              Text('Total Harga: Rp. ${pesanan['total_harga'].toString()}'),
              Text('Status: ${_getStatusText(pesanan['status'].toString())}'),
              Text('Alamat Pembeli: ${(pesanan['alamat_pembeli'])}'),
              // Tambahkan informasi lainnya sesuai kebutuhan
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
            IconButton(
              onPressed: () {
                // Construct the WhatsApp message with the seller's phone number
                String phoneNumber = pesanan['nomor_telepon_pembeli'];
                final Uri whatsApp = Uri.parse('https://wa.me/$phoneNumber');

                launchUrl(whatsApp);
              },
              icon: Icon(
                Icons.chat,
                color: Colors.green,
              ), // Add your desired chat icon
            ),
          ],
        );
      },
    );
  } // Function to launch WhatsApp with a predefined message

  String _getStatusText(String status) {
    switch (status) {
      case '1':
        return 'Pesanan Dibuat';
      case '2':
        return 'Pesanan Dibatalkan';
      case '3':
        return 'Pesanan Dikonfirmasi Penjual';
      case '4':
        return 'Pesanan Ditolak Oleh Penjual';
      default:
        return 'Status Tidak Dikenali';
    }
  }
}
