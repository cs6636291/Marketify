import 'package:flutter/material.dart';
import 'package:marketify_app/api_service.dart';
import 'package:marketify_app/product_card.dart';
import 'package:marketify_app/product_model.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget _buildBanner() {
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: NetworkImage(
            'http://localhost/my_shop/images/banner1.jpg',
          ), // ใส่ URL รูป Banner
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCategoryMenu() {
    List<Map<String, dynamic>> categories = [
      {'name': 'เสื้อผ้า', 'icon': Icons.checkroom},
      {'name': 'อิเล็กทรอนิกส์', 'icon': Icons.electrical_services},
      {'name': 'ความงาม', 'icon': Icons.face},
      {'name': 'อาหาร', 'icon': Icons.fastfood},
    ];

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 218, 0, 0).withOpacity(0.2),
                  child: Icon(categories[index]['icon'], color: Colors.orange),
                ),
                const SizedBox(height: 5),
                Text(
                  categories[index]['name'],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 35,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 228, 228, 228),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search Here',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.pushNamed(context, '/about'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.pushNamed(context, '/about'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // ทำให้หน้าจอเลื่อนลงได้ทั้งหน้า
        child: Column(
          children: [
            // 1. ส่วน Banner สไลด์
            _buildBanner(),

            // 2. ส่วนเมนูหมวดหมู่
            _buildCategoryMenu(),

            // 3. ส่วนหัวข้อ "สินค้าแนะนำ"
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "สินค้าแนะนำ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // 4. ส่วนรายการสินค้า (ต้องใช้แบบห้ามเลื่อนแยก เพื่อให้เลื่อนไปพร้อมกับข้างบน)
            FutureBuilder<List<Product>>(
              future: ApiService().fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.builder(
                    shrinkWrap:
                        true, // สำคัญ! เพื่อให้ Grid สูงตามจำนวนของที่มี
                    physics:
                        const NeverScrollableScrollPhysics(), // ปิดการเลื่อนของ Grid เอง
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) =>
                        ProductCard(product: snapshot.data![index]),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
