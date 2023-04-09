import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AppPref {
  static String _AddCustomerPermissionCode = "";
  static String get AddCustomerPermissionCode => _AddCustomerPermissionCode;
  static set AddCustomerPermissionCode(String value) {
    print('set value ${value}');
    SetString("AddCustomerPermissionCode", value);

  }

  static final Future<SharedPreferences> Prefs = SharedPreferences.getInstance();

  static void LoadSettings() async {
    _AddCustomerPermissionCode = await GetString("AddCustomerPermissionCode");
    //SetString("AddCustomerPermissionCode", "910547");
  }

  static Future<String> GetString(String key) async {
    SharedPreferences _pref = await Prefs;
    return _pref.getString(key)??'';
  }

  static Future<void> SetString(String key, String value) async {
    SharedPreferences _pref = await Prefs;
    _pref.setString(key, value);
  }
}