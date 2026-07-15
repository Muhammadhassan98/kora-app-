import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  Future<Box> openBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  Future<void> write<T>(String boxName, String key, T value) async {
    final box = await openBox(boxName);
    await box.put(key, value);
  }

  Future<T?> read<T>(String boxName, String key) async {
    final box = await openBox(boxName);
    final val = box.get(key);
    if (val == null) return null;
    return val as T?;
  }

  Future<void> delete<T>(String boxName, String key) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }
}
