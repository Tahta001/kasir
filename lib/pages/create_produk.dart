//digunakan unutun membuat dan edit produk (CRUD)
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key, required productId}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

// State untuk halaman produk, mengatur logika aplikasi
class _ProductPageState extends State<ProductPage> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form
  final TextEditingController _nameController =
      TextEditingController(); // Kontroler untuk input nama produk
  final TextEditingController _priceController =
      TextEditingController(); // Kontroler untuk input harga
  final TextEditingController _stockController =
      TextEditingController(); // Kontroler untuk input stok
  final TextEditingController _searchController =
      TextEditingController(); // Kontroler untuk pencarian produk

  List<Map<String, dynamic>> _products = []; // Daftar semua produk
  List<Map<String, dynamic>> _filteredProducts =
      []; // Daftar produk yang difilter berdasarkan pencarian
  int? _editingProductId; // Menyimpan ID produk yang sedang diedit
  bool _isLoading = false; // Indikator untuk proses loading

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Memuat data produk saat pertama kali widget dibangun
    _searchController.addListener(
        _filterProducts); // Mendengarkan perubahan pada input pencarian
  }

  @override
  void dispose() {
    _nameController.dispose(); // Membersihkan kontroler nama
    _priceController.dispose(); // Membersihkan kontroler harga
    _stockController.dispose(); // Membersihkan kontroler stok
    _searchController.dispose(); // Membersihkan kontroler pencarian
    super.dispose();
  }

  // Mengambil data produk dari database
  Future<void> _fetchProducts() async {
    try {
      setState(() {
        _isLoading = true; // Mengatur indikator loading menjadi true
      });

      // Memanggil data dari tabel 'produk' di Supabase
      final response = await Supabase.instance.client
          .from('produk')
          .select()
          .order('id', ascending: true);

      setState(() {
        _products =
            List<Map<String, dynamic>>.from(response); // Menyimpan data produk
        _filteredProducts =
            _products; // Menyimpan data produk untuk daftar yang difilter
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error mengambil data: ${error.toString()}')), // Menampilkan pesan kesalahan
      );
    } finally {
      setState(() {
        _isLoading = false; // Mengatur indikator loading menjadi false
      });
    }
  }

  // Memfilter produk berdasarkan input pencarian
  void _filterProducts() {
    final query = _searchController.text
        .toLowerCase(); // Mendapatkan teks pencarian dalam huruf kecil
    setState(() {
      _filteredProducts = _products
          .where((product) => product['namaproduk']
              .toLowerCase()
              .contains(query)) // Menyaring produk berdasarkan nama
          .toList();
    });
  }

  // Menambahkan atau memperbarui produk
  Future<void> _addOrUpdateProduct() async {
    if (!_formKey.currentState!.validate())
      return; // Memvalidasi form sebelum melanjutkan

    try {
      setState(() {
        _isLoading = true; // Mengatur indikator loading menjadi true
      });

      final name = _nameController.text; // Mengambil nilai nama produk
      final price =
          double.parse(_priceController.text); // Mengambil nilai harga produk
      final stock =
          int.parse(_stockController.text); // Mengambil nilai stok produk

      if (_editingProductId == null) {
        // Jika tidak ada ID yang sedang diedit, tambahkan produk baru
        final maxIdResponse = await Supabase.instance.client
            .from('produk')
            .select('id')
            .order('id', ascending: false)
            .limit(1)
            .maybeSingle();

        final newId = (maxIdResponse?['id'] ?? 0) + 1; // Menentukan ID baru

        await Supabase.instance.client.from('produk').insert({
          'id': newId,
          'namaproduk': name,
          'harga': price,
          'stok': stock,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Produk berhasil ditambahkan')), // Menampilkan pesan sukses
        );
      } else {
        // Jika ada ID yang sedang diedit, perbarui produk yang ada
        await Supabase.instance.client.from('produk').update({
          'namaproduk': name,
          'harga': price,
          'stok': stock,
        }).eq('id', _editingProductId as Object);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Produk berhasil diupdate')), // Menampilkan pesan sukses
        );
      }

      _clearForm(); // Membersihkan form
      await _fetchProducts(); // Memuat ulang daftar produk
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error: ${error.toString()}')), // Menampilkan pesan kesalahan
      );
    } finally {
      setState(() {
        _isLoading = false; // Mengatur indikator loading menjadi false
      });
    }
  }

  // Menghapus produk dari database
  Future<void> _deleteProduct(int id) async {
    try {
      setState(() {
        _isLoading = true; // Mengatur indikator loading menjadi true
      });

      await Supabase.instance.client
          .from('produk')
          .delete()
          .eq('id', id); // Menghapus produk berdasarkan ID

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Produk berhasil dihapus')), // Menampilkan pesan sukses
      );

      await _fetchProducts(); // Memuat ulang daftar produk
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error menghapus produk: ${error.toString()}')), // Menampilkan pesan kesalahan
      );
    } finally {
      setState(() {
        _isLoading = false; // Mengatur indikator loading menjadi false
      });
    }
  }

  // Mengisi form dengan data produk yang sedang diedit
  void _editProduct(Map<String, dynamic> product) {
    setState(() {
      _editingProductId =
          product['id']; // Menyimpan ID produk yang sedang diedit
      _nameController.text = product['namaproduk']; // Mengisi nama produk
      _priceController.text =
          product['harga'].toString(); // Mengisi harga produk
      _stockController.text = product['stok'].toString(); // Mengisi stok produk
    });
  }

  // Membersihkan form dan mengatur ulang state
  void _clearForm() {
    setState(() {
      _editingProductId = null; // Mengatur ulang ID yang sedang diedit
      _nameController.clear(); // Mengosongkan input nama
      _priceController.clear(); // Mengosongkan input harga
      _stockController.clear(); // Mengosongkan input stok
    });
  }

  // Menampilkan dialog konfirmasi sebelum menghapus produk
  Future<void> _confirmDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'), // Judul dialog
          content: const Text(
              'Apakah Anda yakin ingin menghapus produk ini?'), // Isi dialog
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // Membatalkan aksi
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(true), // Menghapus produk
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteProduct(id); // Jika konfirmasi, hapus produk
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'), // Judul halaman
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding di sekitar konten
        child: Column(
          children: [
            // Form untuk menambah atau mengedit produk
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Input nama produk
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Produk',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama produk tidak boleh kosong'; // Validasi input
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Input harga produk
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ', // Teks prefix untuk harga
                    ),
                    keyboardType: TextInputType.number, // Hanya menerima angka
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga tidak boleh kosong'; // Validasi input
                      }
                      if (double.tryParse(value) == null) {
                        return 'Masukkan angka yang valid'; // Validasi angka
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Input stok produk
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stok',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number, // Hanya menerima angka
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stok tidak boleh kosong'; // Validasi input
                      }
                      if (int.tryParse(value) == null) {
                        return 'Masukkan angka yang valid'; // Validasi angka
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _addOrUpdateProduct, // Tambah atau update produk
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _editingProductId == null
                                      ? 'Tambah Produk' // Teks tombol saat menambah
                                      : 'Update Produk', // Teks tombol saat memperbarui
                                ),
                        ),
                      ),
                      if (_editingProductId != null) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _clearForm, // Membatalkan aksi edit
                          child: const Text('Batal'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Input pencarian produk
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Cari Produk',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(), // Menampilkan indikator loading
                    )
                  : _filteredProducts.isEmpty
                      ? const Center(
                          child: Text(
                              'Tidak ada produk'), // Menampilkan pesan jika tidak ada produk
                        )
                      : ListView.builder(
                          itemCount: _filteredProducts.length, // Jumlah produk
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[
                                index]; // Produk yang sedang ditampilkan
                            return Card(
                              elevation: 2, // Bayangan pada card
                              margin: const EdgeInsets.only(
                                  bottom: 8), // Margin antar card
                              child: ListTile(
                                title: Text(
                                  product[
                                      'namaproduk'], // Menampilkan nama produk
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Harga: Rp ${product['harga'].toString()} | Stok: ${product['stok'].toString()}', // Menampilkan harga dan stok
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon:
                                          const Icon(Icons.edit), // Tombol edit
                                      onPressed: () => _editProduct(
                                          product), // Aksi edit produk
                                      tooltip: 'Edit',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.delete), // Tombol hapus
                                      onPressed: () => _confirmDelete(
                                          product['id']), // Aksi hapus produk
                                      tooltip: 'Hapus',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
