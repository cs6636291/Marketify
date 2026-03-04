import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification')
        ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 214, 214, 214),
                  child: Icon(Icons.local_shipping, color: Colors.white,)
                ),
                SizedBox(width: 10,),
                Expanded(child: Text('"พัสดุกำลังจัดส่ง" กรุณารอรับสินค้า ภายใน 21,00 น.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
              ],
            ),
            Divider(),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 214, 214, 214),
                  child: Icon(Icons.local_shipping, color: Colors.white,)
                ),
                SizedBox(width: 10,),
                Expanded(child: Text('"พัสดูกำลังถูกส่งไปยังสาขาปลายทาง" ผูัส่งพัสดุกำลังจะนำส่งสินค้า', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
              ],
            ),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 214, 214, 214),
                  child: Icon(Icons.local_shipping, color: Colors.white,)
                ),
                SizedBox(width: 10,),
                Expanded(child: Text('""ผู้ขนส่งพัสดุเข้ารับสินค้าแล้ว" โปรดรอสินค้า 1-2 วัน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
              ],
            ),
            Divider(),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 214, 214, 214),
                  child: Icon(Icons.local_shipping, color: Colors.white,)
                ),
                SizedBox(width: 10,),
                Expanded(child: Text('"ยืนยันคำสั่งซื้อสินค้าแล้ว" โปรดรอร้านค้าจัดส่งสินค้า', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
              ],
            ),
            Divider(),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 214, 214, 214),
                  child: Icon(Icons.local_shipping, color: Colors.white,)
                ),
                SizedBox(width: 10,),
                Expanded(child: Text('"การสั่งสินค้าสำเร็จ" โปรดรอร้านค้ายืนยัน รายการคำสั่งซื้อ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
              ],
            ),
            Divider(),
            
          ],
        ),
      ),
      );
  }
}