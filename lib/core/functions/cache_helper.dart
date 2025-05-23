// import 'package:shared_preferences/shared_preferences.dart';

// class CacheHelper {
//   static late SharedPreferences sharedPreferences;

//   static init() async {
//     sharedPreferences = await SharedPreferences.getInstance();
//   }

//   static dynamic getSaveData({required dynamic key}) {
//     return sharedPreferences.get(key);
//   }

//   static Future<bool> saveData({
//     required String key,
//     required dynamic value,
//   }) async {
//     if (value is String) {
//       await sharedPreferences.setString(key, value);
//       return true;
//     }
//     if (value is bool) {
//       await sharedPreferences.setBool(key, value);
//       return true;
//     }
//     if (value is int) {
//       await sharedPreferences.setInt(key, value);
//       return true;
//     }
//     if (value is double) {
//       await sharedPreferences.setDouble(key, value);
//       return true;
//     }
//     if (value is List) {
//       await sharedPreferences.setStringList(key, value);
//       return true;
//     } else {
//       return false;
//     }
//   }

//   static Future<bool> removeData({required String key}) async {
//     return await sharedPreferences.remove(key);
//   }

//   static Future<String> storeData({
//     required String key,
//     required String value,
//   }) async {
//     await sharedPreferences.setString(key, value);
//     return value;
//   }
// }

import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<void> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (value is List<String>) {
      await sharedPreferences.setStringList(key, value);
    }
  }

  static Future<List<String>> getSaveData({required String key}) async {
    return sharedPreferences.getStringList(key) ?? [];
  }
}
