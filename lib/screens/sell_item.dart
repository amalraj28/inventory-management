import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_management/exports/exports.dart';
import 'package:searchfield/searchfield.dart';

class SellItem extends StatelessWidget {
  SellItem({super.key});
  final _itemNameController = TextEditingController();
  final _itemCountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sell item',
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SearchField(
                controller: _itemNameController,
                searchInputDecoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Item Name',
                ),
                suggestions: searchItem
                    .map(
                      (item) => SearchFieldListItem(
                        item,
                        child: Text(
                          item,
                        ),
                      ),
                    )
                    .toList(),
                emptyWidget: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Item Not Found'),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _itemCountController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Item Count',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton.icon(
                onPressed: () {
                  final message =
                      'Name: ${_itemNameController.text}\t\t\t\t\t\tCount: ${_itemCountController.text}';
                  createSnackbar(
                    context: context,
                    message: message,
                    backgroundColor: Colors.green,
                  );
                },
                label: const Text(
                  'Submit',
                ),
                icon: const Icon(
                  Icons.check,
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Colors.blue,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
