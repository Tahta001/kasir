//digunakan untuk header halaman
// ignore_for_file: prefer_const_constructors, use_super_parameters

import 'package:flutter/material.dart';
import 'package:pl2_kasir/pages/login.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRole;
  final String userRole;
  final Function(String) onRoleSwitch;

  const CustomAppBar({
    Key? key,
    required this.currentRole,
    required this.userRole,
    required this.onRoleSwitch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 94, 120, 236),
      title: Text(
        currentRole == 'admin'
            ? 'Admin Dashboard'
            : currentRole == 'pegawai'
                ? 'Pegawai Dashboard'
                : 'Pelanggan Dashboard',
      ),
      actions: [
        _buildRoleSwitcher(),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRoleSwitcher() {
    return userRole == 'admin'
        ? PopupMenuButton<String>(
            onSelected: onRoleSwitch,
            icon: const Icon(Icons.swap_horiz),
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'admin', child: Text('Switch to admin')),
              const PopupMenuItem(
                  value: 'pegawai', child: Text('Switch to pegawai')),
              const PopupMenuItem(
                  value: 'pelanggan', child: Text('Switch to pelanggan')),
            ],
          )
        : Container();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
