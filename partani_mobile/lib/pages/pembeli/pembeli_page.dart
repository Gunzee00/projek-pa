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

  Future<void> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/api/produk/all'));
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
          // Produk berhasil ditambahkan ke keranjang
          print('Produk berhasil ditambahkan ke keranjang.');
          // TODO: Tambahkan feedback visual ke pengguna (opsional)
        } else {
          // Gagal menambahkan produk ke keranjang
          print('Gagal menambahkan produk ke keranjang.');
          // Menampilkan pesan error dari response server
          print('Error: ${response.body}');
          // TODO: Tambahkan feedback visual ke pengguna (opsional)
        }
      } catch (e) {
        // Error ketika melakukan request
        print('Error: $e');
        // TODO: Tambahkan feedback visual ke pengguna (opsional)
      }
    }
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
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            padding: EdgeInsets.fromLTRB(36, 20, 36, 36),
            margin: EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Partani',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (token.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.logout),
                        color: Colors.white,
                        onPressed: () {
                          logout(); // Panggil metode logout saat tombol logout ditekan
                        },
                      ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    menuItem(label: 'All', color: Colors.purple),
                    menuItem(label: 'Sayur', color: Colors.grey),
                    menuItem(label: 'Buah', color: Colors.grey),
                    menuItem(label: 'Rempah-Rempah', color: Colors.grey),
                  ],
                ),
              ],
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
                                padding: const EdgeInsets.only(
                                    left: 15,
                                    top: 8), // Added padding for location text
                                child: Row(
                                  // Added row to display location text and icon
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: const Color.fromARGB(
                                          255, 118, 119, 119),
                                      size: 20,
                                    ),
                                    SizedBox(
                                        width: 4), // Added SizedBox for spacing
                                    Text(
                                      products[index]['lokasi_produk'] ??
                                          '', // Display location of the product
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
                                print(
                                    'Jumlah: $jumlah'); // Add this line to check type
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                token = prefs.getString('token') ??
                                    ''; // Inisialisasi token
                                if (token.isEmpty) {
                                  // Jika token kosong, tampilkan popup untuk autentikasi
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Peringatan"),
                                        content: Text(
                                            "Kamu harus melakukan autentikasi dahulu."),
                                        actions: <Widget>[
                                          // Tombol untuk pergi ke halaman login
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
