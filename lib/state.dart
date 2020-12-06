import 'package:mobile_workforce/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentUserId {
  static String id = '';
  static String role = '';

  static Future<void> update(String userid, String _role) async {
    id = userid;
    role = _role;
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Global.USER_ID_KEY, userid);
  }
}
