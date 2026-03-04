import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ShopProfilePage extends StatelessWidget {
  const ShopProfilePage({super.key});

  // ฟังก์ชันไปถามข้อมูลจาก PHP (เขียนแยกไว้จะได้ไม่งง)
  Future<Map<String, dynamic>> getShopData(String id) async {
    final res = await http.get(Uri.parse("http://10.0.2.2/my_shop/get_shop_profile.php?id=$id"));
    return json.decode(res.body);
  }

  @override
  Widget build(BuildContext context) {
    final shopId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text("ข้อมูลร้านค้า")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getShopData(shopId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final shop = snapshot.data!;

          return Column(
            children: [
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage("http://10.0.2.2/my_shop/images/logo/${shop['logo_url']}"),
              ),
              const SizedBox(height: 10),
              Text(shop['shop_name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(shop['description'] ?? 'ไม่มีรายละเอียด'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.thumb_up, color: Colors.grey,),
                        SizedBox(width: 5,),
                        Text('27'),
                      ],
                    ),
                    SizedBox(width: 10,),
                    Text('Follower: 60')
                  ],
                ),
              )
              ,
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Image.network("http://10.0.2.2/my_shop/images/shop_banner/s_ban1.jpg"),
                    SizedBox(height: 10,),
                    Image.network("http://10.0.2.2/my_shop/images/shop_banner/s_ban2.jpg"),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}