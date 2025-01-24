import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model untuk Transaksi
class Transaction {
  final int penjualanId;
  final String tanggalPenjualan;
  final double totalHarga;
  final String namaPelanggan;

  Transaction({
    required this.penjualanId,
    required this.tanggalPenjualan,
    required this.totalHarga,
    required this.namaPelanggan,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      penjualanId: json['penjualanid'],
      tanggalPenjualan: json['tanggalpenjualan'],
      totalHarga: json['totalharga'].toDouble(),
      namaPelanggan: json['pelanggan']['nama'],
    );
  }
}

// Model untuk Detail Transaksi
class TransactionDetail {
  final int detailId;
  final int penjualanId;
  final String namaProduk;
  final int jumlahProduk;
  final double subtotal;

  TransactionDetail({
    required this.detailId,
    required this.penjualanId,
    required this.namaProduk,
    required this.jumlahProduk,
    required this.subtotal,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      detailId: json['detailid'],
      penjualanId: json['penjualanid'],
      namaProduk: json['produk']['namaproduk'],
      jumlahProduk: json['jumlahproduk'],
      subtotal: json['subtotal'].toDouble(),
    );
  }
}

class TransactionHistoryPage extends StatefulWidget {
  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final _supabase = Supabase.instance.client;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final response = await _supabase
          .from('penjualan')
          .select('penjualanid, tanggalpenjualan, totalharga, pelanggan(nama)');
      
      setState(() {
        _transactions = response
            .map<Transaction>((item) => Transaction.fromJson(item))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading transactions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return ListTile(
            title: Text(transaction.namaPelanggan),
            subtitle: Text('Total: Rp${transaction.totalHarga}'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionDetailPage(
                      penjualanId: transaction.penjualanId,
                    ),
                  ),
                );
              },
              child: const Text('Lihat Detail'),
            ),
          );
        },
      ),
    );
  }
}

class TransactionDetailPage extends StatefulWidget {
  final int penjualanId;

  const TransactionDetailPage({Key? key, required this.penjualanId})
      : super(key: key);

  @override
  _TransactionDetailPageState createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final _supabase = Supabase.instance.client;
  List<TransactionDetail> _transactionDetails = [];
  double _totalTransaksi = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchTransactionDetails();
  }

  Future<void> _fetchTransactionDetails() async {
    try {
      final response = await _supabase
          .from('detailpenjualan')
          .select('detailid, penjualanid, jumlahproduk, subtotal, produk(namaproduk)')
          .eq('penjualanid', widget.penjualanId);
      
      setState(() {
        _transactionDetails = response
            .map<TransactionDetail>((item) => TransactionDetail.fromJson(item))
            .toList();
        
        _totalTransaksi = _transactionDetails
            .fold(0.0, (sum, detail) => sum + detail.subtotal);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading transaction details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _transactionDetails.length,
              itemBuilder: (context, index) {
                final detail = _transactionDetails[index];
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
              'Total Transaksi: Rp$_totalTransaksi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}