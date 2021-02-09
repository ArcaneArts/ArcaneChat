import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class ArcaneStorage {
  static Directory documentsPath;
  static Directory cachePath;
  static String resourcePath;
  static bool ready = false;

  static Box getSettings() {
    if (!ready) {
      return null;
    }

    return Hive.box("settings");
  }

  static Box getWallets() {
    if (!ready) {
      return null;
    }

    return Hive.box("wallets");
  }

  static Future<bool> init() async {
    if (!kIsWeb) {
      documentsPath = await getApplicationDocumentsDirectory();
      cachePath = await getTemporaryDirectory();
      resourcePath = documentsPath.path + "/resources";
      Hive.init(documentsPath.path + "/hive");
    }

    await open("settings", "hive_key_settings");
    await open("wallets", "hive_key_wallets");
    ready = true;

    return true;
  }

  static Future<Box> open(String d, String key, {tries = 4}) async {
    if (tries < 0) {
      return null;
    }

    try {
      Box b = await Hive.openBox(d);
      return b;
    } catch (e) {
      File file = File(documentsPath.path + "/hive/" + d + ".hive");
      File lck = File(documentsPath.path + "/hive/" + d + ".lock");

      if (lck.existsSync()) {
        lck.deleteSync();
      }

      if (file.existsSync()) {
        file.deleteSync();
      }

      return open(d, key, tries: tries - 1);
    }
  }
}
