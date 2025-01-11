import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'create_produk.dart';

class HomePage extends StatefulWidget {
  final int userId;
  final String username;

  const HomePage({Key? key, required this.userId, required this.username})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _products = []; // Menyimpan data produk
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Panggil fungsi untuk mengambil data produk
  }

  // Fungsi untuk mengambil data produk dari Supabase
  Future<void> _fetchProducts() async {
    try {
      final response = await Supabase.instance.client
          .from('produk')
          .select(); // Query data produk

      setState(() {
        _products = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Iya'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await Supabase.instance.client.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Widget _buildHomePage() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text('Tidak ada produk tersedia'),
      );
    }

    // Menampilkan data produk dalam ListView
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(product['namaproduk'] ?? 'Nama tidak tersedia'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Harga: Rp ${product['harga']}'),
                Text('Stok: ${product['stok']}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductEditPage(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigasi ke halaman produk atau create_produk
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProductPage()), // Ganti `ProductPage` dengan nama halaman Anda
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note, size: 50, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Produk',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Halaman ini akan berisi form untuk menambah dan mengedit produk',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.point_of_sale, size: 50, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Transaksi',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'Halaman ini akan berisi form transaksi penjualan',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sistem Kasir'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _confirmLogout(context),
            tooltip: 'Logout',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: Colors.grey[300],
            height: 2,
          ),
        ),
      ),
      body: _currentIndex == 0
          ? _buildHomePage()
          : _currentIndex == 1
              ? _buildProductEditPage(context)
              : _buildTransactionPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Tambah/Edit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Transaksi',
          ),
        ],
      ),
    );
  }
}
