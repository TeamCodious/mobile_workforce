import 'dart:convert';
import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart';
import 'package:mobile_workforce/global.dart';
import 'package:mobile_workforce/pages/home_page.dart';
import 'package:mobile_workforce/pages/login_page.dart';
import 'package:mobile_workforce/state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:connectivity/connectivity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AndroidAlarmManager.initialize();
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
  StreamSubscription<ConnectivityResult> subscription;
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
    final isOnline = useState(false);
    final hasBackups = useState(false);
    void check() async {
      PermissionStatus permission = await LocationPermissions().checkPermissionStatus();
      if (permission == PermissionStatus.denied) {
        PermissionStatus permission = await LocationPermissions().requestPermissions();
        if (permission == PermissionStatus.denied) {
          SystemNavigator.pop();
        }
      }
    }
    Future<void> uploadBackups() async {
      final locations = SQLite.locations();
      // try catch
      // send all backups to server, uploading fails, don't delete.
      SQLite.deleteBackups();
    }
    useEffect(() {
      check();
      return () {};
    });
    useEffect(() {
      subscription = Connectivity().onConnectivityChanged.listen((event) async {
        if (event == ConnectivityResult.none) {
          isOnline.value = false;
        } else if (event == ConnectivityResult.mobile || event == ConnectivityResult.wifi) {
          if (!isOnline.value) {
            hasBackups.value = await SQLite.hasBackUps();
            await uploadBackups();
            hasBackups.value = false;
          }
          isOnline.value = true;
        } else {
          isOnline.value = false;
        }
      });
      return () {};
    }, []);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: customColor),
      home: FutureBuilder(
        future: isLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (isOnline.value) {
            if (hasBackups.value) {

              return Scaffold(
                body: Center(child: Text("Has backups."),),
              );
            }
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
          } else {
            return Scaffold(
              body: Center(child: Text("Going Offline."),),
            );
          }
        },
      ),
    );
  }
}
