import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  dynamic prefs;
  
  Future initialize() async {
    // Obtain shared preferences.
    prefs = await SharedPreferences.getInstance();
  }

  storeData(String key, String value) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();

    // Save an String value to 'action' key.
    // await prefs.setString('action', 'Start');
    await prefs.setString(key, value);
  }

  // String? getData(String key) {
  //   // Try reading data from the 'action' key. If it doesn't exist, returns null.
  //   // final String? action = prefs.getString('action');
  //   final String? value = this.prefs.getString(key);
  //   return value;
  // }

  // <<<<<<<<<<>>>>>>>>>>>>>
  // This set of functions used to be standalone outside the 'LocalStorage' class
  // They were collapsed into the class (2023.07.21)
  Future<String?> getData(String key) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    // prefs.reload();

    // Try reading data from the 'action' key. If it doesn't exist, returns null.
    // final String? action = prefs.getString('action');
    final String? value = prefs.getString(key);
    return value ?? '';
  }

  Future<Map<String, String>> getDataMap(List<String> keys) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    // prefs.reload();

    Map<String, String> data = {};

    //traverse through each element of list
    for (var i = 0; i < keys.length; i++) {
      // print(keys[i]);

      // Try reading data from the 'action' key. If it doesn't exist, returns null.
      // final String? action = prefs.getString('action');
      final String? value = prefs.getString(keys[i]);
      data[keys[i]] = value ?? '';
    }
    return data;
  }

  Future<bool> removeData(String key) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();

    // Remove data for the 'counter' key.
    // final success = await prefs.remove('counter');
    final success = await prefs.remove(key);
    return success;
  }

  Future<bool> clearAll() async {
    final prefs = await SharedPreferences.getInstance();

    final success = await prefs.clear();
    return success;
  }
  // ! <<<<<<<<<<>>>>>>>>>>>>>
}


final localStorage = LocalStorage();