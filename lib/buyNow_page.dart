import 'package:flutter/material.dart';

class BuyNowPage extends StatefulWidget {
  const BuyNowPage({super.key});

  @override
  State<BuyNowPage> createState() => _BuyNowPageState();
}

class _BuyNowPageState extends State<BuyNowPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Now'),
      ),
    );
  }
}