class Product {
  final String id;
  final String name;
  final String price;
  final String imageUrl;
  final String description;
  final int stock;
  final String shopName; // 1. เพิ่มตัวแปร stock เป็น int
  final String shopLogo;
  final String shopId; // 1. เพิ่มตัวแปร stock เป็น int

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.stock, // 2. เพิ่มใน Constructor
    required this.shopName,
    required this.shopLogo,
    required this.shopId, // 2. เพิ่มใน Constructor
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      imageUrl: json['image_url'],
      description: json['description'] ?? "ไม่มีรายละเอียด",
      // 3. แปลงค่าจาก String ใน JSON ให้เป็น int
      stock: int.parse(json['stock'].toString()),
      shopName: json['shop_name'] ?? "ไม่ระบุ",
      shopLogo: json['logo_url'] ?? "ไม่มีรูป",
      shopId: json['shop_id']?.toString() ?? '0',
    );
  }
}