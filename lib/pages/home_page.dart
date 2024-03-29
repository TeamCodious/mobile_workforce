import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/global.dart';
import 'package:mobile_workforce/pages/employee_detail_page.dart';
import 'package:mobile_workforce/pages/employees_page.dart';
import 'package:mobile_workforce/pages/map_page.dart';
import 'package:mobile_workforce/pages/messages_page.dart';
import 'package:mobile_workforce/pages/reportsPage.dart';
import 'package:mobile_workforce/pages/tasks_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:badges/badges.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notificaitons_page.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:android_alarm_manager/android_alarm_manager.dart';
// import '../global.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart';
import '../state.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends HookWidget {
  final _tabs = <String>['Tasks', 'Map', 'Messages', 'Reports', 'Employees'];

  @override
  Widget build(BuildContext context) {
    final tabIndex = useState(0);
    final tabController = useTabController(initialLength: 5);
    FirebaseMessaging messaging = FirebaseMessaging();
    final hasNoti = useState(false);

    _getNoti() async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      hasNoti.value = pref.getBool(Global.NOTI_KEY) ?? false;
    }

    _setFalse() async {
      hasNoti.value = false;
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setBool(Global.NOTI_KEY, false);
    }

    useEffect(() {
      _getNoti();
      messaging.configure(onMessage: (Map<String, dynamic> message) async {
        print("[Info]: Notification is received while app is on foreground.");
        hasNoti.value = true;
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setBool(Global.NOTI_KEY, true);
      }, onResume: (message) async {
        print("[Info]: Notification is received.");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => NotificaitonPage()));
      }, onLaunch: (message) async {
        print("[Info]: Notification is received while app is on launch.");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => NotificaitonPage()));
      });
      return () {};
    }, []);

    // useEffect(() {
    //   // WARNING:
    //   // This function will be run at the background even if app is terminated. After testing this function, don't forget to uninstall the app.
    //   // startTracking();
    //   return () {};
    // }, []);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_tabs[tabIndex.value]),
        leading: Tooltip(
          message: 'Profile',
          child: ActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => EmployeeDetailPage(
                            id: CurrentUserId.id,
                          )));
            },
            icon: Icon(Icons.person),
          ),
        ),
        actions: [
          Badge(
            position: BadgePosition.topEnd(top: 10, end: 10),
            badgeContent: null,
            showBadge: hasNoti.value,
            child: Tooltip(
              message: 'Notifications',
              child: ActionButton(
                onPressed: () {
                  _setFalse();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              NotificaitonPage()));
                },
                icon: Icon(Icons.notifications),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        color: Theme.of(context).colorScheme.primary,
        child: TabBar(
          controller: tabController,
          onTap: (index) {
            tabIndex.value = index;
          },
          tabs: [
            Tab(
              child: tabIndex.value == 0
                  ? Icon(Icons.fact_check)
                  : Icon(Icons.fact_check_outlined),
            ),
            Tab(
              child: tabIndex.value == 1
                  ? Icon(Icons.map)
                  : Icon(Icons.map_outlined),
            ),
            Tab(
              child: tabIndex.value == 2
                  ? Icon(Icons.sms)
                  : Icon(Icons.sms_outlined),
            ),
            Tab(
              child: tabIndex.value == 3
                  ? Icon(Icons.report)
                  : Icon(Icons.report_outlined),
            ),
            Tab(
              child: tabIndex.value == 4
                  ? Icon(Icons.people)
                  : Icon(Icons.people_outline),
            ),
          ],
        ),
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          TasksPage(),
          MapPage(),
          MessagesPage(),
          ReportsPage(),
          EmployeesPage(),
        ],
      ),
    );
  }

  // void startTracking() async {
  //   await AndroidAlarmManager.periodic(
  //       Duration(seconds: 5), Global.BACKGROUND_TASK_ID, callback);
  // }

  // static Future<void> callback() async {
  //   print("Alarm fired");
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   bool result = await isInternet();
  //   print(position);
  //   // WARNING:
  //   // This function will be run at the background even if app is terminated. After testing this function, don't forget to uninstall the app.
  //   if (result == true) {
  //     // await save(position);
  //   } else {
  //     // await SQLite.insertPosition(position);
  //   }
  //   //debug
  //   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //       new FlutterLocalNotificationsPlugin();
  //   var initializationSettingsAndroid =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');
  //   var initializationSettings =
  //       InitializationSettings(android: initializationSettingsAndroid);
  //   flutterLocalNotificationsPlugin.initialize(initializationSettings);

  //   var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
  //       'location_update',
  //       'Location Updates',
  //       'You will receive location updates here',
  //       importance: Importance.max,
  //       priority: Priority.high);
  //   var platformChannelSpecifics =
  //       new NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.show(0, 'PUT success $result',
  //       "${position.longitude} ${position.latitude}", platformChannelSpecifics);
  // }

  // static Future<void> save(Position position) async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   String userID = pref.getString(Global.USER_ID_KEY) ?? '';
  //   if (userID == '') {
  //     await AndroidAlarmManager.cancel(Global.BACKGROUND_TASK_ID);
  //     return;
  //   }
  //   String url = Uri.encodeFull(Global.URL + 'locations/new');

  //   String body =
  //       '{"time": ${DateTime.now().toUtc().millisecondsSinceEpoch}, "latitude": ${position.latitude}, "longitude": ${position.longitude}, "employee": "$userID"}';
  //   print(body);
  //   print(CurrentUserId.id);
  //   try {
  //     Response response = await put(url, body: body);
  //     if (response.statusCode != 201) {
  //       throw "Error: $response";
  //     }
  //   } catch (err) {
  //     print(err);
  //     await SQLite.insertPosition(position);
  //   }
  // }
}
