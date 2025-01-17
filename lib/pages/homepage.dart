import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'create_produk.dart'; // Pastikan halaman Create/Edit Produk sudah ada

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
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentRole = widget.userRole; // Role default sesuai login awal
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  /// Fungsi untuk mengganti role
  void _switchRole(String role) {
    setState(() {
      _currentRole = role; // Role baru akan diaktifkan
    });
  }

  /// Widget switcher (khusus admin)
  Widget _buildRoleSwitcher() {
    return widget.userRole == 'admin'
        ? PopupMenuButton<String>(
            onSelected: _switchRole,
            icon: const Icon(Icons.swap_horiz),
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'admin', child: Text('Switch to admin')),
              const PopupMenuItem(
                  value: 'pegawai', child: Text('Switch to pegawai')),
              const PopupMenuItem(
                  value: 'pelanggan', child: Text('Switch to pelanggan')),
            ],
          )
        : Container();
  }

  /// Filter produk berdasarkan pencarian
  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
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

  /// List produk untuk admin dan pegawai
  Widget _buildProductList({required bool isEditable}) {
    return ListView.builder(
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
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
            trailing: isEditable
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductPage(productId: product['id']),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product['id']),
                      ),
                    ],
                  )
                : null, // Tidak ada tombol untuk pegawai
          ),
        );
      },
    );
  }

  /// Isi konten sesuai role aktif
  Widget _buildContent() {
    if (_currentRole == 'admin') {
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
                : _buildProductList(isEditable: true),
          ),
        ],
      );
    } else if (_currentRole == 'pegawai') {
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
                : _buildProductList(
                    isEditable: false), // Pegawai tidak bisa edit
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
                : _buildProductListPelanggan(),
          ),
        ],
      );
    } else {
      return const Center(child: Text('Role tidak dikenali.'));
    }
  }

  /// List produk untuk pelanggan
  Widget _buildProductListPelanggan() {
    return ListView.builder(
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Produk ditambahkan ke keranjang')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_bag),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produk dibeli!')),
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

  /// Hapus produk (admin)
  Future<void> _deleteProduct(int id) async {
    await Supabase.instance.client.from('produk').delete().eq('id', id);
    setState(() {
      _products.removeWhere((product) => product['id'] == id);
      _filteredProducts = _products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 94, 120, 236),
        title: Text(
          _currentRole == 'admin'
              ? 'Admin Dashboard'
              : _currentRole == 'pegawai'
                  ? 'Pegawai Dashboard'
                  : 'Pelanggan Dashboard',
        ),
        actions: [
          if (_currentRole == 'admin') // Tombol tambah produk hanya untuk admin
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                // Navigasi ke halaman CreateProdukPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductPage(
                      productId: null,
                    ),
                  ),
                ).then(
                    (_) => _fetchProducts()); // Perbarui produk setelah kembali
              },
            ),
          _buildRoleSwitcher(), // Role switcher hanya untuk admin
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _buildContent(),
      bottomNavigationBar: _currentRole == 'admin' ||
              _currentRole == 'pegawai' ||
              _currentRole == 'pelanggan'
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: _currentRole == 'pelanggan'
                  ? const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_cart),
                        label: 'Keranjang',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.account_circle),
                        label: 'Profil',
                      ),
                    ]
                  : const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings),
                        label: 'Settings',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.people),
                        label: 'Pegawai',
                      ),
                    ],
            )
          : null,
    );
  }
}
