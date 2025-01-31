// Digunakan untuk menampilkan daftar produk di halaman admin dan pegawai.
import 'package:flutter/material.dart';
import 'package:pl2_kasir/pages/create_produk.dart';

class ProductList extends StatelessWidget {
  // Daftar produk, status editabilitas, dan fungsi untuk menghapus dan memperbarui produk.
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
      // Widget ListView.builder digunakan untuk menampilkan daftar produk secara dinamis.
      padding: const EdgeInsets.all(8.0), // Memberikan jarak.
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          // Membungkus setiap produk dalam widget Card untuk tampilan yang rapi.
          elevation: 2, // Memberikan efek bayangan.
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            // Widget ListTile digunakan untuk menampilkan informasi produk.
            contentPadding: const EdgeInsets.all(16.0), // Padding dalam kartu.
            title: Text(
              product['namaproduk'] ?? 'Nama tidak tersedia',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              // Menampilkan informasi tambahan seperti harga dan stok.
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8), // Jarak antar elemen.
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
            trailing: isEditable
                ? Row(
                    mainAxisSize: MainAxisSize.min, // Mengatur ukuran minimal.
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navigasi ke halaman CreateProductPage dengan ID produk.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateProductPage(
                                  productId: product['produkid']),
                            ),
                          ).then(
                              (_) => onRefresh()); // Refresh setelah kembali.
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(
                            context, product['produkid']), // Konfirmasi hapus.
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi hapus produk.
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
                onDelete(id); // fngsi untuk menghapus produk.
              },
            ),
          ],
        );
      },
    );
  }
}
