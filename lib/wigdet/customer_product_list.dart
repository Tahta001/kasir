// Digunakan untuk menampilkan daftar produk di halaman pelanggan.
import 'package:flutter/material.dart';

class CustomerProductList extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const CustomerProductList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Widget ListView.builder digunakan untuk membuat daftar produk secara dinamis.
      padding: const EdgeInsets.all(8.0), // Memberikan jarak di sekitar daftar.
      itemCount: products.length, 
      itemBuilder: (context, index) {
        final product =
            products[index]; // Mengambil data produk berdasarkan indeks.
        return Card(
          elevation: 2, // bayangan 
          margin:
              const EdgeInsets.symmetric(vertical: 4.0), // Margin antar kartu.
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0), // Padding dalam kartu.
            title: Text(
              product['namaproduk'] ?? 'Nama tidak tersedia', 
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              // Informasi tambahan seperti harga dan stok.
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
              // Bagian trailing untuk tombol aksi.
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag, color: Colors.green),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Produk dibeli'),
                        duration: Duration(seconds: 1), // Durasi notifikasi.
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
