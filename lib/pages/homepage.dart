import 'package:flutter/material.dart';
import 'package:pl2_kasir/pages/create_produk.dart';
import 'package:pl2_kasir/pages/penjualan.dart';
import 'package:pl2_kasir/pages/transaksi.dart';
import 'package:pl2_kasir/pages/user_management.dart';
import 'package:pl2_kasir/wigdet/app_bar.dart';
import 'package:pl2_kasir/wigdet/bottom_nav.dart';
import 'package:pl2_kasir/wigdet/customer_product_list.dart';
import 'package:pl2_kasir/wigdet/product_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  final int userId;
  final String username;
  final String userRole;

  const HomePage({
    Key? key,
    required this.userId,
    required this.username,
    required this.userRole,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late String _currentRole;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentRole = widget.userRole;
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await Supabase.instance.client.from('produk').select();
      setState(() {
        _products = List<Map<String, dynamic>>.from(response);
        _filteredProducts = _products;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products
            .where((product) => product['namaproduk']
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _deleteProduct(int id) async {
    try {
      await Supabase.instance.client.from('produk').delete().eq('produkid', id);
      await _fetchProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error menghapus produk: $e')),
        );
      }
    }
  }

  Widget _buildContent() {
    if (_currentRole == 'admin' || _currentRole == 'pegawai') {
      return Column(
        children: [
          Padding(
            // opsional
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterProducts,
              decoration: InputDecoration(
                labelText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ProductList(
                    products: _filteredProducts,
                    isEditable: true,
                    onDelete: _deleteProduct,
                    onRefresh: _fetchProducts,
                  ),
          ),
        ],
      );
    } else if (_currentRole == 'pelanggan') {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterProducts,
              decoration: InputDecoration(
                labelText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomerProductList(products: _filteredProducts),
          ),
        ],
      );
    } else {
      return const Center(child: Text('Role tidak dikenali.'));
    }
  }

  void _handleNavigation(int index) {
    setState(() => _currentIndex = index);

    if (_currentRole == 'admin' && index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserManagementPage(),
        ),
      );
    }
    if (_currentRole == 'admin' && index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TransactionHistoryPage(),
        ),
      );
    }
    if (_currentRole == 'pegawai' && index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(),
        ),
      );
    }
    if (_currentRole == 'pegawai' && index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TransactionHistoryPage(),
        ),
      );
    }

    // Tambahkan navigasi untuk menu lain sesuai kebutuhan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        currentRole: _currentRole,
        userRole: widget.userRole,
        onRoleSwitch: (role) => setState(() => _currentRole = role),
      ),
      body: _buildContent(),
      floatingActionButton:
          (_currentRole == 'admin' || _currentRole == 'pegawai')
              ? FloatingActionButton(
                  backgroundColor: const Color.fromARGB(255, 94, 120, 236),
                  child: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const CreateProductPage(productId: null),
                      ),
                    ).then((_) => _fetchProducts());
                  },
                )
              : null,
      bottomNavigationBar: CustomBottomNav(
        currentRole: _currentRole,
        currentIndex: _currentIndex,
        onTap: _handleNavigation, // Menggunakan fungsi _handleNavigation
      ),
    );
  }
}
