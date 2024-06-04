import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:partani_mobile/pages/penjual/manage_product.dart';
import 'package:partani_mobile/user_login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _satuanController = TextEditingController();
  TextEditingController _minOrderController = TextEditingController();
  TextEditingController _stockController = TextEditingController();
  TextEditingController _lokasiprodukController = TextEditingController();

  File? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initializeTokenAndRole();
  }

  Future<void> initializeTokenAndRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? role = prefs.getString('role');

    if (role != 'penjual') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Future<void> _addProduct(String token) async {
    String name = _nameController.text.trim();
    String price = _priceController.text.trim();
    String description = _descriptionController.text.trim();
    String satuan = _satuanController.text.trim();
    String minOrder = _minOrderController.text.trim();
    String stock = _stockController.text.trim();
    String lokasiProduk = _lokasiprodukController.text.trim();

    if (name.isEmpty ||
        price.isEmpty ||
        description.isEmpty ||
        satuan.isEmpty ||
        minOrder.isEmpty ||
        stock.isEmpty ||
        lokasiProduk.isEmpty ||
        _image == null) {
      _showErrorDialog("Semua kolom harus diisi dan gambar harus dipilih");
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://projek.cloud/api/create-produk'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['nama_produk'] = name;
      request.fields['harga'] = price;
      request.fields['deskripsi'] = description;
      request.fields['satuan'] = satuan;
      request.fields['minimal_pemesanan'] = minOrder;
      request.fields['stok'] = stock;
      request.fields['lokasi_produk'] = lokasiProduk;

      request.files.add(
        await http.MultipartFile.fromPath('gambar', _image!.path),
      );

      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        print('Error: ${response.statusCode}');
        print('Response: $responseString');
        _showErrorDialog(
            "Gagal menambahkan produk. Silakan coba lagi. \nStatus: ${response.statusCode}\nResponse: $responseString");
      }
    } catch (error) {
      print('Error: $error');
      _showErrorDialog("Terjadi kesalahan: $error");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sukses"),
          content: Text("Produk berhasil ditambahkan"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigasi ke halaman ManageProductPage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ManageProductPage()),
                );
              },
              child: Text("OK"),
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
        title: Text('Tambahkan Produk'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Produk',
                prefixIcon: Icon(Icons.shopping_bag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Color(0xFF64AA54)),
                ),
              ),
            ),
            SizedBox(height: 12.0),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Harga',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Color(0xFF64AA54)),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12.0),
            TextFormField(
              controller: _lokasiprodukController,
              decoration: InputDecoration(
                labelText: 'Lokasi Produk',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Color(0xFF64AA54)),
                ),
              ),
            ),
            SizedBox(height: 12.0),
            TextFormField(
              controller: _satuanController,
              decoration: InputDecoration(
                labelText: 'Satuan',
                prefixIcon: Icon(Icons.dashboard),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Color(0xFF64AA54)),
                ),
              ),
            ),
            SizedBox(height: 12.0),
            TextFormField(
              controller: _minOrderController,
              decoration: InputDecoration(
                labelText: 'Minimal Pemesanan',
                prefixIcon: Icon(Icons.shopping_cart),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Color(0xFF64AA54)),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12.0),
            TextFormField(
              controller: _stockController,
              decoration: InputDecoration(
                labelText: 'Stok',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Color(0xFF64AA54)),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Color(0xFF64AA54)),
                ),
              ),
              maxLines: 5, // Mengatur jumlah baris maksimum
            ),
            SizedBox(height: 12.0),
            GestureDetector(
              onTap: _getImage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                height: 150,
                child: _image == null
                    ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString('token');
                if (token != null) {
                  _addProduct(token);
                } else {
                  _showErrorDialog(
                      "Token tidak ditemukan, silahkan login ulang.");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF64AA54),
              ),
              child: Text('Tambahkan Produk',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
