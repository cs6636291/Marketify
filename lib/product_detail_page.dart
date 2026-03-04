import 'package:flutter/material.dart';
import 'package:marketify_app/api_service.dart';
import 'package:marketify_app/buyNow_page.dart';
import 'package:marketify_app/chat_page.dart';
import 'package:marketify_app/review_model.dart';
import 'package:marketify_app/shop_profile_page.dart';
import 'product_model.dart'; // อย่าลืม import model มาด้วย

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isFollowing = false;
  @override
  Widget build(BuildContext context) {
    // --- 1. ส่วนการดึงข้อมูลที่ส่งมาจาก ProductCard ---
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    const String imageUrlPath = "http://10.0.2.2/my_shop/images/";

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name), // แสดงชื่อสินค้าบน AppBar
        backgroundColor: const Color.fromARGB(255, 209, 0, 0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 2. ส่วนแสดงรูปภาพสินค้าขนาดใหญ่ ---
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.white,
              child: Image.network(
                imageUrlPath + product.imageUrl,
                fit: BoxFit.contain,
              ),
            ),

            // --- 3. ส่วนรายละเอียดสินค้า ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อสินค้า
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ราคาสินค้า
                  Text(
                    '฿${product.price}',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color.fromARGB(255, 0, 161, 13),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'คงเหลือ: ${product.stock} ชิ้น',
                    style: TextStyle(
                      fontSize: 14,
                      color: product.stock > 0 ? Colors.grey[700] : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // เส้นคั่น
                  const Divider(),
                  const SizedBox(height: 10),

                  // หัวข้อรายละเอียด
                  const Text(
                    "รายละเอียดสินค้า",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // คำอธิบาย (ถ้าใน Model มี description ให้ใช้ product.description)
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => 
                    Navigator.pushNamed(
                      context, 
                      '/shopprofile',
                      arguments: product.shopId,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              product.shopLogo != null && product.shopLogo != ""
                              ? NetworkImage(
                                  "http://10.0.2.2/my_shop/images/logo/${product.shopLogo}",
                                )
                              : const AssetImage(
                                      'http://10.0.2.2/my_shop/images/default_shop.png',
                                    )
                                    as ImageProvider,
                        ),
                        SizedBox(width: 10),
                        Text(
                          product.shopName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isFollowing = !isFollowing;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing
                          ? Colors.grey
                          : const Color.fromARGB(255, 209, 0, 0),
                    ),
                    child: Text(
                      isFollowing ? 'Followed' : 'Follow',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Product Reviews',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            FutureBuilder<List<Review>>(
              future: ApiService().fetchReviews(product.id), // ดึงรีวิวตาม ID สินค้า
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("ไม่สามารถโหลดรีวิวได้"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("ยังไม่มีรีวิวสำหรับสินค้านี้", style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // ปิด scroll ซ้อน
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final review = snapshot.data![index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.red[100],
                                child: Text(review.username[0], style: const TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                review.username,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              // แสดงดาว
                              Row(
                                children: List.generate(5, (i) => Icon(
                                  Icons.star,
                                  size: 14,
                                  color: i < review.rating ? Colors.amber : Colors.grey[300],
                                )),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            review.comment,
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            review.createdAt.split(' ')[0], // แสดงแค่วันที่
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),


          ],
        ),
      ),

      //ปุ่มสั่งซื้อด้านล่างสุด
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 209, 0, 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 209, 0, 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BuyNowPage()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 209, 0, 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Buy Now",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
