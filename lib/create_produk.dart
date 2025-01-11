import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'login.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  List<Map<String, dynamic>> _products = [];
  int? _editingProductId;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await Supabase.instance.client
        .from('produk')
        .select()
        .order('id', ascending: true);
    setState(() {
      _products = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _addOrUpdateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final price = double.parse(_priceController.text);
    final stock = int.parse(_stockController.text);

    if (_editingProductId == null) {
      // Create product
      await Supabase.instance.client.from('produk').insert({
        'namaproduk': name,
        'harga': price,
        'stok': stock,
      });
    } else {
      // Update product
      await Supabase.instance.client.from('produk').update({
        'namaproduk': name,
        'harga': price,
        'stok': stock,
      }).eq('id', _editingProductId as Object);
    }

    _clearForm();
    _fetchProducts();
  }

  Future<void> _deleteProduct(int id) async {
    await Supabase.instance.client.from('produk').delete().eq('id', id);
    _fetchProducts();
  }

  void _editProduct(Map<String, dynamic> product) {
    setState(() {
      _editingProductId = product['id'];
      _nameController.text = product['namaproduk'];
      _priceController.text = product['harga'].toString();
      _stockController.text = product['stok'].toString();
    });
  }

  void _clearForm() {
    setState(() {
      _editingProductId = null;
      _nameController.clear();
      _priceController.clear();
      _stockController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nama Produk'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama produk tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: 'Harga'),
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
                  TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(labelText: 'Stok'),
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
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _addOrUpdateProduct,
                        child: Text(_editingProductId == null
                            ? 'Tambah Produk'
                            : 'Update Produk'),
                      ),
                      if (_editingProductId != null)
                        TextButton(
                          onPressed: _clearForm,
                          child: Text('Batal'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return Card(
                    child: ListTile(
                      title: Text(product['namaproduk']),
                      subtitle: Text(
                          'Harga: Rp ${product['harga']} | Stok: ${product['stok']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editProduct(product),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteProduct(product['id']),
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
