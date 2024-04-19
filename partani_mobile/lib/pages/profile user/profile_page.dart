import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:partani_mobile/pages/profile%20user/editprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('token') ?? '';

    final url = Uri.parse('http://10.0.2.2:8000/api/user/profile');
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
      print("gagal menampilkan profile");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Pembeli'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/image.jpeg'),
            ),
            SizedBox(height: 20),
            userInfo != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileField(
                            label: 'Username', value: userInfo!['username']),
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
                        ProfileField(
                          label: 'Password',
                          value: '******', // Informasi password
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
                                      builder: (context) => EditProfilePage()),
                                );
                              },
                              child: Text('Edit Profile'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : CircularProgressIndicator(), // Menampilkan indikator loading selama data diambil
          ],
        ),
      ),
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
