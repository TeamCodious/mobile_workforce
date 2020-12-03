import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_workforce/pages/home_page.dart';
import 'package:mobile_workforce/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences pref = await SharedPreferences.getInstance();
  String token = pref.getString('tokenId');
  runApp(MainFrame(
    token: token,
  ));
}

class MainFrame extends HookWidget {
  final token;
  MainFrame({this.token});
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
      home: token == null ? LoginPage() : HomePage(),
    );
  }
}
