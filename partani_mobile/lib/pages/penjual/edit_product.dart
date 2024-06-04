import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:partani_mobile/user_login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProductPage extends StatefulWidget {
  final int productId;

  EditProductPage(this.productId);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaProdukController;
  late TextEditingController _hargaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _satuanController;
  late TextEditingController _lokasiProdukController;
  late TextEditingController _minimalPemesananController;
  late TextEditingController _stokController;
  File? _image;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _namaProdukController = TextEditingController();
    _hargaController = TextEditingController();
    _deskripsiController = TextEditingController();
    _satuanController = TextEditingController();
    _lokasiProdukController = TextEditingController();
    _minimalPemesananController = TextEditingController();
    _stokController = TextEditingController();

    // Panggil _fetchProductDetails di sini
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      final response = await http.get(
        Uri.parse('https://projek.cloud/api/produk/${widget.productId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final product = json.decode(response.body);
        setState(() {
          _namaProdukController.text = product['nama_produk'] ?? '';
          _hargaController.text = (product['harga'] ?? '').toString();
          _deskripsiController.text = product['deskripsi'] ?? '';
          _satuanController.text = product['satuan'] ?? '';
          _lokasiProdukController.text = product['lokasi_produk'] ?? '';
          _minimalPemesananController.text =
              (product['minimal_pemesanan'] ?? '').toString();
          _stokController.text = (product['stok'] ?? '').toString();
          _currentImageUrl = product['gambar'] ?? '';
        });
      } else {
        throw Exception('Failed to load product details');
      }
    } else {
      // Token not available, perhaps need authentication process
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token != null) {
        var request = http.MultipartRequest(
          'PUT', // Use POST method for sending multipart form data
          Uri.parse(
              'https://projek.cloud/api/update-produk/${widget.productId}'),
        );
        request.headers['Authorization'] = 'Bearer $token';
        request.fields['_method'] = 'PUT'; // Use method override for PUT
        request.fields['nama_produk'] = _namaProdukController.text;
        request.fields['harga'] = _hargaController.text;
        request.fields['deskripsi'] = _deskripsiController.text;
        request.fields['satuan'] = _satuanController.text;
        request.fields['lokasi_produk'] = _lokasiProdukController.text;
        request.fields['minimal_pemesanan'] = _minimalPemesananController.text;
        request.fields['stok'] = _stokController.text;

        if (_image != null) {
          request.files.add(
            await http.MultipartFile.fromPath('gambar', _image!.path),
          );
        } else {
          // If no new image selected, send the current image URL
          request.fields['gambar'] = _currentImageUrl!;
        }

        final response = await request.send();
        if (response.statusCode == 200) {
          Navigator.pop(
            context,
            true,
          ); // Return to previous screen with success flag
        } else {
          // Handle error, if any
          print('Failed to update product: ${response.reasonPhrase}');
        }
      } else {
        // Token not available, perhaps need authentication process
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _namaProdukController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    _satuanController.dispose();
    _lokasiProdukController.dispose();
    _minimalPemesananController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Produk'),
      ),
      body: _currentImageUrl == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _namaProdukController,
                      decoration: InputDecoration(labelText: 'Nama Produk'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _hargaController,
                      decoration: InputDecoration(labelText: 'Harga'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product price';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _deskripsiController,
                      decoration: InputDecoration(labelText: 'Deskripsi'),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product description';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _lokasiProdukController,
                      decoration: InputDecoration(labelText: 'Lokasi Produk'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product location';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _minimalPemesananController,
                      decoration:
                          InputDecoration(labelText: 'Minimal Pemesanan'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter minimum order';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _stokController,
                      decoration: InputDecoration(labelText: 'Stok'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stock';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pickImage,
                      child: _image == null
                          ? _currentImageUrl != null
                              ? Image.network(
                                  'https://projek.cloud/' + _currentImageUrl!,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.camera_alt, size: 50),
                                )
                          : Image.file(
                              _image!,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateProduct,
                      child: Text('Update Product'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
