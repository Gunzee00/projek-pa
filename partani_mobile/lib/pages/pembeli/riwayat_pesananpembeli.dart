import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  bool isPesananDibatalkan =
      false; // State untuk melacak apakah pesanan telah dibatalkan

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    String apiUrl =
        'http://10.0.2.2:8000/api/pesanan/pembeli'; // Sesuaikan dengan URL yang benar
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

  Future<void> batalkanPesanan(int idPesanan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    String apiUrl =
        'http://10.0.2.2:8000/api/pesanan/batalkan/$idPesanan'; // Sesuaikan dengan URL yang benar
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        // Pesanan berhasil dibatalkan, perbarui state
        setState(() {
          isPesananDibatalkan = true;
        });
        // Pesanan berhasil dibatalkan, lakukan sesuatu jika diperlukan
        // Misalnya, muat ulang data pesanan atau tampilkan pesan sukses
        fetchData(); // Memuat ulang data pesanan setelah pembatalan
      } else {
        throw Exception('Gagal membatalkan pesanan');
      }
    } catch (e) {
      print('Error: $e');
      // Tambahkan penanganan kesalahan jika diperlukan
    }
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
              Text('Penjual: ${pesanan['penjual']}'),
              Text('Nama Produk: ${pesanan['nama_produk']}'),
              Text('Jumlah: ${pesanan['jumlah']} ${pesanan['satuan']}'),
              Text('Total Harga: Rp. ${pesanan['total_harga']}'),
              Text('Status: ${_getStatusText(pesanan['status'])}'),
              Text('Alamat Pengirim: ${(pesanan['alamat_penjual'])}'),
              // Text('Nomor Penjual: ${pesanan['nomor_telepon_penjual']}'),
              // Add other necessary information as needed
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
                String phoneNumber = pesanan['nomor_telepon_penjual'];
                final Uri whatsApp = Uri.parse('https://wa.me/$phoneNumber');

                launchUrl(whatsApp);
                // Construct the WhatsApp message with the seller's phone number
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
        title: Text('Pesanan Saya'),
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
                final penjual = pesanan[
                    'penjual']; // Ubah sesuai dengan key nama penjual dalam respons API

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
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        onTap: () {
                          _showPesananDetail(
                              pesanan); // Tampilkan detail pesanan saat pesanan ditekan
                        },
                        leading: Image.asset(
                          'assets/images/image.jpeg',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(pesanan['nama_produk'] ?? ''),
                        subtitle: Text(
                          'Total Harga: Rp. ${pesanan['total_harga']}\n'
                          'Jumlah Pesanan:  ${pesanan['jumlah']} ${pesanan['satuan']}\n'
                          'Status: ${_getStatusText(pesanan['status'])}',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
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
