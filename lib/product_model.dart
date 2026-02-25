class Product {
  final String id;
  final String name;
  final String price;
  final String imageUrl;

  Product({required this.id, required this.name, required this.price, required this.imageUrl});

  // ฟังก์ชันแปลง JSON จาก API มาเป็น Object ใน Dart
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'],
      price: json['price'].toString(),
      imageUrl: json['image_url'],
    );
  }
}