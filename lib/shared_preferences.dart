import 'package:shared_preferences/shared_preferences.dart';

String _accessTokenKey = 'accessTokenKey';

Future<bool> setAccessToken(String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString(_accessTokenKey, value);
}

Future<String> getAccessToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getString(_accessTokenKey) ?? '';
}
