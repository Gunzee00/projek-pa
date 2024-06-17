import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProductPage extends StatefulWidget {
  final dynamic product;

  EditProductPage({required this.product});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _satuanController = TextEditingController();
  TextEditingController _minOrderController = TextEditingController();
  TextEditingController _stockController = TextEditingController();
  TextEditingController _lokasiprodukController = TextEditingController();

  File? _image; // File gambar yang di-upload

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _nameController.text = widget.product['nama_produk'];
    _priceController.text = widget.product['harga'].toString();
    _descriptionController.text = widget.product['deskripsi'];
    _satuanController.text = widget.product['satuan'];
    _minOrderController.text = widget.product['minimal_pemesanan'].toString();
    _stockController.text = widget.product['stok'].toString();
    _lokasiprodukController.text = widget.product['lokasi_produk'];
  }

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProduct(String token) async {
    // Ambil data dari form
    String name = _nameController.text.trim();
    String price = _priceController.text.trim();
    String description = _descriptionController.text.trim();
    String satuan = _satuanController.text.trim();
    String minOrder = _minOrderController.text.trim();
    String stock = _stockController.text.trim();
    String lokasiProduk = _lokasiprodukController.text.trim();

    // Validasi form
    if (name.isEmpty ||
        price.isEmpty ||
        description.isEmpty ||
        satuan.isEmpty ||
        minOrder.isEmpty ||
        stock.isEmpty ||
        lokasiProduk.isEmpty) {
      _showErrorDialog("Semua kolom harus diisi");
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('token') ?? '';

      var url = Uri.parse(
          'https://projek.cloud/api/update-produk/${widget.product['id_produk']}');

      var response = await http.put(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $authToken', // Mengirim token di header
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'nama_produk': name,
          'harga': price,
          'deskripsi': description,
          'satuan': satuan,
          'minimal_pemesanan': minOrder,
          'stok': stock,
          'lokasi_produk': lokasiProduk,
        }),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          // Debugging: Cetak data terbaru yang diterima dari API
          print("Data terbaru dari API: ${responseData['data']}");

          // Update local product data to reflect the new changes
          setState(() {
            widget.product['nama_produk'] = responseData['data']['nama_produk'];
            widget.product['harga'] = responseData['data']['harga'];
            widget.product['deskripsi'] = responseData['data']['deskripsi'];
            widget.product['satuan'] = responseData['data']['satuan'];
            widget.product['minimal_pemesanan'] =
                responseData['data']['minimal_pemesanan'];
            widget.product['stok'] = responseData['data']['stok'];
            widget.product['lokasi_produk'] =
                responseData['data']['lokasi_produk'];
          });

          // Kembali ke layar sebelumnya dengan indikator sukses
          Navigator.pop(context, true);
        } else {
          _showErrorDialog(
              "Data produk yang diperbarui tidak ditemukan dalam respons.");
        }
      } else {
        // Gagal mengubah produk, tampilkan pesan kesalahan
        _showErrorDialog(
            "Gagal mengupdate produk. Silakan coba lagi. \nStatus: ${response.statusCode}\nResponse: ${response.body}");
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
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
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
        title: Text('Edit Produk'),
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
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Color(0xFF64AA54)),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 12.0),
            _image == null
                ? CachedNetworkImage(
                    imageUrl: widget.product['gambar'],
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    height: 150,
                  )
                : Image.file(_image!, height: 150),
            SizedBox(height: 12.0),
            ElevatedButton.icon(
              icon: Icon(Icons.photo_camera),
              label: Text('Pilih Gambar'),
              onPressed: _getImage,
            ),
            SizedBox(height: 12.0),
            ElevatedButton(
              child: Text('Update Produk'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString('token');
                if (token != null) {
                  await _updateProduct(token);
                } else {
                  _showErrorDialog(
                      "Token tidak ditemukan. Silakan login kembali.");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
