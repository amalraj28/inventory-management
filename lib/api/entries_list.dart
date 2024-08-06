// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:inventory_management/db/data_models.dart';
// import 'package:inventory_management/exports/constants.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class InventoryProvider with ChangeNotifier {
//   final List<StockData> itemList;

//   InventoryProvider({required this.itemList}) {
//     _init();
//   }

//   Timer? _timer;

//   _init() async {
//     await _loadInvoicesFromStorage();
//     _scheduleDailyReset();
//   }

//   List<StockData> get items => itemList;

//   void addInvoice(StockData newInvoice) {
//     _saveInvoicesToStorage();
//     notifyListeners();
//   }

//   void _scheduleDailyReset() {
//     // Same logic as before for scheduling the reset at 12 AM IST
//     DateTime now =
//         DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
//     DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
//     Duration timeUntilMidnight = nextMidnight.difference(now);

//     _timer = Timer(timeUntilMidnight, _resetList);
//   }

//   void _resetList() {
//     _saveInvoicesToStorage();
//     notifyListeners();
//     _scheduleDailyReset();
//   }

//   Future<void> _loadInvoicesFromStorage() async {
//     SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
//     if (!sharedPrefs.containsKey(ITEM_LIST)) {
//       return;
//     }

//     final jsonData = sharedPrefs.getString(ITEM_LIST);
//     if (jsonData == null) return;

//     late final Map<DateTime, List<StockData>> data;

//     try {
//       data = jsonDecode(jsonData);
//     } catch (e) {
//       throw "Data from shared preferences can't be loaded";
//     }

		



//     if (itemsJson != null) {
//       List<dynamic> jsonList = jsonDecode(itemsJson);

//       // _items.addAll(
//       //   jsonList.map((json) {
//       //     return StockData.fromJson(json);
//       //   }).toList(),
//       // );

//       notifyListeners();
//     }
//   }

//   Future<void> _saveInvoicesToStorage() async {
//     SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
//     if (!sharedPrefs.containsKey(ITEM_LIST)) {
//       final newPrefObject = {
//         DateTime.now(): itemList,
//       };

//       sharedPrefs.setString(ITEM_LIST, jsonEncode(newPrefObject));
//     } else {
//       final prefObjectAsString = sharedPrefs.getString(ITEM_LIST);
//       if (prefObjectAsString == null) return;

//       late final Map<DateTime, List<StockData>> prefObject;

//       try {
//         prefObject = jsonDecode(prefObjectAsString);
//       } catch (e) {
//         return;
//       }

//       final today = DateTime.now();
//       final keysList = prefObject.keys.toList();

//       keysList.map((key) {
//         final diff = today.difference(key).inHours;
//         if (diff < 0 || diff >= 24) {
//           prefObject.remove(key);
//         }
//       });

//       if (prefObject.isEmpty) {
//         final newPrefObject = {
//           DateTime.now(): itemList,
//         };
//         sharedPrefs.setString(ITEM_LIST, jsonEncode(newPrefObject));
//       } else if (prefObject[today] == null || prefObject.length > 1) {
//         throw ('Inconsistent data storage in ITEM_LIST shared preference');
//       } else {
//         prefObject[today]!.addAll(itemList);
//         sharedPrefs.setString(ITEM_LIST, jsonEncode(prefObject));
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
// }
