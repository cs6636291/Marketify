import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_model.dart';

class BuyNowPage extends StatefulWidget {
  const BuyNowPage({super.key});

  @override
  State<BuyNowPage> createState() => _BuyNowPageState();
}

class _BuyNowPageState extends State<BuyNowPage> {
  // ข้อมูล User
  String userAddress = "กำลังโหลด...";
  String userName = "กำลังโหลด...";
  String userPhone = "08x-xxx-xxxx";
  String? currentUserId;

  List<Map<String, dynamic>> checkoutItems = [];
  double subtotal = 0;      // ราคารวมสินค้าก่อนหักส่วนลด
  double discountAmount = 0; // ยอดที่ลดไป
  double totalPrice = 0;     // ยอดสุทธิที่ต้องจ่าย (net_amount)
  
  Map<String, dynamic>? selectedVoucher; 
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ดึงข้อมูล User จาก SharedPreferences (ค่าที่ได้ตอน Login)
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('user_id');
      userName = prefs.getString('username') ?? "ไม่ระบุชื่อ";
      userAddress = prefs.getString('address') ?? "ยังไม่มีที่อยู่";
      // ถ้ามีเบอร์โทรใน prefs ให้ใส่ตรงนี้ครับ: userPhone = prefs.getString('phone') ?? "08x-xxx-xxxx";
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      if (args.containsKey('items')) {
        checkoutItems = List<Map<String, dynamic>>.from(args['items']);
      } else if (args.containsKey('product')) {
        checkoutItems = [{'product': args['product'] as Product, 'quantity': args['quantity'] as int}];
      }
      _calculateTotal();
      _isInitialized = true;
    }
  }

  void _calculateTotal() {
    double currentSubtotal = checkoutItems.fold(0, (sum, item) {
      final Product p = item['product'];
      final int q = item['quantity'];
      return sum + (double.parse(p.price) * q);
    });

    double discount = 0;
    if (selectedVoucher != null) {
      double val = double.parse(selectedVoucher!['discount_value'].toString());
      if (selectedVoucher!['discount_type'] == 'percentage') {
        discount = currentSubtotal * (val / 100);
      } else {
        discount = val;
      }
    }

    setState(() {
      subtotal = currentSubtotal;
      discountAmount = discount;
      totalPrice = currentSubtotal - discount;
    });
  }

  // เลือกโค้ดส่วนลด
  void _showVoucherPicker() async {
    if (currentUserId == null) return;
    try {
      final response = await http.get(Uri.parse("http://10.0.2.2/my_shop/get_user_vouchers.php?user_id=$currentUserId"));
      List vouchers = json.decode(response.body);

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text("เลือกส่วนลดของคุณ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: vouchers.isEmpty 
                  ? const Center(child: Text("คุณยังไม่มีโค้ดส่วนลด"))
                  : ListView.builder(
                    itemCount: vouchers.length,
                    itemBuilder: (context, index) {
                      final v = vouchers[index];
                      return ListTile(
                        leading: const Icon(Icons.confirmation_number, color: Colors.red),
                        title: Text(v['code']),
                        subtitle: Text(v['discount_type'] == 'percentage' ? "ลด ${v['discount_value']}%" : "ลด ${v['discount_value']} บาท"),
                        onTap: () {
                          setState(() {
                            selectedVoucher = v;
                            _calculateTotal();
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print("Error fetching vouchers: $e");
    }
  }

  // ฟังก์ชันส่งคำสั่งซื้อ (เข้าตาราง orders และ orderitem)
  Future<void> _placeOrder() async {
    if (currentUserId == null) return;

    // แสดง Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // เตรียม Data ส่งเป็น JSON
      Map<String, dynamic> orderData = {
        "user_id": currentUserId,
        "promotion_id": selectedVoucher != null ? selectedVoucher!['id'] : null,
        "total_price": subtotal,
        "discount_amount": discountAmount,
        "net_amount": totalPrice,
        "items": checkoutItems.map((item) {
          final Product p = item['product'];
          return {
            "product_id": p.id,
            "quantity": item['quantity'],
            "price": p.price,
          };
        }).toList(),
      };

      final response = await http.post(
        Uri.parse("http://10.0.2.2/my_shop/place_order.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderData),
      );

      if (!mounted) return;
      Navigator.pop(context); // ปิด Loading

      final result = jsonDecode(response.body);

      if (result['status'] == 'success') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("สั่งซื้อสำเร็จ"),
            content: Text("ขอบคุณที่ใช้บริการครับ\nยอดชำระ: ฿${totalPrice.toStringAsFixed(2)}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), 
                child: const Text("ตกลง")
              )
            ],
          ),
        );
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ผิดพลาด: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ทำการสั่งซื้อ"), backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAddressSection(),
            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
            _buildProductList(),
            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
            
            ListTile(
              leading: const Icon(Icons.local_offer, color: Colors.red),
              title: Text(selectedVoucher == null ? "เลือกโค้ดส่วนลด" : "ใช้โค้ด: ${selectedVoucher!['code']}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showVoucherPicker,
            ),
            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            _buildPaymentSummary(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.location_on, color: Colors.red), SizedBox(width: 8), Text("ที่อยู่ในการจัดส่ง", style: TextStyle(fontWeight: FontWeight.bold))]),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$userName | $userPhone", style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(userAddress, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: checkoutItems.length,
      itemBuilder: (context, index) {
        final Product product = checkoutItems[index]['product'];
        final int quantity = checkoutItems[index]['quantity'];
        return ListTile(
          leading: Image.network("http://10.0.2.2/my_shop/images/${product.imageUrl}", width: 60, height: 60, fit: BoxFit.cover),
          title: Text(product.name),
          subtitle: Text("฿${product.price} x $quantity"),
        );
      },
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _summaryRow("ยอดรวมสินค้า", "฿${subtotal.toStringAsFixed(2)}"),
          if (discountAmount > 0)
            _summaryRow("ส่วนลดจากโค้ด", "-฿${discountAmount.toStringAsFixed(2)}", isDiscount: true),
          _summaryRow("ค่าจัดส่ง", "฿0.00"),
          const Divider(),
          _summaryRow("ยอดชำระเงินทั้งหมด", "฿${totalPrice.toStringAsFixed(2)}", isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(color: isDiscount || isTotal ? Colors.red : Colors.black, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("รวมจ่าย: ฿${totalPrice.toStringAsFixed(2)}", style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 15),
          ElevatedButton(
            onPressed: _placeOrder,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
            child: const Text("สั่งซื้อสินค้า", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}