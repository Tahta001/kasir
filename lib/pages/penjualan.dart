import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Produk {
  int Produktid;
  String NamaProduk;
  double Harga;
  int Stok;

  Produk({
    required this.Produktid,
    required this.NamaProduk,
    required this.Harga,
    required this.Stok,
  });
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final supabase = Supabase.instance.client;
  List<Produk> _products = [];
  final List<Produk> _selectedProducts = [];
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await supabase.from('produk').select('*');
    _products = response
        .map((row) => Produk(
              Produktid: row['produktid'],
              NamaProduk: row['namaproduk'],
              Harga: double.parse(row['harga'].toString()),
              Stok: row['stok'],
            ))
        .toList();
    setState(() {});
  }

  void _addToCart(Produk product) {
    if (product.Stok > 0) {
      setState(() {
        _selectedProducts.add(product);
        _totalAmount += product.Harga;
      });
    }
  }

  void _removeFromCart(Produk product) {
    setState(() {
      _selectedProducts.remove(product);
      _totalAmount -= product.Harga;
    });
  }

  Future<void> _processPayment() async {
    try {
      await showProgressIndicator(context);
      final transaction = await supabase.from('penjualan');
      // Insert the sales record and get the penjualanid
      final penjualanResponse = await transaction
          .from('penjualan')
          .insert({
            'pelangganid': 1,
            'tanggalpenjualan': DateTime.now().toIso8601String(),
            'totalharga': _totalAmount,
          })
          .returning('penjualanid')
          .single();

      final penjualanid = penjualanResponse['penjualanid'];

      await _updateProductStocks(transaction, penjualanid);
      await _insertDetailSales(transaction, penjualanid);
      await transaction.commit();
      Navigator.pushNamed(context, '/payment_confirmation');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing payment: $e'),
        ),
      );
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> _updateProductStocks(transaction, int penjualanid) async {
    final productUpdates = _selectedProducts.map((product) => {
          'produktid': product.Produktid,
          'stok': product.Stok - 1,
        });
    await transaction.from('produk').update(productUpdates);
  }

  Future<void> _insertDetailSales(transaction, int penjualanid) async {
    final detailSales = _selectedProducts.map((product) => {
          'penjualanid': penjualanid,
          'produktid': product.Produktid,
          'harga': product.Harga,
        });
    await transaction.from('detailpenjualan').insert(detailSales);
  }

  Future<void> showProgressIndicator(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                Produk product = _products[index];
                return ListTile(
                  title: Text(product.NamaProduk),
                  subtitle:
                      Text('Harga: Rp ${product.Harga.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => _removeFromCart(product),
                      ),
                      const SizedBox(width: 8),
                      Text(
                          '${_selectedProducts.where((p) => p.Produktid == product.Produktid).length}'),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _addToCart(product),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Total: Rp ${_totalAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _processPayment,
                  child: const Text('Proses Pembayaran'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
