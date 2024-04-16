import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class KeranjangPage extends StatefulWidget {
  @override
  _KeranjangPageState createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  List<Map<String, dynamic>> keranjangData = [];
  late String token;

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/keranjang'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        keranjangData = json.decode(response.body).cast<Map<String, dynamic>>();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  double calculateTotal() {
    double total = 0.0;
    for (var item in keranjangData) {
      total += double.parse(item['total_harga']);
    }
    return total;
  }

  Future<void> hapusKeranjang(String idKeranjang) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/api/keranjang/hapus-keranjang'),
        headers: {'Authorization': 'Bearer $token'},
        body: {'id_keranjang': idKeranjang},
      );

      if (response.statusCode == 200) {
        // Jika penghapusan berhasil, panggil kembali fetchData untuk memperbarui data
        fetchData();
      } else {
        // Tangani kesalahan dari server
        throw Exception('Failed to delete data: ${response.body}');
      }
    } catch (error) {
      // Tangani kesalahan dari klien
      print('Error: $error');
      throw Exception('Failed to delete data: $error');
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
        title: Text('Keranjang'),
      ),
      body: keranjangData.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: keranjangData.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = keranjangData[index];
                      return Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/image.jpeg',
                                width: 100,
                                height: 100,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['nama_produk'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${item['jumlah']} ${item['satuan']}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Rp. ${item['total_harga']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  // Check if 'id_keranjang' exists and has a value before calling hapusKeranjang
                                  if (item['id_keranjang'] != null &&
                                      item['id_keranjang'].isNotEmpty) {
                                    hapusKeranjang(item['id_keranjang']);
                                  } else {
                                    // Handle the case where 'id_keranjang' is missing or empty
                                    print(
                                        'Error: id_keranjang is missing or empty.');
                                    // You can also display a user-friendly error message here
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp. ${calculateTotal()}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
