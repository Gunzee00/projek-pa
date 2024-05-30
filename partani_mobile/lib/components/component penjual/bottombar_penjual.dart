import 'package:flutter/material.dart';
import 'package:partani_mobile/pages/penjual/manage_product.dart';
import 'package:partani_mobile/pages/penjual/penjual_page.dart';
import 'package:partani_mobile/pages/penjual/pesanan_page.dart';
import 'package:partani_mobile/pages/penjual/riwayat_pesananpenjual.dart';
import 'package:partani_mobile/pages/profile%20user/profile_page.dart';

class BottombarPenjual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Color(0xFF5FA64F),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.home,
                color: Colors.white,
              ),
              iconSize: 30,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PenjualPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.dashboard_customize_sharp,
                color: Colors.white,
              ),
              iconSize: 30,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageProductPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.receipt,
                color: Colors.white,
              ),
              iconSize: 30,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PesananPenjualPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.history_sharp,
                color: Colors.white,
              ),
              iconSize: 30,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RiwayatPesananPenjualPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.account_circle,
                color: Colors.white,
              ),
              iconSize: 30,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
