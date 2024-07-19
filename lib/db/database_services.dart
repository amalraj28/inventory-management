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

  create(StockData data) {
    final itemName = data.getName();
    try {
      parent.child(itemName).set(data.toJson());
    } catch (e) {
      log(e.toString());
    }
  }

  read(String itemName) async {
    try {
      final data = await parent.child(itemName).once();
      return data.snapshot.exists ? data.snapshot.value : null;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  readProperty(String itemName, String property) async {
    final data = await read(itemName);
    if (data != null) return data[property];
    return null;
  }

  update(String itemName, Map<String, Object> newData) async {
    try {
      final data = await parent.child(itemName).once();
      if (data.snapshot.exists) {
        await parent.child(itemName).update(newData);
        return true;
      }
    } catch (e) {
      log(e.toString());
    }

    return false;
  }

  delete(String itemName) async {
    try {
      await parent.child(itemName).remove();
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
