import 'package:flutter/material.dart';
import 'package:marketify_app/api_service.dart';
import 'package:marketify_app/product_card.dart';
import 'package:marketify_app/product_model.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 35,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 228, 228, 228),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search Here',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.pushNamed(context, '/noti'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. ส่วน Banner
            Container(
              height: 180,
              width: double.infinity,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: const DecorationImage(
                  image: NetworkImage(
                    'http://10.0.2.2/my_shop/images/banner1.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 2. ส่วนเมนู (เขียนเรียงกัน 4 ปุ่มแบบง่ายๆ เลย)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // --- ปุ่มที่ 1: เสื้อผ้า ---
                  // --- ปุ่มที่ 1: เสื้อผ้า ---
                  Column(
                    children: [
                      InkWell(
                        onTap: () => print("ไปหน้าเสื้อผ้า"),
                        child: const CircleAvatar(
                          radius: 30, // ปรับขนาดวงกลมที่นี่
                          backgroundColor: Color.fromARGB(255, 199, 0, 0),
                          child: Icon(
                            Icons.category,
                            color: Colors.white,
                            size: 30,
                          ), // ปรับขนาด Icon ที่นี่
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ), // ระยะห่างระหว่างไอคอนกับข้อความ
                      const Text("Category", style: TextStyle(fontSize: 18)),
                    ],
                  ),

                  // --- ปุ่มที่ 2: ไฟฟ้า ---
                  Column(
                    children: [
                      InkWell(
                        onTap: () => print("ไปหน้าไฟฟ้า"),
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Color.fromARGB(255, 199, 0, 0),
                          child: Icon(
                            Icons.discount,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text("Promotion", style: TextStyle(fontSize: 18)),
                    ],
                  ),

                  // --- ปุ่มที่ 3: ความงาม ---
                  Column(
                    children: [
                      InkWell(
                        onTap: () => print("ไปหน้าความงาม"),
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Color.fromARGB(255, 199, 0, 0),
                          child: Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text("Code", style: TextStyle(fontSize: 18)),
                    ],
                  ),

                  // --- ปุ่มที่ 4: อาหาร ---
                  Column(
                    children: [
                      InkWell(
                        onTap: () => print("ไปหน้าอาหาร"),
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Color.fromARGB(255, 199, 0, 0),
                          child: Icon(
                            Icons.fastfood,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text("อาหาร", style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),

            // 3. หัวข้อสินค้าแนะนำ
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recommendation",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // 4. รายการสินค้า (FutureBuilder เหมือนเดิม)
            FutureBuilder<List<Product>>(
              future: ApiService().fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
