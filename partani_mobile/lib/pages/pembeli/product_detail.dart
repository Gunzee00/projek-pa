import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailPage extends StatelessWidget {
  final dynamic product;
  TextEditingController searchController = TextEditingController();
  late String token;

  ProductDetailPage({required this.product});

  Future<void> tambahProdukKeKeranjang(int idProduk, int jumlah) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    String apiUrl = 'http://10.0.2.2:8000/api/keranjang/tambah-keranjang';
    Map<String, dynamic> body = {
      'id_produk': idProduk.toString(), // Ensure id_produk is a string
      'jumlah': jumlah.toString(), // Ensure jumlah is a string
    };
    print(
        'id_produk: $idProduk'); // Add log to check type and value of id_produk
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        // Produk berhasil ditambahkan ke keranjang
        print('Produk berhasil ditambahkan ke keranjang.');
        // TODO: Add visual feedback to the user (optional)
      } else {
        // Gagal menambahkan produk ke keranjang
        print('Gagal menambahkan produk ke keranjang.');
        // Menampilkan pesan error dari response server
        print('Error: ${response.body}');
        // TODO: Add visual feedback to the user (optional)
      }
    } catch (e) {
      // Error ketika melakukan request
      print('Error: $e');
      // TODO: Add visual feedback to the user (optional)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Produk"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/image.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    'Rp.${product['harga']}/${product['satuan']}',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    product['nama_produk'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Lokasi: ${product['lokasi_produk']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Minimal Pemesanan: ${product['minimal_pemesanan']} ${product['satuan']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Stok: ${product['stok']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Deskripsi Produk',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    product['deskripsi'],
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Implement buy now functionality here
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xFF64AA54),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Color(0xFF64AA54)),
                ),
                child: Text('Beli Langsung'),
              ),
              ElevatedButton(
                onPressed: () {
                  int jumlah = product['minimal_pemesanan'];
                  print('Jumlah: $jumlah'); // Add this line to check type
                  tambahProdukKeKeranjang(
                    product['id_produk'],
                    jumlah,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF64AA54),
                ),
                child: Text(
                  'Keranjang',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
