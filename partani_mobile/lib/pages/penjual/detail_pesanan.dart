import 'package:flutter/material.dart';

class DetailPesananPage extends StatelessWidget {
  final Map<String, dynamic> pesanan;

  DetailPesananPage({required this.pesanan});

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
              'Status: ${_getStatusText(pesanan['status'])}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Jumlah: ${pesanan['jumlah']}'),
            SizedBox(height: 10),
            Text('Nama Produk: ${pesanan['nama_produk']}'),
            SizedBox(height: 10),
            Text('Satuan: ${pesanan['satuan']}'),
            SizedBox(height: 10),
            Text('Harga: Rp. ${pesanan['harga']}'),
            SizedBox(height: 10),
            Text('Total Harga: Rp. ${pesanan['total_harga']}'),
            SizedBox(height: 10),
            Text('Pembeli: ${pesanan['pembeli']}'),
            SizedBox(height: 10),
            Image.network(
              pesanan['gambar'], // URL gambar
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
