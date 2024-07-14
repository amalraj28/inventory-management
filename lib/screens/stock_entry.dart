import 'package:flutter/material.dart';

class StockEntry extends StatelessWidget {
  const StockEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
				title: const Text('Add New Entry'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('This is the inventory page')],
        ),
      ),
    );
  }
}
