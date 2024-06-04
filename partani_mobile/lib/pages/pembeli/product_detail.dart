import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:partani_mobile/pages/pembeli/pesananpembeli_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:partani_mobile/user_login/login.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Tambahkan ini

class ProductDetailPage extends StatefulWidget {
  final dynamic product;

  ProductDetailPage({required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late TextEditingController searchController;
  late String token;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    token = '';
  }

  Future<void> buatPesananLangsung(int idProduk, int jumlah) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Peringatan"),
            content: Text("Kamu harus melakukan autentikasi dahulu."),
            actions: <Widget>[
              TextButton(
                child: Text("Login"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      String apiUrl = 'https://projek.cloud/api/pesanan/buat-pesanan-langsung';
      Map<String, dynamic> body = {
        'id_produk': idProduk,
        'jumlah': jumlah,
      };

      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: json.encode(body),
        );

        if (response.statusCode == 201) {
          _showSnackbar('Pesanan berhasil dibuat.');
        } else {
          print(response.statusCode);
          _showSnackbar('Gagal membuat pesanan.');
        }
      } catch (e) {
        _showSnackbar('Terjadi kesalahan: $e');
      }
    }
  }

  Future<void> tambahProdukKeKeranjang(int idProduk, int jumlah) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      // Jika token kosong, tampilkan popup untuk autentikasi
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Peringatan"),
            content: Text("Kamu harus melakukan autentikasi dahulu."),
            actions: <Widget>[
              // Tombol untuk pergi ke halaman login
              TextButton(
                child: Text("Login"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
              // Tombol untuk menutup popup
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Jika token tidak kosong, tambahkan produk ke keranjang
      String apiUrl = 'https://projek.cloud/api/keranjang/tambah-keranjang';
      Map<String, dynamic> body = {
        'id_produk': idProduk.toInt(), // Ensure id_produk is a string
        'jumlah': jumlah.toInt(), // Ensure jumlah is a string
      };
      print(body);
      print(
          'id_produk: $idProduk'); // Tambahkan log untuk memeriksa tipe dan nilai id_produk
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: json.encode(body),
        );
        print(json.encode(body));

        if (response.statusCode == 201) {
          _showSnackbar('Produk berhasil ditambahkan ke keranjang.');
        } else {
          print(response.statusCode);
          // _showSnackbar('Gagal menambahkan produk ke keranjang.');
        }
      } catch (e) {
        _showSnackbar('Terjadi kesalahan: $e');
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String phoneNumber = widget.product['nomor_penjual'];
    final Uri whatsApp = Uri.parse('https://wa.me/+62$phoneNumber');

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Produk"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: widget.product['gambar'] != null
                    ? FadeInImage.assetNetwork(
                        placeholder: 'assets/images/dummy.png',
                        image: widget.product['gambar'],
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/dummy.png',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/dummy.png',
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp.${widget.product['harga']}/${widget.product['satuan']}',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () async {
                            launchUrl(whatsApp);
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: Icon(
                              Icons.chat,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.product['nama_produk'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Lokasi: ${widget.product['lokasi_produk']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Minimal Pemesanan: ${widget.product['minimal_pemesanan']} ${widget.product['satuan']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Stok: ${widget.product['stok']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
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
                              widget.product['deskripsi'],
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
        color: Colors.white,
        child: Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () async {
                  print(widget.product[widget.product]);

                  int jumlah = int.tryParse(
                          widget.product['minimal_pemesanan'].toString()) ??
                      0;

                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String token = prefs.getString('token') ?? '';

                  if (token.isEmpty) {
                    // Show login dialog if token is empty
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Peringatan"),
                          content:
                              Text("Kamu harus melakukan autentikasi dahulu."),
                          actions: <Widget>[
                            TextButton(
                              child: Text("Login"),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                );
                              },
                            ),
                            TextButton(
                              child: Text("Close"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    int? idProduk =
                        int.tryParse(widget.product['id_produk'].toString());

                    if (idProduk != null && jumlah > 0) {
                      buatPesananLangsung(idProduk, jumlah);
                    } else {
                      String errorMessage = '';
                      if (idProduk == null) {
                        errorMessage += 'Error: Nilai id_produk tidak valid.\n';
                      }
                      if (jumlah <= 0) {
                        errorMessage +=
                            'Error: Nilai jumlah harus lebih besar dari 0.\n';
                      }
                      print(errorMessage);
                      _showSnackbar(
                          'Terjadi kesalahan saat melakukan pemesanan langsung.');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xFF64AA54),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Color(0xFF64AA54)),
                ),
                child: Text('Pesan Langsung'),
              ),
              ElevatedButton(
                onPressed: () async {
                  print(widget.product[widget.product]);

                  int jumlah = int.tryParse(
                          widget.product['minimal_pemesanan'].toString()) ??
                      0;

                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String token = prefs.getString('token') ?? '';

                  if (token.isEmpty) {
                    // Show login dialog if token is empty
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Peringatan"),
                          content:
                              Text("Kamu harus melakukan autentikasi dahulu."),
                          actions: <Widget>[
                            TextButton(
                              child: Text("Login"),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                );
                              },
                            ),
                            TextButton(
                              child: Text("Close"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    int? idProduk =
                        int.tryParse(widget.product['id_produk'].toString());

                    if (idProduk != null && jumlah > 0) {
                      tambahProdukKeKeranjang(idProduk, jumlah);
                    } else {
                      String errorMessage = '';
                      if (idProduk == null) {
                        errorMessage += 'Error: Nilai id_produk tidak valid.\n';
                      }
                      if (jumlah <= 0) {
                        errorMessage +=
                            'Error: Nilai jumlah harus lebih besar dari 0.\n';
                      }
                      print(errorMessage);
                      _showSnackbar(
                          'Terjadi kesalahan saat menambahkan produk ke keranjang.');
                    }
                  }
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
