import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inventory_management/db/data_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryProvider with ChangeNotifier {
  final List<StockData> _items = [];
  Timer? _timer;

  InventoryProvider() {
    _init();
  }

  _init() async {
    await _loadInvoicesFromStorage();
    _scheduleDailyReset();
  }

  List<StockData> get items => _items;

  void addInvoice(StockData newInvoice) {
    _items.add(newInvoice);
    _saveInvoicesToStorage();
    notifyListeners();
  }

  void _scheduleDailyReset() {
    // Same logic as before for scheduling the reset at 12 AM IST
    DateTime now =
        DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
    Duration timeUntilMidnight = nextMidnight.difference(now);

    _timer = Timer(timeUntilMidnight, _resetList);
  }

  void _resetList() {
    _items.clear();
    _saveInvoicesToStorage();
    notifyListeners();
    _scheduleDailyReset();
  }

  Future<void> _loadInvoicesFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? itemsJson = prefs.getString('inventoryInvoices');

    if (itemsJson != null) {
      List<dynamic> jsonList = jsonDecode(itemsJson);

      _items.addAll(
        jsonList.map((json) {
          return StockData.fromJson(json);
        }).toList(),
      );

      notifyListeners();
    }
  }

  void _saveInvoicesToStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList =
        _items.map((item) => jsonEncode(item.toJson())).toList();
    prefs.setString('inventoryInvoices', jsonEncode(jsonList));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
