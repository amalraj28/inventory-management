import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_management/db/database_services.dart';
import 'package:inventory_management/exports/exports.dart';
import 'package:searchfield/searchfield.dart';

class SellItem extends StatelessWidget {
  late final DatabaseServices dbServices;
  SellItem(this.dbServices, {super.key});
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
                suggestions: const [],
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
                onPressed: () async {
                  final count = int.tryParse(_itemCountController.text);
                  if (count == null || _itemNameController.text.isEmpty) {
                    createSnackbar(
                      context: context,
                      message: 'Invalid data',
                      backgroundColor: Colors.red,
                    );
                    return;
                  }
                  final availability = await dbServices.readProperty(
                    _itemNameController.text,
                    'remQuantity',
                  );
                  if (availability == null ||
                      availability <= 0 ||
                      count > availability) {
                    createSnackbar(
                      context: context,
                      message: 'Item out of stock or item not in database',
                      backgroundColor: Colors.red,
                    );
                    return;
                  }

                  final rem = availability - count;

                  final status = await dbServices.update(
                    _itemNameController.text,
                    {
                      'remQuantity': rem,
                    },
                  );

                  if (!status) {
                    context.mounted &&
                        createSnackbar(
                          context: context,
                          message: 'Failed to update database',
                          backgroundColor: Colors.red,
                        );
                    return;
                  }

                  createSnackbar(
                    context: context,
                    message: 'Database updated successfully',
                    backgroundColor: Colors.green,
                  );

                  _itemCountController.clear();
                  _itemNameController.clear();
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
