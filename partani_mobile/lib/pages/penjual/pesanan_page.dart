import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PesananPage extends StatefulWidget {
  @override
  _PesananPageState createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  List<Map<String, dynamic>> pesananMasuk = [];
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
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Image.asset(
                      'assets/images/image.jpeg', // Menggunakan gambar dari assets
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(pesanan['nama_produk'] ?? ''),
                    subtitle: Text(
                        'Total Harga: Rp. ${pesanan['total_harga']} | Status: $status'),
                  ),
                );
              },
            ),
    );
  }
}
