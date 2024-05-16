import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:partani_mobile/pages/pembeli/keranjang_page.dart';
import 'package:partani_mobile/pages/pembeli/pesananpembeli_page.dart';
import 'package:partani_mobile/pages/profile%20user/profile_page.dart';

import 'package:partani_mobile/pages/pembeli/product_detail.dart';
import 'package:partani_mobile/user_login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PembeliPage extends StatefulWidget {
  @override
  _PembeliPageState createState() => _PembeliPageState();
}

class _PembeliPageState extends State<PembeliPage> {
  List<dynamic> products = [];
  TextEditingController searchController = TextEditingController();
  late String token = ''; // Inisialisasi token

  Future<void> fetchProducts({String query = ''}) async {
    String apiUrl = 'http://10.0.2.2:8000/api/produk/all';
    if (query.isNotEmpty) {
      apiUrl += '?q=$query';
    }

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body)['produk'];
      });
    } else {
      print("produk kosong");
    }
  }

  // Fungsi untuk menginisialisasi token dari SharedPreferences
  Future<void> initializeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? '';
    });
  }

  // Metode logout
  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      // Tambahkan pengecekan token sebelum logout
      String apiUrl = 'http://10.0.2.2:8000/api/user/logout';
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
        );

        if (response.statusCode == 200) {
          prefs.remove('token');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          print('Gagal logout: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  // Metode untuk menambahkan produk ke keranjang
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
      String apiUrl = 'http://10.0.2.2:8000/api/keranjang/tambah-keranjang';
      Map<String, dynamic> body = {
        'id_produk': idProduk.toString(), // Ensure id_produk is a string
        'jumlah': jumlah,
      };
      print(
          'id_produk: $idProduk'); // Tambahkan log untuk memeriksa tipe dan nilai id_produk
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
          _showSnackbar('Produk berhasil ditambahkan ke keranjang.');
        } else {
          _showSnackbar('Gagal menambahkan produk ke keranjang.');
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

  Widget menuItem({required String label, required Color color}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
    initializeToken(); // Panggil fungsi untuk menginisialisasi token
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Partani'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0), // Kurangi padding
            child: TextFormField(
              controller: searchController,
              onChanged: (value) {
                fetchProducts(query: value);
              },
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(
                  Icons.search,
                  size: 20, // Atur ukuran ikon di sini
                ),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: 20), // Sesuaikan padding konten
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 2.2),
              ),
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailPage(product: products[index]),
                        ),
                      );
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/image.jpeg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  products[index]['nama_produk'] ?? '',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: const Color.fromARGB(
                                          255, 118, 119, 119),
                                      size: 20,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      products[index]['lokasi_produk'] ?? '',
                                      style: TextStyle(
                                          color: Colors.black.withOpacity(0.6)),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  '\Rp.${products[index]['harga'] ?? '0'}',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                color: Colors.green,
                                size: 24,
                              ),
                              onPressed: () async {
                                int jumlah =
                                    products[index]['minimal_pemesanan'];
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String token = prefs.getString('token') ?? '';
                                if (token.isEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Peringatan"),
                                        content: Text(
                                            "Kamu harus melakukan autentikasi dahulu."),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text("Login"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoginPage()),
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
                                  tambahProdukKeKeranjang(
                                    products[index]['id_produk'],
                                    jumlah,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: Color(0xFF64AA54),
                ),
                iconSize: 30,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  color: Color(0xFF64AA54),
                ),
                iconSize: 30,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => KeranjangPage()),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.receipt,
                  color: Color(0xFF64AA54),
                ),
                iconSize: 30,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PesananPembeliPage()),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.account_circle,
                  color: Color(0xFF64AA54),
                ),
                iconSize: 30,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
