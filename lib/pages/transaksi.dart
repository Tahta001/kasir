import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model for transaction details
class TransactionDetail {
  final int detailId;
  final int produkId;
  final int jumlahProduk;
  final double subtotal;
  final int penjualanId;

  TransactionDetail({
    required this.detailId,
    required this.produkId,
    required this.jumlahProduk,
    required this.subtotal,
    required this.penjualanId,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      detailId: json['detailid'] as int,
      produkId: json['produkid'] as int,
      jumlahProduk: json['jumlahproduk'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      penjualanId: json['penjualanid'] as int,
    );
  }
}

// Transaction model
class Transaction {
  final int penjualanId;
  final String tanggalPenjualan;
  final double totalHarga;
  final int pelangganId;
  final List<TransactionDetail> details;
  bool isExpanded;

  Transaction({
    required this.penjualanId,
    required this.tanggalPenjualan,
    required this.totalHarga,
    required this.pelangganId,
    this.details = const [],
    this.isExpanded = false,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      penjualanId: json['penjualanid'] as int,
      tanggalPenjualan: json['tanggalpenjualan'] as String,
      totalHarga: (json['totalharga'] as num).toDouble(),
      pelangganId: json['pelangganid'] as int,
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

  // Fetch transactions
  Future<List<Transaction>> _fetchTransactions() async {
    try {
      final response = await _supabase
          .from('penjualan')
          .select('*')
          .order('penjualanid', ascending: false);

      List<Transaction> transactions =
          (response as List).map((item) => Transaction.fromJson(item)).toList();

      // Fetch details for each transaction
      for (var transaction in transactions) {
        final detailsResponse = await _supabase
            .from('detailpenjualan')
            .select()
            .eq('penjualanid', transaction.penjualanId);

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
                        'ID Pelanggan: ${transaction.pelangganId}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
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
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...transaction.details.map((detail) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Produk #${detail.produkId}'),
                                    Text('${detail.jumlahProduk}x'),
                                    const SizedBox(width: 16),
                                    Text(
                                      formatCurrency(detail.subtotal),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                formatCurrency(transaction.totalHarga),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
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
