import 'package:mobile_workforce/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentUserId {
  static String id = '';

  static Future<void> update(String userid) async {
    id = userid;
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Global.USER_ID_KEY, userid);
  }
}
