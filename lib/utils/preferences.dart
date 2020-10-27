import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Future setString(String key, String value) async {
    (await SharedPreferences.getInstance()).setString(key, value);
  }
  static Future<String> getString(String key) async {
    return (await SharedPreferences.getInstance()).getString(key) ?? null;
  
  }
}