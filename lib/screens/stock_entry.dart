import 'package:flutter/material.dart';
import 'package:inventory_management/exports/exports.dart';

class StockEntry extends StatelessWidget {
  const StockEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Add New Entry'),
        actions: [
          IconButton(
              onPressed: () {
                createSnackbar(context: context, message: 'This is a snackbar');
              },
              icon: const Icon(Icons.notification_add))
        ],
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
