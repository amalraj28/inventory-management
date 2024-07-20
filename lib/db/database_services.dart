import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:inventory_management/db/data_models.dart';

class DatabaseServices {
  final _real = FirebaseDatabase.instance;
  late final String uuid;
  late final DatabaseReference parent;

  DatabaseServices(this.uuid) {
    parent = _real.ref(uuid);
  }

  create(StockData data) async {
    final itemName = data.getName().toLowerCase();
    try {
      await parent.child(itemName).set(data.toJson());
      return true;
    } catch (e) {
      log(e.toString());
    }

    return false;
  }

  read(String itemName) async {
    try {
      final data = await parent.child(itemName.toLowerCase()).once();
      return data.snapshot.exists ? data.snapshot.value : null;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  readProperty(String itemName, String property) async {
    final data = await read(itemName.toLowerCase());
    return data != null ? data[property] : null;
  }

  Future<bool> update(String itemName, Map<String, Object> newData) async {
    final item = itemName.toLowerCase();

    try {
      final data = await parent.child(item).once();
      if (data.snapshot.value != null) {
        await parent.child(item).update(newData);
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
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
