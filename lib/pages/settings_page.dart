import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/pages/login_page.dart';
import 'package:mobile_workforce/state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import '../global.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import '../state.dart';
import 'package:uuid/uuid.dart';

class SettingsPage extends HookWidget {
  // Future<void> createActivity(String title) async {
  //     String url = Uri.encodeFull(Global.URL + '/activities/new');
  //     String body = '{"task": "", "employee": "${CurrentUserId.id}", "title": "$title"}';
  //     Response res = await put(url, headers: Global.HEADERS, body: body);
  //     if (res.statusCode == 201) {
  //       print('done');
  //     } else {
  //       print("$res");
  //     }
  // }
  @override
  Widget build(BuildContext context) {
    final workingState = useState(CurrentUserId.workingState);
    logout() async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.remove('token');
      CurrentUserId.update('', '');
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
      body: Builder(   
        builder: (context) {
          if (workingState.value == 'OFF' || workingState.value == 'BREAK') {
            return Container(  
              margin: EdgeInsets.all(5),
              height: 40,
              width: double.infinity,
              child: RaisedButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Are you sure to get to your work?"),
                        actions: [
                          FlatButton(onPressed: () {
                            Navigator.of(context).pop();
                          }, child: Text("Later")),
                          FlatButton(onPressed: () async {
                            startTracking();
                            Global.setWorking();
                            // createActivity("Started working on ${DateFormat('yyyy-MM-dd, kk:mm a').format(DateTime.now())}");
                            workingState.value = 'ON';
                            Navigator.of(context).pop();
                          }, child: Text("Sure"))
                        ],
                      );
                    }
                  );
                },
                child: Text("Start your work"),
              ),
            );
          } else {
            return Column(
              children: [
                Container(  
                  margin: EdgeInsets.all(5),
                  height: 40,
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Are you sure to take a break for a while?"),
                            actions: [
                              FlatButton(onPressed: () {
                                Navigator.of(context).pop();
                              }, child: Text("Cancel")),
                              FlatButton(onPressed: () async {
                                final time = await showTimePicker(
                                  context: context, 
                                  initialTime: TimeOfDay.now(),
                                );
                                final now = new DateTime.now();
                                final dateTime = new DateTime(now.year, now.month, now.day, time.hour, time.minute);
                                final next30 = now.add(Duration(minutes: 30));
                                if (dateTime.isAfter(next30)) {
                                  Navigator.of(context).pop();
                                  await showDialog(  
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('You are not allowed to take a break longer than 30 minute.'),
                                        actions: [
                                          FlatButton(onPressed: () {
                                            Navigator.of(context).pop();
                                          }, child: Text("OK"))
                                        ],
                                      );
                                    }
                                  );
                                  return;
                                } else {
                                  SharedPreferences pref = await SharedPreferences.getInstance();
                                  String id = pref.getString(Global.TIME);
                                  print("[Minute]: ${dateTime.difference(now).inMinutes}");
                                  breakTime(id, dateTime.difference(now).inMinutes);
                                  Global.setBreak();
                                  // createActivity("Took a break for ${now.difference(dateTime).inHours} minutes.");
                                  stopTracking();
                                  workingState.value = 'BREAK';
                                  Navigator.of(context).pop();
                                  return;
                                }
                              }, child: Text("Sure"))
                            ],
                          );
                        }
                      );
                    },
                    child: Text("Take a break"),
                  ),
                ),
                Container(  
                  margin: EdgeInsets.all(5),
                  height: 40,
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Are you sure to get off your work?"),
                            actions: [
                              FlatButton(onPressed: () {
                                Navigator.of(context).pop();
                              }, child: Text("Later")),
                              FlatButton(onPressed: () async {
                                stop();
                                Global.setFinish();
                                // createActivity('Stopped working at ${DateTime.now().toString()}');
                                stopTracking();
                                workingState.value = 'OFF';
                                Navigator.of(context).pop();
                              }, child: Text("Sure"))
                            ],
                          );
                        }
                      );
                    },
                    child: Text("Stop your task"),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void stop() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String id = pref.getString(Global.TIME);
    String url = Uri.encodeFull(Global.URL + '/time/stop');
    String body = '{"id": "$id", "stop_time": ${DateTime.now().toUtc().millisecondsSinceEpoch}}';
    Response res = await patch(url, headers: Global.HEADERS, body: body);
    if (res.statusCode == 204) {
      print('done');
    } else {
      print("$res");
    }
    pref.remove(Global.TIME);
  }

  void breakTime(String id, int time) async {
    String url = Uri.encodeFull(Global.URL + '/time/break');
    String body = '{"id": "$id", "total_break": $time, "now": ${DateTime.now().toUtc().millisecondsSinceEpoch}}';
    Response res = await patch(url, headers: Global.HEADERS, body: body);
    if (res.statusCode == 204) {
      print('done');
    } else {
      print("$res");
    }
  }

  void stopTracking() async {
    final flag = await AndroidAlarmManager.cancel(Global.BACKGROUND_TASK_ID);
    if (flag) {
      print("[Info]: System stops tracking.");
    } else {
      print("[Error]: System is unable to stop tracking.");
    }
  }

  void createTime() async {
    final id = Uuid().v4();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Global.TIME, id);
    String url = Uri.encodeFull(Global.URL + '/time/new');
    String body = '{"id": "$id", "employee": "${CurrentUserId.id}", "start_time": ${DateTime.now().toUtc().millisecondsSinceEpoch}}';
    Response res = await put(url, headers: Global.HEADERS, body: body);
    if (res.statusCode == 201) {
      print('done');
    } else {
      print("$res");
    }
  }

  void startTracking() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String id = pref.getString(Global.TIME);
    if (id == null) {
      createTime();
    }
    final flag = await AndroidAlarmManager.initialize();
    if (flag) {
      print("[Info]: System starts tracking.");
    } else {
      print("[Error]: System is unable to start tracking.");
    }
    await AndroidAlarmManager.periodic(
        Duration(seconds: 5), Global.BACKGROUND_TASK_ID, callback);
  }

  static Future<void> callback() async {
    print("Alarm fired");
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    bool result = await isInternet();
    print(position);
    if (result == true) {
      await save(position);
    } else {
      await SQLite.insertPosition(position);
    }
    //debug
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'location_update',
        'Location Updates',
        'You will receive location updates here',
        importance: Importance.max,
        priority: Priority.high);
    var platformChannelSpecifics =
        new NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'PUT success $result',
        "${position.longitude} ${position.latitude}", platformChannelSpecifics);
  }

  static Future<void> save(Position position) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String userID = pref.getString(Global.USER_ID_KEY) ?? '';
    if (userID == '') {
      await AndroidAlarmManager.cancel(Global.BACKGROUND_TASK_ID);
      return;
    }
    String url = Uri.encodeFull(Global.URL + 'locations/new');

    String body =
        '{"time": ${DateTime.now().toUtc().millisecondsSinceEpoch}, "latitude": ${position.latitude}, "longitude": ${position.longitude}, "employee": "$userID"}';
    print(body);
    print(CurrentUserId.id);
    try {
      Response response = await put(url, headers: Global.HEADERS, body: body);
      if (response.statusCode != 201) {
        throw "Error: $response";
      }
    } catch (err) {
      print(err);
      await SQLite.insertPosition(position);
    }
  }
}
