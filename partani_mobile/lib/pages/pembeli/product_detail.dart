import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> pesanProduk(int idProduk, int jumlah) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    String apiUrl = 'http://10.0.2.2:8000/api/pesanan/buat-pesanan-langsung';
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
        print('Berhasil melakukan pemesanan');
        // TODO: Add visual feedback to the user (optional)
      } else {
        // Gagal menambahkan produk ke keranjang
        print('Gagal melakukan pemesanan');
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
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 2), // Atur jarak atas-bawah dan kiri-kanan
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), // Radius bingkai
                  image: DecorationImage(
                    image: AssetImage('assets/images/image.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20), // Spasi antara gambar dan deskripsi produk
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Container untuk harga produk
                        Container(
                          child: Text(
                            'Rp.${product['harga']}/${product['satuan']}',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Widget untuk logo WhatsApp
                        GestureDetector(
                          onTap: () async {
                            // Ganti dengan logika untuk mengambil nomor telepon penjual dari data produk yang baru saja dibuat
                            String phoneNumber = product[
                                'nomor_penjual']; // Ganti dengan nomor telepon penjual yang sesuai

                            // Periksa apakah nomor telepon penjual tidak null sebelum mengakses WhatsApp
                            if (phoneNumber != null) {
                              // URL untuk membuka aplikasi WhatsApp dengan nomor telepon yang diberikan
                              String whatsappUrl = 'https://wa.me/$phoneNumber';

                              // Membuka aplikasi WhatsApp
                              if (await canLaunch(whatsappUrl)) {
                                await launch(whatsappUrl);
                              } else {
                                throw 'Could not launch $whatsappUrl';
                              }
                            } else {
                              // Tindakan yang diambil jika nomor telepon penjual null
                              print('Nomor telepon penjual tidak tersedia');
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors
                                  .green, // Warna latar belakang ikon WhatsApp
                            ),
                            child: Icon(
                              Icons.chat, // Ikon WhatsApp
                              color: Colors.white, // Warna ikon WhatsApp
                              size: 30, // Ukuran ikon WhatsApp
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      // Container untuk informasi dasar produk
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['nama_produk'],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Lokasi: ${product['lokasi_produk']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Minimal Pemesanan: ${product['minimal_pemesanan']} ${product['satuan']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Stok: ${product['stok']}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(10), // Menambahkan radius
                        color: Colors.grey[200], // Memberi warna latar belakang
                      ),
                      padding: EdgeInsets.all(
                          10), // Memberi padding agar konten tidak terlalu dekat dengan tepi
                      child: SizedBox(
                        width: double.infinity, // Menggunakan lebar maksimal
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Color.fromARGB(
                                  255, 73, 73, 73), // Warna ikon person
                            ),
                            SizedBox(
                                width:
                                    10), // Memberi jarak antara ikon dan teks
                            Text(
                              '${product['nama_penjual']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
                    // Container untuk deskripsi produk
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Radius bingkai
                      ),
                      elevation: 3, // Atur elevasi kartu sesuai keinginan
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deskripsi Produk',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              product['deskripsi'],
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(
            255, 255, 255, 255), // Atur warna background menjadi putih
        child: Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  int jumlah = product['minimal_pemesanan'];
                  print('Jumlah: $jumlah');
                  pesanProduk(
                    product['id_produk'],
                    jumlah,
                  );
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
                  print('Jumlah: $jumlah');
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
