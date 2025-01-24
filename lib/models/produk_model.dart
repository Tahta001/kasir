// Model data produk
//ini berisi model data yang berada dalam apk

class ProductModel {
  final int id; // ID produk
  final String namaProduk; // Nama produk
  final double harga; // Harga produk
  final int stok;// Stok produk

  // Constructor untuk inisialisasi objek ProductModel
  ProductModel({
    required this.id,
    required this.namaProduk,
    required this.harga,
    required this.stok,
  });

  // Factory method untuk membuat objek ProductModel dari JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['produkid'], // Mengambil ID produk dari JSON
      namaProduk: json['namaproduk'], // Mengambil nama produk dari JSON
      harga: json['harga'], // Mengambil harga produk dari JSON
      stok: json['stok'], // Mengambil stok produk dari JSON
    );
  }

  // Method untuk mengubah objek ProductModel menjadi format JSON
  Map<String, dynamic> toJson() {
    return {
      'produkid': id, // Menyimpan ID produk ke dalam JSON
      'namaproduk': namaProduk, // Menyimpan nama produk ke dalam JSON
      'harga': harga, // Menyimpan harga produk ke dalam JSON
      'stok': stok, // Menyimpan stok produk ke dalam JSON
    };
  }
}

