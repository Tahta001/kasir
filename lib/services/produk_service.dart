//unutk operasi CRUD
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final BuildContext context;
  final _supabase = Supabase.instance.client;

  ProductService(this.context);

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      final response = await _supabase
          .from('produk')
          .select()
          .order('id', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      _showError('Error mengambil data: $error');
      return [];
    }
  }

  Future<void> addProduct(String name, double price, int stock) async {
    try {
      final maxIdResponse = await _supabase
          .from('produk')
          .select('id')
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();

      final newId = (maxIdResponse?['id'] ?? 0) + 1;

      await _supabase.from('produk').insert({
        'id': newId,
        'namaproduk': name,
        'harga': price,
        'stok': stock,
      });

      _showSuccess('Produk berhasil ditambahkan');
    } catch (error) {
      _showError('Error: $error');
    }
  }

  Future<void> updateProduct(int id, String name, double price, int stock) async {
    try {
      await _supabase.from('produk').update({
        'namaproduk': name,
        'harga': price,
        'stok': stock,
      }).eq('id', id);

      _showSuccess('Produk berhasil diupdate');
    } catch (error) {
      _showError('Error: $error');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _supabase.from('produk').delete().eq('id', id);
      _showSuccess('Produk berhasil dihapus');
    } catch (error) {
      _showError('Error menghapus produk: $error');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
