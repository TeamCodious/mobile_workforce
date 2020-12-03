import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    logout() async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.remove('tokenId');
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Settings'),
        actions: [
          Tooltip(
            message: 'Log out',
            child: ActionButton(
              onPressed: logout,
              icon: Icon(Icons.logout),
            ),
          ),
        ],
      ),
    );
  }
}
