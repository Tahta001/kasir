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
        '${currentRole.substring(0, 1).toUpperCase()}${currentRole.substring(1)} Dashboard',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        if (userRole == 'admin')
          PopupMenuButton<String>(
            onSelected: onRoleSwitch,
            icon: const Icon(Icons.swap_horiz, color: Colors.white),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'admin', child: Text('Switch to Admin')),
              PopupMenuItem(value: 'pegawai', child: Text('Switch to Pegawai')),
            ],
          ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
