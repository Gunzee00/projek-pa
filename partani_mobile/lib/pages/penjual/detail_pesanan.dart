import 'package:flutter/material.dart';
import 'package:partani_mobile/user_login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPesananPage extends StatefulWidget {
  final Map<String, dynamic> pesanan;

  DetailPesananPage({required this.pesanan});

  @override
  _DetailPesananPageState createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  late String token = '';
  late String role = '';

  @override
  void initState() {
    super.initState();
    initializeTokenAndRole();
  }

  Future<void> initializeTokenAndRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? '';
      role = prefs.getString('role') ?? '';
      if (role != 'penjual') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${_getStatusText(widget.pesanan['status'])}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Jumlah: ${widget.pesanan['jumlah']}'),
            SizedBox(height: 10),
            Text('Nama Produk: ${widget.pesanan['nama_produk']}'),
            SizedBox(height: 10),
            Text('Satuan: ${widget.pesanan['satuan']}'),
            SizedBox(height: 10),
            Text('Harga: Rp. ${widget.pesanan['harga']}'),
            SizedBox(height: 10),
            Text('Total Harga: Rp. ${widget.pesanan['total_harga']}'),
            SizedBox(height: 10),
            Text('Pembeli: ${widget.pesanan['pembeli']}'),
            SizedBox(height: 10),
            Image.network(
              widget.pesanan['gambar'], // URL gambar
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Pesanan Dibuat';
      case 2:
        return 'Pesanan Diproses';
      default:
        return 'Pesanan Dibuat';
    }
  }
}
