import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PesananPembeliPage extends StatefulWidget {
  @override
  _PesananPembeliPageState createState() => _PesananPembeliPageState();
}

class _PesananPembeliPageState extends State<PesananPembeliPage> {
  List<Map<String, dynamic>> pesananPembeli = [];
  late String token;
  bool isPesananDibatalkan =
      false; // State untuk melacak apakah pesanan telah dibatalkan

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    String apiUrl =
        'http://10.0.2.2:8000/api/pesanan/pembeli'; // Sesuaikan dengan URL yang benar
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          pesananPembeli =
              json.decode(response.body).cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      // Tambahkan penanganan kesalahan jika diperlukan
    }
  }

  Future<void> batalkanPesanan(int idPesanan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    String apiUrl =
        'http://10.0.2.2:8000/api/pesanan/batalkan/$idPesanan'; // Sesuaikan dengan URL yang benar
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        // Pesanan berhasil dibatalkan, perbarui state
        setState(() {
          isPesananDibatalkan = true;
        });
        // Pesanan berhasil dibatalkan, lakukan sesuatu jika diperlukan
        // Misalnya, muat ulang data pesanan atau tampilkan pesan sukses
        fetchData(); // Memuat ulang data pesanan setelah pembatalan
      } else {
        throw Exception('Gagal membatalkan pesanan');
      }
    } catch (e) {
      print('Error: $e');
      // Tambahkan penanganan kesalahan jika diperlukan
    }
  }

  void _showPesananDetail(Map<String, dynamic> pesanan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detail Pesanan'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Penjual: ${pesanan['penjual']}'),
              Text('Nama Produk: ${pesanan['nama_produk']}'),
              Text('Jumlah: ${pesanan['jumlah']} ${pesanan['satuan']}'),
              Text('Total Harga: Rp. ${pesanan['total_harga']}'),
              Text('Status: ${_getStatusText(pesanan['status'])}'),
              Text('Alamat Pengirim: ${(pesanan['alamat_penjual'])}'),
              Text('Nomor Penjual: ${pesanan['nomor_telepon_penjual']}'),
              // Add other necessary information as needed
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
            IconButton(
              onPressed: () {
                // Construct the WhatsApp message with the seller's phone number
                String phoneNumber = pesanan['nomor_telepon_penjual'];
                String message = 'Halo, saya tertarik dengan produk Anda.';

                // Launch WhatsApp with the predefined message
                _launchWhatsApp(phoneNumber, message);
              },
              icon: Icon(
                Icons.chat,
                color: Colors.green,
              ), // Add your desired chat icon
            ),
          ],
        );
      },
    );
  }

// Function to launch WhatsApp with a predefined message
  void _launchWhatsApp(String phoneNumber, String message) async {
    // Encode the message for URL
    String urlMessage = Uri.encodeComponent(message);

    // Construct the WhatsApp URL
    String url = 'https://wa.me/$phoneNumber/?text=$urlMessage';

    // Check if WhatsApp is installed on the device and launch the URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle if WhatsApp is not installed
      print('Could not launch WhatsApp');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesanan Saya'),
      ),
      body: pesananPembeli.isEmpty
          ? Center(
              child: Text(
                'Tidak ada pesanan',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: pesananPembeli.length,
              itemBuilder: (BuildContext context, int index) {
                final pesanan = pesananPembeli[index];

                final penjual = pesanan[
                    'penjual']; // Ubah sesuai dengan key nama penjual dalam respons API
                final bool isPesananDibuat = pesanan['status'] == '1';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Warna latar belakang pemisah
                        borderRadius: BorderRadius.circular(8), // Radius field
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [],
                      ),
                    ),

                    Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        onTap: () {
                          _showPesananDetail(
                              pesanan); // Tampilkan detail pesanan saat pesanan ditekan
                        },
                        leading: Image.asset(
                          'assets/images/image.jpeg',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(pesanan['nama_produk'] ?? ''),
                        subtitle: Text(
                          'Total Harga: Rp. ${pesanan['total_harga']}\n'
                          'Jumlah Pesanan:  ${pesanan['jumlah']} ${pesanan['satuan']}\n'
                          'Status: ${_getStatusText(pesanan['status'])}',
                        ),
                      ),
                    ),

                    // Tampilkan tombol "Batalkan Pesanan" jika pesanan belum dibatalkan
                    // Tampilkan tombol "Batalkan Pesanan" jika pesanan dibuat
                    if (isPesananDibuat)
                      ElevatedButton(
                        onPressed: () {
                          final idPesanan = pesanan['id_pesanan'];
                          if (idPesanan != null) {
                            // Tampilkan dialog konfirmasi sebelum membatalkan pesanan
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Konfirmasi Pembatalan Pesanan'),
                                  content: Text(
                                      'Yakin ingin membatalkan pesanan ini?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Tutup dialog
                                      },
                                      child: Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Batalkan pesanan jika pengguna menekan "Ya"
                                        batalkanPesanan(idPesanan);
                                        Navigator.of(context)
                                            .pop(); // Tutup dialog
                                      },
                                      child: Text('Ya'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            print('ID pesanan tidak tersedia');
                          }
                        },
                        child: Text('Batalkan Pesanan'),
                      ),
                  ],
                );
              },
            ),
    );
  }

  String _getStatusText(String status) {
    if (status == '1') {
      return 'Pesanan Dibuat';
    } else if (status == '2') {
      return 'Pesanan Dibatalkan';
    } else if (status == '3') {
      return 'Pesanan Diterima ';
    } else if (status == '4') {
      return 'Pesanan Ditolak Oleh Penjual';
    } else {
      return 'Status Tidak Dikenali';
    }
  }
}
