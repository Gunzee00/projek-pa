import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:partani_mobile/components/component%20penjual/bottombar_penjual.dart';
import 'package:partani_mobile/pages/profile%20user/editprofile.dart';
import 'package:partani_mobile/user_login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userInfo;
  bool isAuthenticated = true; // Menambahkan flag untuk autentikasi

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('token') ?? '';

    if (authToken.isEmpty) {
      // Mengatur flag autentikasi jika token kosong
      setState(() {
        isAuthenticated = false;
      });

      // Menampilkan dialog jika token kosong
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Peringatan"),
              content: Text("Kamu harus melakukan autentikasi dahulu."),
              actions: <Widget>[
                // Tombol untuk pergi ke halaman login
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
                // Tombol untuk menutup popup
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

      return; // Menghentikan eksekusi lebih lanjut jika token kosong
    }

    final url = Uri.parse('https://projek.cloud/api/user/profile');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $authToken', // Mengirim token di header
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userInfo = json.decode(response.body);
      });
    } else {
      print("Gagal menampilkan profil");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      // bottomNavigationBar: BottombarPenjual(),
      body: isAuthenticated
          ? userInfo != null
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/person.png'),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfileField(
                                label: 'Username',
                                value: userInfo!['username']),
                            ProfileField(
                                label: 'Nama Lengkap',
                                value: userInfo!['nama_lengkap']),
                            ProfileField(
                                label: 'Nomor Telepon',
                                value: userInfo!['nomor_telepon']),
                            ProfileField(
                              label: 'Alamat',
                              value: userInfo!['alamat'],
                              maxLines: 2,
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditProfilePage()),
                                    );
                                  },
                                  child: Text('Edit Profil'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child:
                      CircularProgressIndicator()) // Menampilkan indikator loading selama data diambil
          : Container(), // Tidak menampilkan apapun jika tidak terautentikasi
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;

  const ProfileField({
    Key? key,
    required this.label,
    required this.value,
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
        Text(
          value,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16),
        ),
        Divider(),
      ],
    );
  }
}
