import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_management/db/data_models.dart';
import 'package:inventory_management/db/database_services.dart';
import 'package:searchfield/searchfield.dart';

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

  num totalCost = 0;
  num unitPrice = 0;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add to Stock'),
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
                                            itemName, 'availableStock')
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
}
