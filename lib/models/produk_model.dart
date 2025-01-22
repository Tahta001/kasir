//model data produk
class ProductModel {
  final int id;
  final String namaProduk;
  final double harga;
  final int stok;

  ProductModel({
    required this.id,
    required this.namaProduk,
    required this.harga,
    required this.stok,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      namaProduk: json['namaproduk'],
      harga: json['harga'],
      stok: json['stok'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaproduk': namaProduk,
      'harga': harga,
      'stok': stok,
    };
  }
}
