import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart';
import 'package:mobile_workforce/pages/home_page.dart';
import 'package:mobile_workforce/pages/login_page.dart';
import 'package:mobile_workforce/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainFrame());
}

class MainFrame extends HookWidget {
  Future<String> isLoggedIn() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString('token') ?? '';
    if (token != '') {
      String url = Uri.encodeFull(
          'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/me/');
      Map<String, String> headers = {'tokenKey': token};
      Response response = await get(url, headers: headers);
      Map<String, dynamic> data = jsonDecode(response.body);

      CurrentUserId.update(data['id']);
    }
    return token;
  }

  @override
  Widget build(BuildContext context) {
    Map<int, Color> colorCodes = {
      50: Color.fromRGBO(27, 71, 131, .1),
      100: Color.fromRGBO(27, 71, 131, .2),
      200: Color.fromRGBO(27, 71, 131, .3),
      300: Color.fromRGBO(27, 71, 131, .4),
      400: Color.fromRGBO(27, 71, 131, .5),
      500: Color.fromRGBO(27, 71, 131, .6),
      600: Color.fromRGBO(27, 71, 131, .7),
      700: Color.fromRGBO(27, 71, 131, .8),
      800: Color.fromRGBO(27, 71, 131, .9),
      900: Color.fromRGBO(27, 71, 131, 1),
    };
    MaterialColor customColor = MaterialColor(0xFF1b4783, colorCodes);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: customColor),
      home: FutureBuilder(
        future: isLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            if (snapshot.data == '') {
              return LoginPage();
            } else {
              return HomePage();
            }
          }
        },
      ),
    );
  }
}
