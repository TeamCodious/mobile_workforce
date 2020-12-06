import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart';
import 'package:mobile_workforce/global.dart';
import 'package:mobile_workforce/pages/home_page.dart';
import 'package:mobile_workforce/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    String _email;
    String _password;

    login() async {
      String body =
          '{"email": "' + _email + '", "password": "' + _password + '"}';
      String url = Uri.encodeFull(Global.URL + 'login/');
      Response response = await post(url, body: body);
      Map<String, dynamic> res = json.decode(response.body);
      CurrentUserId.update(res['userId'], res['employee_role']);
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('token', res['id']);
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => HomePage()));
    }

    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (String s) => _email = s,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              onChanged: (String s) => _password = s,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            RaisedButton(
              onPressed: login,
              child: const Text('Login'),
            )
          ],
        ),
      ),
    );
  }
}
