// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pl2_kasir/services/produk_service.dart';

// Membuat StatefulWidget untuk halaman pembuatan/edit produk
class CreateProductPage extends StatefulWidget {
  final int? productId;
  const CreateProductPage({super.key, this.productId});

  @override
  CreateProductPageState createState() => CreateProductPageState();
}

class CreateProductPageState extends State<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk mengontrol input teks (nama, harga, stok)
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  // Service untuk operasi produk
  late ProductService _productService;

  // Flag untuk menunjukkan proses loading
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _productService = ProductService(context);
    _loadProductData();
  }

  // Method untuk memuat data produk yang akan diedit
  Future<void> _loadProductData() async {
    if (widget.productId != null) {
      setState(() => _isLoading = true);
      try {
        // Ambil daftar produk
        final products = await _productService.fetchProducts();
        final product = products.firstWhere(
          (product) => product['produkid'] == widget.productId,
          orElse: () => throw Exception('Produk tidak ditemukan'),
        );

        // Isi form dengan data produk yang ada
        _nameController.text = product['namaproduk'];
        _priceController.text = product['harga'].toString();
        _stockController.text = product['stok'].toString();
      } catch (e) {
        // Tampilkan pesan error jika gagal memuat data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error memuat data produk: $e')),
        );
      }
      // Set loading menjadi false
      setState(() => _isLoading = false);
    }
  }

  // Membersihkan controller saat widget dihapus
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // Method untuk menambah atau memperbarui produk
  Future<void> _addOrUpdateProduct() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Ambil nilai dari input
    final name = _nameController.text;
    final price = double.parse(_priceController.text);
    final stock = int.parse(_stockController.text);

    try {
      // Cek apakah sedang menambah produk baru atau update
      if (widget.productId == null) {
        // Tambah produk baru
        await _productService.addProduct(name, price, stock);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan')),
        );
      } else {
        // Update produk yang sudah ada
        await _productService.updateProduct(
            widget.productId!, name, price, stock);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil diperbarui')),
        );
      }
      // Kembali ke halaman sebelumnya dengan status sukses
      Navigator.pop(context, true);
    } catch (e) {
      // Tampilkan pesan error jika gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  // Method untuk membangun form input produk
  Widget _buildProductForm() {
    // Tampilkan indikator loading jika sedang memproses
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Bangun form dengan validasi
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input nama produk
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Produk',
              border: OutlineInputBorder(),
            ),
            // Validasi input  
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama produk tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(
              labelText: 'Harga',
              border: OutlineInputBorder(),
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Harga tidak boleh kosong';
              }
              if (double.tryParse(value) == null) {
                return 'Masukkan angka yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _stockController,
            decoration: const InputDecoration(
              labelText: 'Stok',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Stok tidak boleh kosong';
              }
              if (int.tryParse(value) == null) {
                return 'Masukkan angka yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _isLoading ? null : _addOrUpdateProduct,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              widget.productId == null ? 'Tambah Produk' : 'Update Produk',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  // Method untuk membangun tampilan halaman
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar juudl
      appBar: AppBar(
        title: Text(widget.productId == null ? 'Tambah Produk' : 'Edit Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildProductForm(),
      ),
    );
  }
}
