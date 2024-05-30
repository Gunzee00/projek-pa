import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:partani_mobile/pages/pembeli/product_detail.dart';
import 'package:partani_mobile/user_login/login.dart'; // Import LoginPage

class KeranjangPage extends StatefulWidget {
  @override
  _KeranjangPageState createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  List<Map<String, dynamic>> keranjangData = [];
  String? token;
  String placeholderImageUrl = 'assets/images/image.jpeg';
  bool isAuthenticated = true; // Add an authentication flag

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    if (token!.isEmpty) {
      // Set authentication flag if token is empty
      setState(() {
        isAuthenticated = false;
      });

      // Show dialog if token is empty
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Peringatan"),
              content: Text("Kamu harus melakukan autentikasi dahulu."),
              actions: <Widget>[
                // Button to go to the login page
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
                // Button to close the popup
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
      });
      return; // Stop further execution if token is empty
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/keranjang'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        keranjangData = json.decode(response.body).cast<Map<String, dynamic>>();
      });
    } else {
      print("Keranjang kosong");
    }
  }

  Future<void> hapusBarangDariKeranjang(int idProduk) async {
    // Tampilkan dialog konfirmasi
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF3F3F3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
                color: Colors.black), // Atur warna dan ketebalan stroke
          ), // Set latar belakang dialog menjadi putih
          title: Text("   "),
          content: Text(
            "Apakah kamu yakin ingin menghapus barang dari keranjang?",
            textAlign: TextAlign.center, // Menjadikan teks berada di tengah
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Tidak",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Set nilai konfirmasi menjadi false
              },
            ),
            TextButton(
              child: Text(
                "Ya",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Set nilai konfirmasi menjadi true
              },
            ),
          ],
        );
      },
    );

    // Hapus barang jika konfirmasi diterima
    if (confirmDelete == true) {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/api/keranjang/hapus-keranjang'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'id_produk': idProduk}),
      );

      if (response.statusCode == 200) {
        fetchData();
      } else {
        print('Gagal menghapus');
      }
    }
  }

  Future<void> buatPesananDariKeranjang(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/pesanan/buat-pesanan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => KeranjangPage()),
      );
      showSuccessDialog(context);
    } else {
      throw Exception('Failed to create pesanan');
    }
  }

  double calculateTotal() {
    double total = 0.0;
    for (var item in keranjangData) {
      if (item['total_harga'] != null) {
        total += double.parse(item['total_harga'].toString());
      }
    }
    return total;
  }

  Future<void> showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pesanan Berhasil'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Pesanan Anda berhasil dibuat.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                fetchData();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang'),
      ),
      body: isAuthenticated
          ? keranjangData.isEmpty
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
                          final bool isFirstItem = index == 0 ||
                              item['penjual'] !=
                                  keranjangData[index - 1]['penjual'];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // if (isFirstItem) SizedBox(height: 16),
                              // if (isFirstItem)
                              // Container(
                              //   margin: EdgeInsets.symmetric(horizontal: 8),
                              //   decoration: BoxDecoration(
                              //     color: Colors.grey[300],
                              //     borderRadius: BorderRadius.circular(8),
                              //   ),
                              //   padding: EdgeInsets.symmetric(
                              //       horizontal: 16, vertical: 8),
                              //   child: Text(
                              //     'Penjual: ${item['penjual']}',
                              //     style: TextStyle(
                              //         fontSize: 16,
                              //         fontWeight: FontWeight.bold),
                              //   ),
                              // ),
                              GestureDetector(
                                onTap: () {
                                  if (item['id_produk'] != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailPage(
                                          product: {
                                            'id_produk': item['id_produk'],
                                          },
                                        ),
                                      ),
                                    );
                                  } else {
                                    print('ID produk tidak tersedia');
                                  }
                                },
                                child: Card(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  margin: const EdgeInsets.all(
                                      10.0), // Menambahkan margin di sekitar Card

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${item['nama_produk']} ${item['jumlah']} ${item['satuan']}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Rp.${item['total_harga']}',
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
                                              hapusBarangDariKeranjang(
                                                  item['id_produk']);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Pembayaran',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Rp. ${calculateTotal().toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 20), // Tambahkan jarak antara widget
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await buatPesananDariKeranjang(context);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                              ),
                              child: Text('Buat Pesanan'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
          : Container(), // Do not display anything if not authenticated
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: KeranjangPage(),
  ));
}
