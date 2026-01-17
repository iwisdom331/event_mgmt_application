import 'package:shared_preferences/shared_preferences.dart';

class SavedData {
  static SharedPreferences? preferences;
  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

  static Future<void> saveUserId(String id) async {
    await preferences!.setString('userId', id);
  }

  static String getUserId() {
    return preferences!.getString('userId') ?? "";
  }

  static Future<void> saveUsername(String name) async {
    await preferences!.setString("name", name);
  }

  static String getUserName() {
    return preferences!.getString('name') ?? "";
  }

  static Future<void> saveUserEmail(String email) async {
    await preferences!.setString("email", email);
  }

  static String getUserEmail() {
    return preferences!.getString('email') ?? "";
  }

  static Future<void> clearSavedData() async {
    await preferences!.clear();
    print("saved data cleared");
  }
}
