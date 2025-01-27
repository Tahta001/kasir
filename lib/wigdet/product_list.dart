// Digunakan untuk menampilkan daftar produk di halaman admin dan pegawai.
import 'package:flutter/material.dart';
import 'package:pl2_kasir/pages/create_produk.dart';

class ProductList extends StatelessWidget {
  // Daftar produk, status editabilitas, dan fungsi untuk menghapus dan memperbarui produk.
  final List<Map<String, dynamic>> products; // Daftar produk dalam bentuk map.
  final bool isEditable; // Menentukan apakah produk dapat diedit atau tidak.
  final Function(int) onDelete; // Fungsi untuk menghapus produk berdasarkan ID.
  final Function()
      onRefresh; // Fungsi untuk memperbarui tampilan setelah perubahan.

  // Konstruktor widget ProductList.
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
      padding:
          const EdgeInsets.all(8.0), // Memberikan padding di sekitar daftar.
      itemCount:
          products.length, // Jumlah item dalam daftar berdasarkan produk.
      itemBuilder: (context, index) {
        final product = products[index]; // Mengambil produk berdasarkan indeks.
        return Card(
          // Membungkus setiap produk dalam widget Card untuk tampilan yang rapi.
          elevation: 2, // Memberikan efek bayangan.
          margin:
              const EdgeInsets.symmetric(vertical: 4.0), // Margin antar kartu.
          child: ListTile(
            // Widget ListTile digunakan untuk menampilkan informasi produk.
            contentPadding: const EdgeInsets.all(16.0), // Padding dalam kartu.
            title: Text(
              product['namaproduk'] ?? 'Nama tidak tersedia', // Nama produk.
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              // Menampilkan informasi tambahan seperti harga dan stok.
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8), // Jarak antar elemen.
                Text(
                  'Harga: Rp ${product['harga']}', // Harga produk.
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Stok: ${product['stok']}', // Stok produk.
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            // Menambahkan tombol edit dan hapus jika mode edit diaktifkan.
            trailing: isEditable
                ? Row(
                    mainAxisSize: MainAxisSize.min, // Mengatur ukuran minimal.
                    children: [
                      IconButton(
                        // Tombol edit produk.
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
                        // Tombol hapus produk.
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
          // Dialog konfirmasi penghapusan.
          title: const Text('Konfirmasi Hapus'), 
          content: const Text(
              'Apakah Anda yakin ingin menghapus produk ini?'), 
          actions: [
            TextButton(
              // Tombol batal.
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(), 
            ),
            TextButton(
              // Tombol hapus.
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop(); 
                onDelete(id); // Panggil fungsi untuk menghapus produk.
              },
            ),
          ],
        );
      },
    );
  }
}
