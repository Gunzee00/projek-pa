import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:partani_mobile/components/component%20penjual/bottombar_penjual.dart';
import 'package:partani_mobile/pages/penjual/add_product.dart';
import 'package:partani_mobile/pages/penjual/edit_product.dart';
import 'package:partani_mobile/pages/penjual/pesanan_page.dart';
import 'package:partani_mobile/pages/profile%20user/profile_page.dart';
import 'package:partani_mobile/pages/penjual/penjual_page.dart'; // Import PenjualPage
import 'package:partani_mobile/user_login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageProductPage extends StatefulWidget {
  @override
  _ManageProductPageState createState() => _ManageProductPageState();
}

class _ManageProductPageState extends State<ManageProductPage> {
  List<dynamic> _produks = [];
  int _selectedIndex = 1; // Set index for bottom bar

  @override
  void initState() {
    super.initState();
    _fetchProduks();
  }

  Future<void> _fetchProduks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/produk'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _produks = json.decode(response.body)['produk'];
        });
      } else {
        throw Exception('Failed to load products');
      }
    } else {
      // Token not available, perhaps need authentication process
    }
  }

  Future<void> _deleteProduct(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/api/delete-produk/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        // Product deleted successfully, perform any necessary actions (e.g., update UI)
        // For example, you can fetch updated list of products
        _fetchProduks();
      } else {
        // Handle error, if any
        print('Failed to delete product: ${response.body}');
      }
    } else {
      // Token not available, perhaps need authentication process
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Produk'),
      ),
      body: _produks.isEmpty
          ? Center(
              child: Text('No products available'),
            )
          : ListView.builder(
              itemCount: _produks.length,
              itemBuilder: (context, index) {
                final produk = _produks[index];
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Card(
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Text(produk['nama_produk']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Harga: Rp ${produk['harga']} / ${produk['satuan']}'),
                          Text('Stok: ${produk['stok']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _navigateToEditProductPage(
                                  context, produk['id_produk']);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteProduct(produk['id_produk']);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottombarPenjual(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddProductPage(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddProductPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductPage()),
    );
  }

  void _navigateToEditProductPage(BuildContext context, int productId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProductPage(productId)),
    );
  }
}
