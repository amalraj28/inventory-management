import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_management/db/data_models.dart';
import 'package:inventory_management/db/database_services.dart';
import 'package:inventory_management/exports/constants.dart';
import 'package:inventory_management/screens/add_stock_cart.dart';
import 'package:inventory_management/utils.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockEntry extends StatefulWidget {
  final DatabaseServices dbServices;
  const StockEntry(this.dbServices, {super.key});

  @override
  State<StockEntry> createState() => _StockEntryState();
}

class _StockEntryState extends State<StockEntry> {
  final _itemNameController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _itemCountController = TextEditingController();
  bool purchasePriceEnabled = true;
  String statusMsg = '';
  bool success = false;
  List<StockData> itemList = [];
  num totalCost = 0;
  num unitPrice = 0;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add to Stock'),
        actions: [
          IconButton(
            onPressed: () async {
              itemList = await _loadInvoicesFromStorage();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => CartScreen(
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
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SearchField(
                suggestions: DatabaseServices.getKeys()
                    .map(
                      (e) => SearchFieldListItem<String>(e),
                    )
                    .toList(),
                searchInputDecoration: const InputDecoration(
                  label: Text('Item name'),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  border: OutlineInputBorder(),
                ),
                controller: _itemNameController,
                onSearchTextChanged: (p0) {
                  setState(() {
                    purchasePriceEnabled =
                        !DatabaseServices.getKeys().contains(p0);
                    if (!purchasePriceEnabled) {
                      _purchasePriceController.text =
                          DatabaseServices.getEntries()[p0]!['purchasePrice']
                              .toString();
                    } else {
                      _purchasePriceController.clear();
                    }
                  });
                  return null;
                },
                onSuggestionTap: (p0) {
                  setState(() {
                    purchasePriceEnabled = false;
                    _purchasePriceController.text = DatabaseServices
                            .getEntries()[p0.searchKey]!['purchasePrice']
                        .toString();
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(
                      r'^\d*\.?\d*$',
                    ),
                  ),
                ],
                enabled: purchasePriceEnabled,
                decoration: const InputDecoration(
                  label: Text('Purchase Price'),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  border: OutlineInputBorder(),
                ),
                controller: _purchasePriceController,
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(
                      r'^\d*\.?\d*$',
                    ),
                  ),
                ],
                decoration: const InputDecoration(
                  label: Text('Sale Price'),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  border: OutlineInputBorder(),
                ),
                controller: _salePriceController,
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  label: Text('Number of units'),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  border: OutlineInputBorder(),
                ),
                controller: _itemCountController,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  final availableStock =
                      int.tryParse(_itemCountController.text);
                  final salePrice = num.tryParse(_salePriceController.text);
                  final purchasePrice =
                      num.tryParse(_purchasePriceController.text);
                  final itemName = _itemNameController.text.trim();

                  if (true &&
                      itemName.isNotEmpty &&
                      availableStock != null &&
                      salePrice != null &&
                      purchasePrice != null &&
                      true) {
                    late final StockData data;
                    late bool status;

                    if (purchasePriceEnabled) {
                      // new item
                      data = StockData(
                        itemName: _itemNameController.text.trim(),
                        availableStock: availableStock,
                        purchasePrice: purchasePrice,
                        salePrice: salePrice,
                        soldStock: 0,
                      );

                      status = await widget.dbServices.create(data);
                    } else {
                      data = StockData(
                        itemName: _itemNameController.text.trim(),
                        availableStock: availableStock +
                            (int.tryParse(
                                  widget.dbServices
                                      .readProperty(itemName, 'availableStock')
                                      .toString(),
                                ) ??
                                0),
                        salePrice: salePrice,
                        purchasePrice: purchasePrice,
                      );

                      status = await widget.dbServices.update(
                        itemName,
                        {
                          'availableStock': availableStock +
                              (int.tryParse(
                                    widget.dbServices
                                        .readProperty(
                                          itemName,
                                          'availableStock',
                                        )
                                        .toString(),
                                  ) ??
                                  0),
                          'sellingPrice': salePrice,
                        },
                      );
                    }

                    setState(() {
                      success = status;
                    });

                    if (status) {
                      _itemCountController.clear();
                      _itemNameController.clear();
                      _purchasePriceController.clear();
                      _salePriceController.clear();

                      StockData newData = StockData(itemName: itemName, availableStock: availableStock, salePrice: salePrice, purchasePrice: purchasePrice);

                      await _saveInvoiceToStorage(newData);

                      setState(() {
                        purchasePriceEnabled = true;
                      });
                    }
                  }
                },
                child: const Text('Submit'),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Update status: ${success.toString().toUpperCase()}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                  fontSize: 15,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveInvoiceToStorage(StockData data) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    if (!sharedPrefs.containsKey(ADD_STOCK_LIST)) {
      final newPrefObject = {
        Utils.formatDate(DateTime.now()): [data],
      };
      try {
        sharedPrefs.setString(ADD_STOCK_LIST, jsonEncode(newPrefObject));
      } catch (e) {
        return;
      }
    } else {
      final prefObjectAsString = sharedPrefs.getString(ADD_STOCK_LIST);
      if (prefObjectAsString == null) {
        return;
      }

      late final Map<String, List<StockData>> prefObject;

      try {
        Map<String, dynamic> data = jsonDecode(prefObjectAsString);
        prefObject = data.map((key, value) {
          return MapEntry(
            key,
            (value as List<dynamic>).map((item) {
              return StockData.fromJson(jsonEncode(item));
            }).toList(),
          );
        });
      } catch (e) {
        return;
      }

      final date = Utils.formatDate(DateTime.now());

      if (prefObject.containsKey(date)) {
        prefObject[date]!.add(data);
      } else {
        prefObject[date] = [data];
      }

      await sharedPrefs.setString(ADD_STOCK_LIST, jsonEncode(prefObject));
    }
  }

  Future<List<StockData>> _loadInvoicesFromStorage() async {
    await _clearStorage();

    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    if (!sharedPrefs.containsKey(ADD_STOCK_LIST)) {
      return [];
    }

    final jsonData = sharedPrefs.getString(ADD_STOCK_LIST);
    if (jsonData == null) return [];

    late final Map<String, dynamic> data;

    try {
      data = jsonDecode(jsonData);
    } catch (e) {
      return [];
    }

    // Convert JSON data to Map<String, List<StockData>>
    final Map<String, List<StockData>> parsedData = {};
    data.forEach((key, value) {
      final List<dynamic> itemsList = value as List<dynamic>;
      parsedData[key] = itemsList.map((item) {
        return StockData.fromJson(jsonEncode(item));
      }).toList(); // Passing JSON string to your factory method
    });

    try {
      final today = Utils.formatDate(DateTime.now());
      if (parsedData.containsKey(today) && parsedData[today] != null) {
        return parsedData[today]!;
      }
    } catch (e) {
      return [];
    }

    return [];
  }

  Future<void> _clearStorage() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final pref = sharedPrefs.getString(ADD_STOCK_LIST);

    if (pref == null || pref.isEmpty) return;
    late final Map<String, List<StockData>> data;
    try {
      data = jsonDecode(pref);
    } catch (e) {
      return;
    }

    final keys = data.keys.toList();

    for (final key in keys) {
      if (data.containsKey(key)) {
        data.remove(key);
      }
    }

    await sharedPrefs.setString(ADD_STOCK_LIST, jsonEncode(data));
  }
}
