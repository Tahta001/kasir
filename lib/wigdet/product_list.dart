import 'package:flutter/material.dart';

class ProductList extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final String currentRole;
  final Function(int) onDelete;
  final Function(int) onEdit;
  final Function(int) onAddToCart;
  final Function(int) onBuyNow;

  const ProductList({
    Key? key,
    required this.products,
    required this.currentRole,
    required this.onDelete,
    required this.onEdit,
    required this.onAddToCart,
    required this.onBuyNow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: ListTile(
            title: Text(product['namaproduk'] ?? 'Nama tidak tersedia'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Harga: Rp ${product['harga']}'),
                Text('Stok: ${product['stok']}'),
              ],
            ),
            trailing: _buildTrailingWidget(context, product),
          ),
        );
      },
    );
  }

  Widget _buildTrailingWidget(
      BuildContext context, Map<String, dynamic> product) {
    if (currentRole == 'admin') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => onEdit(product['id']),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(product['id']),
          ),
        ],
      );
    } else if (currentRole == 'pelanggan') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () => onAddToCart(product['id']),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag),
            onPressed: () => onBuyNow(product['id']),
          ),
        ],
      );
    }
    return Container(); // For pegawai role, no trailing widgets
  }
}
