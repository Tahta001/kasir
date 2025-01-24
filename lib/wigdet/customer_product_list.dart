//digunakan untuk menampilkan produk di halaman pelanggan
import 'package:flutter/material.dart';

class CustomerProductList extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const CustomerProductList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(
              product['namaproduk'] ?? 'Nama tidak tersedia',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag, color: Colors.green),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Produk dibeli'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
