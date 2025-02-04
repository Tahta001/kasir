import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model Produk
class Product {
  final int id;
  final String name;

  Product({
    required this.id,
    required this.name,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['produkid'] as int,
      name: json['namaproduk'] as String,
    );
  }
}

// Model Detail Transaksi
class TransactionDetail {
  final int detailId;
  final int produkId;
  final String? productName;
  final int jumlahProduk;
  final double subtotal;
  final int penjualanId;
  final double hargaSatuan;

  TransactionDetail({
    required this.detailId,
    required this.produkId,
    this.productName,
    required this.jumlahProduk,
    required this.subtotal,
    required this.penjualanId,
    required this.hargaSatuan,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    final double subtotal = (json['subtotal'] as num).toDouble();
    final int jumlahProduk = json['jumlahproduk'] as int;

    return TransactionDetail(
      detailId: json['detailid'] as int,
      produkId: json['produkid'] as int,
      productName: json['produk']['namaproduk'] as String?,
      jumlahProduk: jumlahProduk,
      subtotal: subtotal,
      penjualanId: json['penjualanid'] as int,
      hargaSatuan: subtotal / jumlahProduk,
    );
  }
}

// Model Transaksi
class Transaction {
  final int penjualanId;
  final String tanggalPenjualan;
  final double totalHarga;
  final int pelangganId;
  final String? customerName; // Tambahan field untuk nama pelanggan
  final List<TransactionDetail> details;
  bool isExpanded;

  Transaction({
    required this.penjualanId,
    required this.tanggalPenjualan,
    required this.totalHarga,
    required this.pelangganId,
    this.customerName,
    this.details = const [],
    this.isExpanded = false,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      penjualanId: json['penjualanid'] as int,
      tanggalPenjualan: json['tanggalpenjualan'] as String,
      totalHarga: (json['totalharga'] as num).toDouble(),
      pelangganId: json['pelangganid'] as int,
      customerName: json['pelanggan']['nama']
          as String?, // Mengambil nama pelanggan dari relasi
      details: [],
    );
  }
}

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final _supabase = Supabase.instance.client;

  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  String formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    final List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  Future<List<Transaction>> fetchTransactions() async {
    try {
      // Mengubah query untuk mengambil data pelanggan
      final response = await _supabase.from('penjualan').select('''
            *,
            pelanggan (
              nama
            )
          ''').order('penjualanid', ascending: false);

      List<Transaction> transactions =
          (response as List).map((item) => Transaction.fromJson(item)).toList();

      for (var transaction in transactions) {
        final detailsResponse =
            await _supabase.from('detailpenjualan').select('''
              *,
              produk (
                namaproduk
              )
            ''').eq('penjualanid', transaction.penjualanId);

        transaction.details.addAll(
          (detailsResponse as List)
              .map((detail) => TransactionDetail.fromJson(detail))
              .toList(),
        );
      }

      return transactions;
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      throw Exception('Gagal mengambil riwayat transaksi');
    }
  }

  Future<void> deleteTransaction(int penjualanId) async {
    try {
      // Hapus detail transaksi terlebih dahulu
      await _supabase
          .from('detailpenjualan')
          .delete()
          .eq('penjualanid', penjualanId);

      // Kemudian hapus transaksi utama
      await _supabase.from('penjualan').delete().eq('penjualanid', penjualanId);

      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dihapus')),
        );
      }
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus transaksi')),
        );
      }
    }
  }

  Future<bool?> showDeleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: FutureBuilder<List<Transaction>>(
        future: fetchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada transaksi tersedia.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final transaction = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ExpansionTile(
                  title: Text(
                    'Transaksi #${transaction.penjualanId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Pelanggan: #${transaction.pelangganId} ${(transaction.customerName ?? "Unknown")}', // gunakan toUpperCase() jika ingin kapital semua
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                          'Tanggal: ${formatDate(transaction.tanggalPenjualan)}'),
                      Text(
                        'Total: ${formatCurrency(transaction.totalHarga)}',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ],
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Pesanan:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ...transaction.details.map((detail) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      detail.productName ?? "Unknown",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            '${formatCurrency(detail.hargaSatuan)} x ${detail.jumlahProduk}'),
                                        Text(
                                          formatCurrency(detail.subtotal),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              bool? confirmDelete =
                                  await showDeleteConfirmationDialog();
                              if (confirmDelete == true) {
                                await deleteTransaction(
                                    transaction.penjualanId);
                              }
                            },
                            icon: const Icon(Icons.delete, color: Colors.white),
                            label: const Text(
                              "Hapus Transaksi",
                              style: TextStyle(
                                  color: Colors.white), // Warna teks putih
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red, // Warna latar belakang tombol
                              foregroundColor:
                                  Colors.white, // Warna ikon dan teks
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
