//berisi tentang halaman histori transaksi

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final _supabase = Supabase.instance.client;

  // Fungsi untuk mengambil daftar transaksi
  Future<List<Transaction>> _fetchTransactions() async {
    try {
      final List<dynamic> response = await _supabase
          .from('penjualan')
          .select('*')
          .order('penjualanid',
              ascending: false); // Urutkan dari transaksi terbaru

      // Debugging untuk memastikan data terurut
      debugPrint('Response: $response');

      return response.map((item) => Transaction.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      throw Exception('Gagal mengambil riwayat transaksi');
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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    'Transaksi #${transaction.penjualanId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanggal: ${transaction.tanggalPenjualan}'),
                      Text(
                        'Total: Rp${transaction.totalHarga.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ],
                  ),
                  trailing: Text(
                    'Pelanggan ID: ${transaction.pelangganId}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
