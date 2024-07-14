import 'package:flutter/material.dart';
import 'package:inventory_management/exports/exports.dart';

class StockEntry extends StatelessWidget {
  StockEntry({super.key});
  final _itemNameController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _itemCountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Add New Entry',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _itemNameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Item name',
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      TextFormField(
                        controller: _unitPriceController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Price for 1 unit of item',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      TextFormField(
                        controller: _itemCountController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Number of items purchased',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      TextButton.icon(
                        onPressed: () => createSnackbar(
                          context: context,
                          message: 'Submit button clicked',
                          backgroundColor: Colors.green,
                        ),
                        label: const Text(
                          'Submit',
                        ),
                        icon: const Icon(
                          Icons.check,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createSnackbar(
          context: context,
          message: 'Floating Button Pressed',
          backgroundColor: Colors.green,
        ),
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
