import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_management/db/database_services.dart';
import 'package:inventory_management/exports/constants.dart';
import 'package:inventory_management/exports/exports.dart';
import 'package:inventory_management/screens/sale_list_screen.dart';
import 'package:inventory_management/utils.dart';

import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellItem extends StatefulWidget {
  final DatabaseServices dbServices;
  const SellItem({super.key, required this.dbServices});

  @override
  State<SellItem> createState() => _SellItemState();
}

class _SellItemState extends State<SellItem> {
  final _itemNameController = TextEditingController();
  final _itemCountController = TextEditingController();
  late final GlobalKey<FormState> formKey;
  List<Map<String, Object>> itemList = [];

  @override
  void initState() {
    // TODO: implement initState
    formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sell item',
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: () async {
              itemList = await _loadFromSharedPrefs();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => SaleListScreen(
                    items: itemList,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SearchField(
                  controller: _itemNameController,
                  validator: (value) =>
                      value == null || !_isItemInDatabase(value)
                          ? 'Item not found in database'
                          : null,
                  searchInputDecoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Item Name',
                  ),
                  suggestions: DatabaseServices.getKeys()
                      .map((e) => SearchFieldListItem<String>(e))
                      .toList(),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (value) {
                    const illogicalError = 'Illogical value entered!';
                    if (value == null) return illogicalError;
                    final count = int.tryParse(value);
                    if (count == null) return illogicalError;
                    final itemName =
                        _itemNameController.text.trim().toLowerCase();
                    return !_isValidCount(count, itemName)
                        ? 'Value exceeds the available stock or is illogical!'
                        : null;
                  },
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
                    // 	final count = int.tryParse(_itemCountController.text);
                    // 	if (count == null ||
                    // 			_itemNameController.text.isEmpty ||
                    // 			count <= 0) {
                    // 		return;
                    // 	}
                    // 	final obj = widget.dbServices.readProperty(
                    // 		_itemNameController.text,
                    // 		'remQuantity',
                    // 	);

                    // 	final availability = int.tryParse(obj.toString()) ?? -1;
                    // 	if (availability <= 0 || count > availability) {
                    // 		createSnackbar(
                    // 			context: context,
                    // 			message: 'Item out of stock or item not in database',
                    // 			backgroundColor: Colors.red,
                    // 		);
                    // 		return;
                    // 	}

                    // 	final rem = availability - count;
                    // 	final status = await widget.dbServices.update(
                    // 		_itemNameController.text,
                    // 		{
                    // 			'remQuantity': rem,
                    // 		},
                    // 	);

                    // 	if (!status) {
                    // 		context.mounted &&
                    // 				createSnackbar(
                    // 					context: context,
                    // 					message: 'Failed to update database',
                    // 					backgroundColor: Colors.red,
                    // 				);
                    // 		return;
                    // 	}

                    // 	context.mounted &&
                    // 			createSnackbar(
                    // 				context: context,
                    // 				message: 'Database updated successfully',
                    // 				backgroundColor: Colors.green,
                    // 			);

                    // 	_itemCountController.clear();
                    // 	_itemNameController.clear();

                    // Step 1: check if item is in database
                    if (formKey.currentState!.validate()) {
                      final itemName =
                          _itemNameController.text.trim().toLowerCase();
                      final soldFromDb = int.tryParse(widget.dbServices
                              .readProperty(itemName, 'soldStock')!
                              .toString()) ??
                          0;
                      final countEntered =
                          int.tryParse(_itemCountController.text) ?? 0;

                      final res = await widget.dbServices.update(
                        itemName,
                        {'soldStock': countEntered + soldFromDb},
                      );

                      if (!res && context.mounted) {
                        createSnackbar(
                          context: context,
                          message: 'Failed to update entry',
                          backgroundColor: Colors.red,
                        );

                        return;
                      }

                      if (context.mounted) {
                        createSnackbar(
                          context: context,
                          message: 'Value updated in DB successfully',
                          backgroundColor: Colors.green,
                        );
                      }

                      bool status = await _addToSharedPref({
                        'itemName': itemName,
                        'soldStock': countEntered,
                      });

                      if (status) {
                        _itemCountController.clear();
                        _itemNameController.clear();
                      }
                    }
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
      ),
    );
  }

  bool _isItemInDatabase(String? item) {
    if (item == null) return false;
    item = item.trim().toLowerCase();

    return DatabaseServices.getKeys().contains(item);
  }

  bool _isValidCount(num count, String itemName) {
    if (count <= 0) return false;

    final available =
        widget.dbServices.readProperty(itemName, 'availableStock');
    if (available == null) return false;

    final availabilityFromDb = num.tryParse(available.toString());
    if (availabilityFromDb == null) return false;

    final sold = widget.dbServices.readProperty(itemName, 'soldStock');
    if (sold == null) return false;
    final soldFromDb = num.tryParse(sold.toString());
    if (soldFromDb == null) return false;
    return soldFromDb + count <= availabilityFromDb;
  }

  Future<bool> _addToSharedPref(Map<String, Object> data) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final date = Utils.formatDate(DateTime.now());

    if (sharedPrefs.containsKey(SALE_LIST)) {
      final prefData = sharedPrefs.getString(SALE_LIST);
      if (prefData == null) {
        await sharedPrefs.remove(SALE_LIST);
      } else {
        try {
          // final Map<String, dynamic> savedData = jsonDecode(prefData);

          // final Map<String, List<dynamic>> parsedData = {};
          // savedData.forEach((key, value) {
          //   final List<dynamic> itemsList = value as List<dynamic>;
          //   parsedData[key] = itemsList
          //       .map((item) => {
          //             'itemName': item['itemName'],
          //             'soldStock': item['soldStock'],
          //           })
          //       .toList();
          // });
          // parsedData[date]!.add(data);

          // return await sharedPrefs.setString(
          //   SALE_LIST,
          //   jsonEncode({date: savedData}),
          // );
          final Map<String, dynamic> savedData = jsonDecode(prefData);

// Step 2: Create a new Map<String, List<dynamic>>
          final Map<String, List<dynamic>> parsedData = {};

// Step 3: Iterate over the savedData and ensure each value is treated as a list
          savedData.forEach((key, value) {
            // Ensure value is treated as a List<dynamic>
            final List<dynamic> itemsList = value as List<dynamic>;
            parsedData[key] = itemsList.map((item) {
              return {
                'itemName': item['itemName'],
                'soldStock': item['soldStock'],
              };
            }).toList();
          });

// Step 4: Add new data to the list associated with the current date
          parsedData[date]!.add(data);

// Step 5: Convert the parsedData back to JSON and save it
          return await sharedPrefs.setString(
            SALE_LIST,
            jsonEncode(parsedData),
          );
        } catch (e) {
          print(e.toString());
        }
      }
    }

    return await sharedPrefs.setString(
      SALE_LIST,
      jsonEncode(
        {
          date: [data]
        },
      ),
    );
  }

  Future<List<Map<String, Object>>> _loadFromSharedPrefs() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    if (!sharedPrefs.containsKey(SALE_LIST)) {
      return [];
    }

    final dataAsString = sharedPrefs.getString(SALE_LIST);
    if (dataAsString == null) return [];

    final Map<String, dynamic> data = jsonDecode(dataAsString);
    final keys = data.keys.toList();

    for (final key in keys) {
      if (key != Utils.formatDate(DateTime.now())) {
        data.remove(key);
      }
    }

    if (data.isEmpty) return [];

    final date = Utils.formatDate(DateTime.now());

    try {
      final List<dynamic> dynamicList = data[date] as List<dynamic>;

      // Casting List<dynamic> to List<Map<String, Object>>
      final List<Map<String, Object>> ans = dynamicList.map((item) {
        // Ensure that each item is a Map<String, dynamic>
        final Map<String, dynamic> jsonMap = item as Map<String, dynamic>;

        // Convert the Map<String, dynamic> to Map<String, Object>
        return jsonMap.map((key, value) => MapEntry(key, value as Object));
      }).toList();

      return ans;
    } catch (e) {
      print('Error in loading: ${e.toString()}');
      return [];
    }
  }
}
