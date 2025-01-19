import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRole;
  final Function(String) onRoleSwitch;
  final VoidCallback onLogout;
  final bool isAdmin;

  const CustomAppBar({
    super.key,
    required this.currentRole,
    required this.onRoleSwitch,
    required this.onLogout,
    required this.isAdmin,
  });

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
        if (isAdmin) _buildRoleSwitcher(),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: onLogout,
        ),
      ],
    );
  }

  Widget _buildRoleSwitcher() {
    return PopupMenuButton<String>(
      onSelected: onRoleSwitch,
      icon: const Icon(Icons.swap_horiz),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'admin', child: Text('Switch to admin')),
        const PopupMenuItem(value: 'pegawai', child: Text('Switch to pegawai')),
        const PopupMenuItem(
            value: 'pelanggan', child: Text('Switch to pelanggan')),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
