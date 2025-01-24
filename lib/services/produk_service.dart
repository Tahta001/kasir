// Kelas untuk operasi CRUD produk berdasarkn Supabase
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final BuildContext context;// BuildContext untuk menampilkan pesan
  final _supabase = Supabase.instance.client;// Instance klien untuk koneksi database

  ProductService(this.context);

  // Method untuk mengambil semua produk dari database
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      // Mengambil data dari tabel 'produk' dan mengurutkannya berdasarkan ID
      final response = await _supabase
          .from('produk')
          .select()
          .order('produkid', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      // Tampilkan pesan error jika gagal
      _showError('Error mengambil data: $error');
      return [];
    }
  }

  // Method untuk menambah produk baru
  Future<void> addProduct(String name, double price, int stock) async {
    try {
      // Ambil ID produk terakhir untuk membuat ID baru
      final maxIdResponse = await _supabase
          .from('produk')
          .select('produkid')
          .order('produkid', ascending: false)
          .limit(1)
          .maybeSingle();

      // Buat ID baru (increment dari ID terakhir)
      final newId = (maxIdResponse?['produkid'] ?? 0) + 1;

      // Masukkan produk baru ke database
      await _supabase.from('produk').insert({
        'produkid': newId,
        'namaproduk': name,
        'harga': price,
        'stok': stock,
      });

      _showSuccess('Produk berhasil ditambahkan');
    } catch (error) {
      _showError('Error: $error');
    }
  }

  // Method untuk memperbarui produk yang sudah ada
  Future<void> updateProduct(
      int id, String name, double price, int stock) async {
    try {
      // Update data produk berdasarkan ID
      await _supabase.from('produk').update({
        'namaproduk': name,
        'harga': price,
        'stok': stock,
      }).eq('produkid', id);

      _showSuccess('Produk berhasil diupdate');
    } catch (error) {
      _showError('Error: $error');
    }
  }

  // Method untuk menghapus produk
  Future<void> deleteProduct(int id) async {
    try {
      // Hapus produk berdasarkan ID
      await _supabase.from('produk').delete().eq('produkid', id);
      _showSuccess('Produk berhasil dihapus');
    } catch (error) {
      _showError('Error menghapus produk: $error');
    }
  }

  // Method untuk menampilkan pesan sukses
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Method untuk menampilkan pesan error
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}