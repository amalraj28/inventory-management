import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:inventory_management/db/data_models.dart';

class DatabaseServices {
  final _real = FirebaseDatabase.instance;
  late final String uuid;
  late final DatabaseReference parent;
  static Map<String, Map<String, Object>> _mapping = {};

  DatabaseServices._constructor(this.uuid) {
    parent = _real.ref('/data').child(uuid);
  }

  static Future<DatabaseServices> constructor(String uid) async {
    final dbServices = DatabaseServices._constructor(uid);
    await dbServices._updateMap();
    return dbServices;
  }

  Future<void> _updateMap() async {
    final entries = await parent.once();
    if (entries.snapshot.value == null) {
      _mapping.clear();
    } else {
      final data = Map<String, dynamic>.from(entries.snapshot.value as Map);
      _mapping = data.map(
        (key, value) {
          final innerMap = Map<String, Object>.from(value as Map);
          return MapEntry(key, innerMap);
        },
      );
    }
  }

  create(StockData data) async {
    final itemName = data.getName().toLowerCase();
    try {
      await parent.child(itemName).set(data.toJson());
      await _updateMap();
      return true;
    } catch (e) {
      log(e.toString());
    }

    return false;
  }

  static List<String> getKeys() {
    return _mapping.keys.toList();
  }

  Map<String, Map<String, Object>> getEntries() {
    return _mapping;
  }

  Map<String, Object>? read(String itemName) {
    final item = itemName.toLowerCase();
    return _mapping[item];
  }

  readProperty(String itemName, String property) {
    final item = itemName.toLowerCase();
    return _mapping[item]?[property];
  }

  Future<bool> update(String itemName, Map<String, Object> newData) async {
    final item = itemName.toLowerCase();

    try {
      final data = await parent.child(item).once();
      if (data.snapshot.value != null) {
        await parent.child(item).update(newData);
        await _updateMap();
        return true;
      }
    } catch (e) {
      log(e.toString());
    }

    return false;
  }

  delete(String itemName) async {
    try {
      await parent.child(itemName.toLowerCase()).remove();
      await _updateMap();
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
