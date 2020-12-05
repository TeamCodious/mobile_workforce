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
      CurrentUserId.update(data['id'], data['employee_role']);
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
      final locations = await SQLite.locations();
      SharedPreferences pref = await SharedPreferences.getInstance();
      String userID = pref.getString(Global.USER_ID_KEY) ?? '';
      if (userID == "") return;

      for (var location in locations) {
        String url = Uri.encodeFull(
          'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/locations/new');
        String body =
          '{"time": ${location.time}, "latitude": ${location.latitude}, "longitude": ${location.longitude}, "employee": "$userID"}';
        try {
          Response response = await put(url, body: body);
          if (response.statusCode == 201) {
            await SQLite.deleteLocation(location.id);
            print(body);
          } else {
            throw "Error: $response";
          }
        } catch (err) {
          print(err);
        }
      }
      print("Length: ${locations.length}");
    }
    useEffect(() {
      check();
      return () {};
    });
    useEffect(() {
      subscription = Connectivity().onConnectivityChanged.listen((event) async {
        if (event == ConnectivityResult.none) {
          print('Offline');
          isOnline.value = false;
        } else if (event == ConnectivityResult.mobile || event == ConnectivityResult.wifi) {
          print('Online');
          if (!isOnline.value) {
            isOnline.value = true;
            hasBackups.value = await SQLite.hasBackUps();
            await uploadBackups();
            hasBackups.value = false;
          }
        } else {
          print('Offline');
          isOnline.value = false;
        }
      });
      return () {};
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: customColor),
      home: FutureBuilder(
        future: isLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (isOnline.value) {
            if (hasBackups.value) {

              return Scaffold(
                body: Center(child: Text("Uploading your backups."),),
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
