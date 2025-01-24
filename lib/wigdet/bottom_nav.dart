import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final String currentRole;
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentRole,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: _getNavItems(),
    );
  }

  List<BottomNavigationBarItem> _getNavItems() {
    if (currentRole == 'pelanggan') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Keranjang',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profil',
        ),
      ];
    } else if (currentRole == 'admin') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trolley),
          label: 'transaksi',
        ),
      ];
    } else {
      // untuk pegawai
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.credit_card),
          label: 'pembayaran',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trolley),
          label: 'transaksi',
        ),
      ];
    }
  }
}
