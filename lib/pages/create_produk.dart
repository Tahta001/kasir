// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pl2_kasir/services/produk_service.dart';

class CreateProductPage extends StatefulWidget {
  final int? productId;
  const CreateProductPage({super.key, this.productId});

  @override
  CreateProductPageState createState() => CreateProductPageState();
}

class CreateProductPageState extends State<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  late ProductService _productService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _productService = ProductService(context);
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    if (widget.productId != null) {
      setState(() => _isLoading = true);
      try {
        final products = await _productService.fetchProducts();
        final product = products.firstWhere(
          (product) => product['produkid'] == widget.productId,
          orElse: () => throw Exception('Produk tidak ditemukan'),
        );

        _nameController.text = product['namaproduk'];
        _priceController.text = product['harga'].toString();
        _stockController.text = product['stok'].toString();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error memuat data produk: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _addOrUpdateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    // Method untuk menambah atau memperbarui produk
    setState(() => _isLoading = true);
    // Ambil nilai dari input
    final name = _nameController.text;
    final price = double.parse(_priceController.text);
    final stock = int.parse(_stockController.text);

    try {
      if (widget.productId == null) {
        await _productService.addProduct(name, price, stock);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan')),
        );
      } else {
        await _productService.updateProduct(
            widget.productId!, name, price, stock);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil diperbarui')),
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Widget _buildProductForm() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Produk',
              border: OutlineInputBorder(),
            ),
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

          // Tombol Tambah/Update dengan warna biru
          ElevatedButton(
            onPressed: _isLoading ? null : _addOrUpdateProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Warna biru
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              widget.productId == null ? 'Tambah Produk' : 'Update Produk',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),

          // Tombol Batal dengan warna merah
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // Warna teks putih
              backgroundColor: Colors.red, // Warna merah untuk tombol batal
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Batal', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
