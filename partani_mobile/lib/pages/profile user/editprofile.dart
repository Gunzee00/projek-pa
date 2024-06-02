import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:partani_mobile/components/component%20penjual/bottombar_penjual.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _namaLengkapController = TextEditingController();
  TextEditingController _nomorTeleponController = TextEditingController();
  TextEditingController _alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('token') ?? '';

    final url = Uri.parse('https://projek.cloud/api/user/profile');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $authToken', // Mengirim token di header
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> userInfo = json.decode(response.body);
      _usernameController.text = userInfo['username'];
      _namaLengkapController.text = userInfo['nama_lengkap'];
      _nomorTeleponController.text = userInfo['nomor_telepon'];
      _alamatController.text = userInfo['alamat'];
    } else {
      throw Exception('Failed to load user info');
    }
  }

  Future<void> updateUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('token') ?? '';

    final url = Uri.parse('https://projek.cloud/api/user/update');
    final response = await http.put(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $authToken', // Mengirim token di header
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'username': _usernameController.text,
        'nama_lengkap': _namaLengkapController.text,
        'nomor_telepon': _nomorTeleponController.text,
        'alamat': _alamatController.text,
        // 'password':
        //     'new_password', // Ganti dengan password baru yang diinput oleh pengguna
      }),
    );

    if (response.statusCode == 200) {
      // Sukses mengubah profil, lakukan sesuatu seperti menampilkan pesan atau navigasi kembali
    } else {
      // Gagal mengubah profil, tampilkan pesan kesalahan atau lakukan penanganan lainnya
      throw Exception('Failed to update user info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      bottomNavigationBar: BottombarPenjual(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileFormField(
                label: 'Username',
                controller: _usernameController,
              ),
              ProfileFormField(
                label: 'Nama Lengkap',
                controller: _namaLengkapController,
              ),
              ProfileFormField(
                label: 'Nomor Telepon',
                controller: _nomorTeleponController,
              ),
              ProfileFormField(
                label: 'Alamat',
                controller: _alamatController,
                maxLines: 2,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  updateUser(); // Panggil fungsi untuk mengirim perubahan profil
                },
                child: Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const ProfileFormField({
    Key? key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
