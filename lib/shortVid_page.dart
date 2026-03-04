import 'package:flutter/material.dart';

class ShortvidPage extends StatefulWidget {
  const ShortvidPage({super.key});

  @override
  State<ShortvidPage> createState() => _ShortvidPageState();
}

class _ShortvidPageState extends State<ShortvidPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ShortVideo'),
      ),
    );
  }
}