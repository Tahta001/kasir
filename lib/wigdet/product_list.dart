import 'package:flutter/material.dart';
import 'package:pl2_kasir/pages/create_produk.dart';

class ProductList extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final bool isEditable;
  final Function(int) onDelete;
  final Function() onRefresh;

  const ProductList({
    super.key,
    required this.products,
    required this.isEditable,
    required this.onDelete,
    required this.onRefresh,
  });

  void _navigateToEdit(BuildContext context, int productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateProductPage(productId: productId),
      ),
    ).then((_) => onRefresh());
  }

  Widget _buildProductInfo(Map<String, dynamic> product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product['namaproduk'] ?? 'Nama tidak tersedia',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Harga: Rp ${product['harga']}',
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          'Stok: ${product['stok']}',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, int productId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () => _navigateToEdit(context, productId),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteConfirmation(context, productId),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedProducts = List<Map<String, dynamic>>.from(products)
      ..sort((a, b) => (a['namaproduk'] ?? '')
          .toLowerCase()
          .compareTo((b['namaproduk'] ?? '').toLowerCase()));

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: sortedProducts.length,
      itemBuilder: (context, index) {
        final product = sortedProducts[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: _buildProductInfo(product),
            trailing:
                isEditable ? _buildActions(context, product['produkid']) : null,
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, int id) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete(id);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
