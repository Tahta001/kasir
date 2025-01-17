import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userRole;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adminItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Setting',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: 'Pegawai',
      ),
    ];

    final pelangganItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: 'Cart',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.account_circle),
        label: 'Profile',
      ),
    ];

    final items =
        userRole == 'admin' ? adminItems : pelangganItems; // Pilihan navigasi.

    return BottomNavigationBar(
      backgroundColor: const Color.fromARGB(255, 222, 222, 222),
      unselectedItemColor: const Color.fromARGB(153, 71, 69, 69),
      selectedItemColor: const Color.fromARGB(255, 122, 143, 248),
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
    );
  }
}
