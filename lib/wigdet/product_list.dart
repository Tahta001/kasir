//digunakan unutk menampilkan produk dihalaman admin dan pegawai
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
            trailing: isEditable //floating button yg mengarah ke halaman create_produk
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateProductPage(
                                  productId: product['produkid']),
                            ),
                          ).then((_) => onRefresh());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(
                            context, product['produkid']),
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, int id) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop();
                onDelete(id);
              },
            ),
          ],
        );
      },
    );
  }
}
