import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:partani_mobile/pages/pembeli/keranjang_page.dart';
import 'package:partani_mobile/pages/pembeli/pesananpembeli_page.dart';
import 'package:partani_mobile/user_login/login_admin.dart';
import 'package:partani_mobile/pages/pembeli/product_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PembeliPage extends StatefulWidget {
  @override
  _PembeliPageState createState() => _PembeliPageState();
}

class _PembeliPageState extends State<PembeliPage> {
  List<dynamic> products = [];
  TextEditingController searchController = TextEditingController();
  late String token;

  Future<void> fetchProducts() async {
    final response =
        await http.get(Uri.parse('https://partani.cloud/api/produk/all'));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body)['produk'];
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('role');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> tambahProdukKeKeranjang(int idProduk, int jumlah) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    String apiUrl = 'https://partani.cloud/api/keranjang/tambah-keranjang';
    Map<String, dynamic> body = {
      'id_produk': idProduk,
      'jumlah': jumlah, // Menggunakan jumlah yang diperoleh dari input pengguna
    };
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
                    IconButton(
                      icon: Icon(Icons.logout),
                      color: Colors.white,
                      onPressed: () {
                        logout();
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
                              onPressed: () {
                                int jumlah = int.parse(
                                    products[index]['minimal_pemesanan']);
                                tambahProdukKeKeranjang(
                                  products[index]['id_produk'],
                                  jumlah,
                                );
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
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
