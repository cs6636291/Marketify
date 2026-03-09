import 'package:flutter/material.dart';
import 'package:marketify_app/api_service.dart';
import 'package:marketify_app/chat_page.dart';
import 'package:marketify_app/review_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_model.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isFollowing = false;
  int selectedQuantity = 1;

  late Product product;
  Future<List<Review>>? _reviewsFuture;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      product = ModalRoute.of(context)!.settings.arguments as Product;
      _reviewsFuture = ApiService().fetchReviews(product.id);
      _isInitialized = true;
    }
  }

  void _showSelectionSheet(BuildContext context, bool isBuyNow) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(
                              "http://10.0.2.2/my_shop/images/${product.imageUrl}",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "฿${product.price}",
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "คลัง: ${product.stock}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "จำนวน",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (selectedQuantity > 1) {
                                setModalState(() => selectedQuantity--);
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            "$selectedQuantity",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              if (selectedQuantity < product.stock) {
                                setModalState(() => selectedQuantity++);
                              }
                            },
                            icon: const Icon(Icons.add_circle_outline, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        Navigator.pop(context);

                        if (isBuyNow) {
                          if (mounted) {
                            Navigator.pushNamed(
                              context,
                              '/buynow',
                              arguments: {
                                'product': product,
                                'quantity': selectedQuantity,
                              },
                            );
                          }
                        } else {
                          final prefs = await SharedPreferences.getInstance();
                          final String? userId = prefs.getString('user_id');

                          if (userId != null) {
                            bool success = await ApiService().addToCart(
                              int.parse(product.id),
                              selectedQuantity,
                              int.parse(userId),
                            );

                            if (success) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text("เพิ่ม ${product.name} ลงรถเข็นแล้ว"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text("เกิดข้อผิดพลาดในการเพิ่มลงรถเข็น"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อน")),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 209, 0, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isBuyNow ? "ซื้อตอนนี้" : "เพิ่มลงรถเข็น",
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const String imageUrlPath = "http://10.0.2.2/my_shop/images/";

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.white,
              child: Image.network(
                imageUrlPath + product.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
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
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const Text(
                    "รายละเอียดสินค้า",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // --- แก้ไข: ส่วนร้านค้าให้กดไปหน้า Shop Profile ได้ ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/shopprofile',
                          arguments: product.shopId, // ตรวจสอบชื่อตัวแปรใน Model ให้ตรงกัน
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: product.shopLogo.isNotEmpty
                                ? NetworkImage("http://10.0.2.2/my_shop/images/logo/${product.shopLogo}")
                                : const AssetImage('assets/default_shop.png') as ImageProvider,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.shopName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Text(
                                  "ดูร้านค้า >",
                                  style: TextStyle(fontSize: 12, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => isFollowing = !isFollowing),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing ? Colors.grey : Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      isFollowing ? 'Followed' : 'Follow',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Product Reviews',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            FutureBuilder<List<Review>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("ยังไม่มีรีวิว"));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => _buildReviewCard(snapshot.data![index]),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          children: [
            _buildBottomIconBtn(Icons.chat_bubble_rounded, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            }),
            const SizedBox(width: 10),
            _buildBottomIconBtn(Icons.shopping_cart, () {
              setState(() => selectedQuantity = 1);
              _showSelectionSheet(context, false);
            }),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => selectedQuantity = 1);
                  _showSelectionSheet(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 209, 0, 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Buy Now", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                child: Text(review.username.isNotEmpty ? review.username[0] : "?"),
              ),
              const SizedBox(width: 10),
              Text(review.username, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.comment),
        ],
      ),
    );
  }

  Widget _buildBottomIconBtn(IconData icon, VoidCallback onTap) {
    return Expanded(
      flex: 1,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 209, 0, 0),
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Icon(icon, color: Colors.white, size: 25),
      ),
    );
  }
}