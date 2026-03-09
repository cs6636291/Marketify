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
  String userAddress = "กำลังโหลด...";
  String userName = "กำลังโหลด...";
  String userPhone = "08x-xxx-xxxx";
  String? currentUserId;

  List<Map<String, dynamic>> checkoutItems = [];
  double subtotal = 0;
  double discountAmount = 0;
  double totalPrice = 0;

  Map<String, dynamic>? selectedVoucher;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('user_id') ?? prefs.getInt('user_id')?.toString();
      userName = prefs.getString('username') ?? "ไม่ระบุชื่อ";
      userAddress = prefs.getString('address') ?? "ยังไม่มีที่อยู่";
      userPhone = prefs.getString('phone') ?? "08x-xxx-xxxx";
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
        checkoutItems = [
          {
            'product': args['product'] as Product,
            'quantity': args['quantity'] as int,
          },
        ];
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

  void _showVoucherPicker() async {
    if (currentUserId == null) return;
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2/my_shop/get_user_vouchers.php?user_id=$currentUserId"),
      );
      List vouchers = json.decode(response.body);
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("เลือกส่วนลดของคุณ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              if (vouchers.isEmpty) const Text("ไม่มีโค้ดส่วนลด") 
              else Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: vouchers.length,
                  itemBuilder: (context, index) {
                    final v = vouchers[index];
                    return ListTile(
                      leading: const Icon(Icons.confirmation_number, color: Colors.red),
                      title: Text(v['code']),
                      onTap: () {
                        setState(() { selectedVoucher = v; _calculateTotal(); });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> _placeOrder() async {
    if (currentUserId == null) return;
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      Map<String, dynamic> orderData = {
        "user_id": currentUserId,
        "promotion_id": selectedVoucher != null ? selectedVoucher!['id'] : null,
        "total_price": subtotal,
        "discount_amount": discountAmount,
        "net_amount": totalPrice,
        "items": checkoutItems.map((item) {
          final Product p = item['product'];
          return {"product_id": p.id, "quantity": item['quantity'], "price": p.price};
        }).toList(),
      };

      final response = await http.post(
        Uri.parse("http://10.0.2.2/my_shop/place_order.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderData),
      );

      if (!mounted) return;
      Navigator.pop(context); // ปิด loading

      final result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        // --- จุดสำคัญ: ไปหน้าสำเร็จที่คุณสร้างไว้ ---
        Navigator.pushReplacementNamed(context, '/order_success', arguments: totalPrice);
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
          const Row(children: [Icon(Icons.location_on, color: Colors.red), SizedBox(width: 8), Text("ที่อยู่จัดส่ง", style: TextStyle(fontWeight: FontWeight.bold))]),
          Padding(padding: const EdgeInsets.only(left: 32, top: 8), child: Text("$userName | $userPhone\n$userAddress")),
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
        return ListTile(
          leading: Image.network("http://10.0.2.2/my_shop/images/${product.imageUrl}", width: 50, height: 50, fit: BoxFit.cover),
          title: Text(product.name),
          subtitle: Text("฿${product.price} x ${checkoutItems[index]['quantity']}"),
          trailing: Text("฿${(double.parse(product.price) * checkoutItems[index]['quantity']).toStringAsFixed(2)}"),
        );
      },
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("ยอดรวม"), Text("฿${subtotal.toStringAsFixed(2)}")]),
          if (discountAmount > 0) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("ส่วนลด", style: TextStyle(color: Colors.red)), Text("-฿${discountAmount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.red))]),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("ยอดสุทธิ", style: TextStyle(fontWeight: FontWeight.bold)), Text("฿${totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red))]),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _placeOrder,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
        child: const Text("สั่งซื้อสินค้า", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}