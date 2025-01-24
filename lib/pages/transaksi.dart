import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model for Transaction
class Transaction {
  final int penjualanId;
  final String tanggalPenjualan;
  final double totalHarga;
  final int pelangganId;

  Transaction({
    required this.penjualanId,
    required this.tanggalPenjualan,
    required this.totalHarga,
    required this.pelangganId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      penjualanId: json['penjualanid'] as int,
      tanggalPenjualan: json['tanggalpenjualan'] as String,
      totalHarga: (json['totalharga'] as num).toDouble(),
      pelangganId: json['pelangganid'] as int,
    );
  }
}

// Model for TransactionDetail
class TransactionDetail {
  final int detailId;
  final int penjualanId;
  final int produkId;
  final int jumlahProduk;
  final double subtotal;
  final String namaProduk;

  TransactionDetail({
    required this.detailId,
    required this.penjualanId,
    required this.produkId,
    required this.jumlahProduk,
    required this.subtotal,
    required this.namaProduk,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      detailId: json['detailid'] as int,
      penjualanId: json['penjualanid'] as int,
      produkId: json['produkid'] as int,
      jumlahProduk: json['jumlahproduk'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      namaProduk: json['namaproduk'] as String,
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

  Future<List<Transaction>> _fetchTransactions() async {
    try {
      final List<dynamic> response = await _supabase
          .from('penjualan')
          .select(); // Fetch data without using .execute

      // Convert raw data to List<Transaction>
      return response.map((item) => Transaction.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      throw Exception('Failed to fetch transactions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _fetchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada transaksi tersedia.'));
          }

          final transactions = snapshot.data!;
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return ListTile(
                title: Text('#${transaction.penjualanId}'),
                subtitle: Text(
                    'Tanggal: ${transaction.tanggalPenjualan}\nTotal Harga: Rp${transaction.totalHarga}'),
                trailing: Text('Pelanggan ID: ${transaction.pelangganId}'),
                onTap: () {
                  // Navigate to transaction details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionDetailPage(
                          penjualanId: transaction.penjualanId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class TransactionDetailPage extends StatefulWidget {
  final int penjualanId;

  const TransactionDetailPage({super.key, required this.penjualanId});

  @override
  _TransactionDetailPageState createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final _supabase = Supabase.instance.client;

  Future<List<TransactionDetail>> _fetchTransactionDetails() async {
    try {
      final List<dynamic> response = await _supabase
          .from('detailpenjualan')
          .select(
              'detailid, penjualanid, produkid, jumlahproduk, subtotal, produk(namaproduk)')
          .eq('penjualanid', widget.penjualanId);

      // Convert raw data to List<TransactionDetail>
      return response.map((item) => TransactionDetail.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error fetching transaction details: $e');
      throw Exception('Failed to fetch transaction details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: FutureBuilder<List<TransactionDetail>>(
        future: _fetchTransactionDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada detail transaksi.'));
          }

          final details = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: details.length,
                  itemBuilder: (context, index) {
                    final detail = details[index];
                    return ListTile(
                      title: Text(detail.namaProduk),
                      subtitle: Text('Jumlah: ${detail.jumlahProduk}'),
                      trailing: Text('Subtotal: Rp${detail.subtotal}'),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total Transaksi: Rp${details.fold<double>(
                        0,
                        (sum, item) => sum + item.subtotal,
                      ).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
