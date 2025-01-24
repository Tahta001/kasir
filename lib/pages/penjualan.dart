import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _supabase = Supabase.instance.client;

  List<Product> _products = [];
  List<Customer> _customers = [];
  Map<int, int> _cart = {};
  double _totalAmount = 0.0;
  int? _selectedCustomerId;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCustomers();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await _supabase.from('produk').select();
      if (response != null && response is List) {
        setState(() {
          _products = response.map((item) => Product.fromJson(item)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    }
  }

  Future<void> _fetchCustomers() async {
    try {
      final response = await _supabase.from('pelanggan').select();
      if (response != null && response is List) {
        setState(() {
          _customers = response.map((item) => Customer.fromJson(item)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading customers: $e')),
      );
    }
  }

  void _updateCart(int produkId, int value) {
    setState(() {
      if (!_cart.containsKey(produkId)) {
        _cart[produkId] = 0;
      }
      _cart[produkId] = (_cart[produkId]! + value).clamp(0, 999);

      if (_cart[produkId] == 0) {
        _cart.remove(produkId);
      }

      _totalAmount = _cart.entries.fold(0.0, (sum, entry) {
        final produk = _products.firstWhere((p) => p.produkId == entry.key);
        return sum + (produk.harga * entry.value);
      });
    });
  }

  Future<void> _processPayment() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang kosong!')),
      );
      return;
    }

    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih pelanggan terlebih dahulu!')),
      );
      return;
    }

    try {
      // Insert ke tabel `penjualan`
      final penjualanResponse = await _supabase
          .from('penjualan')
          .insert({
            'tanggalpenjualan': DateTime.now().toIso8601String(),
            'totalharga': _totalAmount,
            'pelangganid': _selectedCustomerId,
          })
          .select()
          .single();
      final penjualanId = penjualanResponse['penjualanid'];

      // Insert ke tabel `detailpenjualan`
      for (var entry in _cart.entries) {
        final produk = _products.firstWhere((p) => p.produkId == entry.key);
        await _supabase.from('detaipenjualan').insert({
          'penjualanid': penjualanId,
          'produkid': produk.produkId,
          'jumlahproduk': entry.value,
          'subtotal': produk.harga * entry.value,
        });

        // Kurangi stok produk
        await _supabase.from('produk').update({
          'stok': produk.stok - entry.value,
        }).eq('produkid', produk.produkId);
      }

      // Reset keranjang
      setState(() {
        _cart.clear();
        _totalAmount = 0.0;
        _selectedCustomerId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran berhasil diproses!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing payment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proses Pembayaran'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<int>(
              isExpanded: true,
              value: _selectedCustomerId,
              hint: const Text('Pilih Pelanggan'),
              items: _customers.map((customer) {
                return DropdownMenuItem<int>(
                  value: customer.pelangganId,
                  child: Text(customer.nama),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCustomerId = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final produk = _products[index];
                final jumlah = _cart[produk.produkId] ?? 0;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(produk.namaproduk),
                    subtitle:
                        Text('Harga: Rp${produk.harga}, Stok: ${produk.stok}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: jumlah > 0
                              ? () => _updateCart(produk.produkId, -1)
                              : null,
                        ),
                        Text(jumlah.toString()),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: produk.stok > jumlah
                              ? () => _updateCart(produk.produkId, 1)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total: Rp$_totalAmount',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _processPayment,
              child: const Text('Lanjutkan Pembayaran'),
            ),
          ),
        ],
      ),
    );
  }
}

// Model Produk
class Product {
  final int produkId;
  final String namaproduk;
  final double harga;
  final int stok;

  Product({
    required this.produkId,
    required this.namaproduk,
    required this.harga,
    required this.stok,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      produkId: json['produkid'],
      namaproduk: json['namaproduk'],
      harga: json['harga'].toDouble(),
      stok: json['stok'],
    );
  }
}

// Model Pelanggan
class Customer {
  final int pelangganId;
  final String nama;

  Customer({
    required this.pelangganId,
    required this.nama,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      pelangganId: json['pelangganid'],
      nama: json['nama'],
    );
  }
}
