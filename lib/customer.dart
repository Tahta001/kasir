import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'create_produk.dart';
import 'customer.dart';

class CustomerPage extends StatelessWidget {
  final String role; // Role pengguna

  CustomerPage({required this.role}); // Role dikirim dari halaman sebelumnya

  @override
  Widget build(BuildContext context) {
    if (role != 'admin') {
      // Jika bukan admin, tampilkan pesan akses ditolak
      return Scaffold(
        appBar: AppBar(
          title: Text('Halaman Pelanggan'),
        ),
        body: Center(
          child: Text(
            'Akses ditolak! Halaman ini hanya untuk admin.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    // Jika role adalah admin, tampilkan halaman pelanggan
    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Pelanggan'),
      ),
      body: Center(
        child: Text(
          'Selamat datang di halaman pelanggan!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
