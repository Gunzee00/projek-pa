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
  String placeholderImageUrl = 'assets/images/image.jpeg';

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('https://partani.cloud/api/keranjang'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        keranjangData = json.decode(response.body).cast<Map<String, dynamic>>();
      });
    } else {
      print("keranjang kosong");
    }
  }

  Future<void> buatPesananDariKeranjang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse('https://partani.cloud/api/pesanan/buat-pesanan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      // Jika pembuatan pesanan berhasil, panggil kembali fungsi fetchData untuk memperbarui tampilan
      fetchData();
    } else {
      throw Exception('Failed to create pesanan');
    }
  }

  double calculateTotal() {
    double total = 0.0;
    for (var item in keranjangData) {
      if (item['total_harga'] != null) {
        // tambahkan pengecekan agar tidak bernilai null
        total += double.parse(item['total_harga'].toString());
      }
    }
    return total;
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
              child: Text(
                'Keranjang kosong',
                style: TextStyle(fontSize: 18),
              ),
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
                                placeholderImageUrl,
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
                              // IconButton(
                              //   onPressed: () async {
                              //     await hapusKeranjang(item['id'].toString());
                              //   },
                              //   icon: Icon(Icons.delete),
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await buatPesananDariKeranjang();
                  },
                  child: Text('Buat Pesanan'),
                ),
              ],
            ),
    );
  }
}
