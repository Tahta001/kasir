// Widget untuk membuat Bottom Navigation Bar berdasarkan role
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

  // Fungsi untuk menentukan item navigasi berdasarkan role
  List<BottomNavigationBarItem> _getNavItems() {
    if (currentRole == 'pelanggan') { // unutk pelanggan
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
    } else if (currentRole == 'admin') { // unutk admin
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
          label: 'Transaksi', 
        ),
      ];
    } else { //unutk pegawai
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home), 
          label: 'Home', 
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.credit_card), 
          label: 'Pembayaran', 
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trolley), 
          label: 'Transaksi', 
        ),
      ];
    }
  }
}
