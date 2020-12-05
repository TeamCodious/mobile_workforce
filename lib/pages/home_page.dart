import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/models.dart';
import 'package:mobile_workforce/pages/map_page.dart';
import 'package:mobile_workforce/pages/messages_page.dart';
import 'package:mobile_workforce/pages/settings_page.dart';
import 'package:mobile_workforce/pages/tasks_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import '../global.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends HookWidget {
  final _tabs = <String>['Tasks', 'Map', 'Messages', 'Reports', 'Employees'];

  @override
  Widget build(BuildContext context) {
    final tabIndex = useState(0);
    final tabController = useTabController(initialLength: 5);

    useEffect(() {
      startTracking();
      return () {};
    }, []);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_tabs[tabIndex.value]),
        leading: Tooltip(
          message: 'Profile',
          child: ActionButton(
            onPressed: () {},
            icon: Icon(Icons.person),
          ),
        ),
        actions: [
          Tooltip(
            message: 'Settings',
            child: ActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => SettingsPage()));
              },
              icon: Icon(Icons.settings),
            ),
          ),
          Tooltip( //For debug
            message: 'See backups',
            child: ActionButton(
              onPressed: () async {
                final locations = await SQLite.locations();
                print(locations.length);
                locations.forEach((element) {
                  print('${element.id} ${element.latitude} ${element.longitude} ${DateTime.fromMillisecondsSinceEpoch(element.time)}');
                });
              },
              icon: Icon(Icons.list),
            ),
          ),

          Tooltip( //For debug
            message: 'See backups',
            child: ActionButton(
              onPressed: () async {
                AndroidAlarmManager.cancel(Global.BACKGROUND_TASK_ID);
              },
              icon: Icon(Icons.stop),
            ),
          )
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
                  ? Icon(Icons.notifications)
                  : Icon(Icons.notifications_outlined),
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
          Center(
            child: const Text('Notifications'),
          ),
          Center(
            child: const Text('Employees'),
          ),
        ],
      ),
    );
  }

  void startTracking() async {
    await AndroidAlarmManager.periodic(Duration(seconds: 5), Global.BACKGROUND_TASK_ID, callback);
  }

  static Future<void> callback() async {
    print("Alarm fired");
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    bool result = await isInternet();
    print(position);
    if(result == true) {
      // create location at server!
      print('YAY! Fire!');
    } else {
      await SQLite.insertPosition(position);
    }

    //For debugging
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'location_update', 'Location Updates', 'You will receive location updates here',
        importance: Importance.max, priority: Priority.high);
    var platformChannelSpecifics = new NotificationDetails(android: androidPlatformChannelSpecifics);
    DateTime dateTime = new DateTime.now();
    await flutterLocalNotificationsPlugin.show(
        0, 'New Location Received !', "${dateTime.toString()} ${position.longitude} ${position.latitude}", platformChannelSpecifics);
  }
}
