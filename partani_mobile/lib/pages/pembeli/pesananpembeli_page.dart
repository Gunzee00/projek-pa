import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PesananPembeliPage extends StatefulWidget {
  @override
  _PesananPembeliPageState createState() => _PesananPembeliPageState();
}

class _PesananPembeliPageState extends State<PesananPembeliPage> {
  List<Map<String, dynamic>> pesananPembeli = [];
  late String token;

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
          pesananPembeli =
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
                        'Total Harga: Rp. ${pesanan['total_harga']} | Status: ${_getStatusText(pesanan['status'])}'),
                  ),
                );
              },
            ),
    );
  }

  String _getStatusText(String status) {
    if (status == '1') {
      return 'Pesanan Dibuat';
    } else if (status == '2') {
      return 'Pesanan Diproses';
    } else {
      return 'Status Tidak Dikenali';
    }
  }
}
