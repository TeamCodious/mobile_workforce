import 'dart:developer';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart';
import 'package:mobile_workforce/global.dart';
import 'package:mobile_workforce/models.dart';
import 'package:mobile_workforce/components/activity_card.dart';
import 'package:mobile_workforce/pages/login_page.dart';
import 'package:mobile_workforce/state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../global.dart';
import '../state.dart';
import 'settings_page.dart';
import 'package:intl/intl.dart';
import '../components/timeline.dart';

class EmployeeDetailPage extends HookWidget {
  final String id;
  EmployeeDetailPage({Key key, this.id}) : super(key: key);

  loadUser() async {
    String url1 = Uri.encodeFull(Global.URL + 'employees/' + id);

    Response res1 = await get(url1, headers: Global.HEADERS);
    User user = User.fromJSON(res1.body);

    String url2 =
        Uri.encodeFull(Global.URL + 'employees/' + id + '/tasks?type=all');
    Response res2 = await get(url2, headers: Global.HEADERS);
    List<Task> tasks = Task.fromJSONArray(res2.body);
    String ongoingTasks =
        tasks.where((t) => t.taskState == 'Ongoing').length.toString();
    String plannedTasks =
        tasks.where((t) => t.taskState == 'Planned').length.toString();
    String completedTasks =
        tasks.where((t) => t.taskState == 'Completed').length.toString();

    // String url3 = Uri.encodeFull(Global.URL +
    //     'employees/' +
    //     id +
    //     '/times');
    // Response res3 = await get(url3, headers: Global.HEADERS);
    // List<Time> times = Time.fromJSONArray(res3.body);
    // times.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    // charts.Series<dynamic, String> totalTime = new charts.Series<dynamic, String>(id: 'total_time', data: times, domainFn: (time, _) => '${DateFormat('d').format(DateTime.fromMillisecondsSinceEpoch(time.createdAt))}', measureFn: (time, _) => time.totalTime);
    // charts.Series<dynamic, String> totalBreak = new charts.Series<dynamic, String>(id: 'total_break', data: times, domainFn: (time, _) => '${DateFormat('d').format(DateTime.fromMillisecondsSinceEpoch(time.createdAt))}', measureFn: (time, _) => time.totalBreak);
    // List<charts.Series<dynamic, String>> seriesList = [totalBreak, totalTime];

    Map<String, dynamic> data = {
      'user': user,
      'ongoingTasks': ongoingTasks,
      'plannedTasks': plannedTasks,
      'completedTasks': completedTasks,
      'tasks': tasks.length.toString(),
      // 'times': times,
      // 'seriesList': seriesList,
    };
    return data;
  }

  @override
  Widget build(BuildContext context) {
    logout() async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.remove('token');
      pref.remove(Global.NOTI_KEY);
      CurrentUserId.update('', '');
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
            id == CurrentUserId.id ? Text('Profile') : Text('Employee Detail'),
      ),
      body: FutureBuilder(
        future: loadUser(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Scaffold(
              body: Center(
                child: Text('Error'),
              ),
            );
          } else if (!snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            loadActivities() async {
              String url = Uri.encodeFull(Global.URL +
                  'employees/' +
                  snapshot.data['user'].id +
                  '/activities');
              return get(url, headers: Global.HEADERS);
            }
            return SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 20),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Container(
                              color: Colors.red,
                              width: 80,
                              height: 80,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data['user'].username,
                                style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .fontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  snapshot.data['user'].role,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              Text('ABC Company Limited'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    id == CurrentUserId.id
                    ? SettingsPage() : Container(),
                    id == CurrentUserId.id
                    ? Container(
                        margin: EdgeInsets.all(5),
                        width: double.maxFinite,
                        child: RaisedButton(
                          onPressed: logout,
                          child: Text('Logout'),
                        ),
                      )
                    : Container(),
                    Container(
                      width: double.maxFinite,
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: Text(
                                  'Contacts',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                  'Email',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  snapshot.data['user'].email,
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                  'Phone',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  snapshot.data['user'].phoneNumber,
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: Text(
                                  'Tasks status',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Column(
                                            children: [
                                              Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 10),
                                                child: Text(
                                                  snapshot.data['plannedTasks'],
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'Planned',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Column(
                                            children: [
                                              Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 10),
                                                child: Text(
                                                  snapshot.data['ongoingTasks'],
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'Ongoing',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Column(
                                            children: [
                                              Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 10),
                                                child: Text(
                                                  snapshot
                                                      .data['completedTasks'],
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Text(
                                                'Completed',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: Text(
                                  'Work status',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total tasks',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      snapshot.data['tasks'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Container(
                              //   margin: EdgeInsets.only(bottom: 10),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Text(
                              //         'Total work hours',
                              //         style: TextStyle(
                              //           fontWeight: FontWeight.bold,
                              //           fontSize: 15,
                              //         ),
                              //       ),
                              //       Text(
                              //         '230',
                              //         style: TextStyle(
                              //           fontWeight: FontWeight.bold,
                              //           fontSize: 15,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TimeLine(id: id),
                    // Container(
                    //   width: double.maxFinite,
                    //   child: Card( 
                    //       child: Padding(  
                    //         padding: EdgeInsets.all(5),
                    //         child: Column(  
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Padding(
                    //             padding: EdgeInsets.symmetric(vertical: 15),
                    //             child: Text(
                    //               'Timeline',
                    //               style: TextStyle(
                    //                 fontSize: 20,
                    //                 fontWeight: FontWeight.bold,
                    //               ),
                    //             ),
                    //           ),
                    //           Container(
                    //             padding: EdgeInsets.only(bottom: 15),
                    //             height: 250,
                    //             child: charts.BarChart(  
                    //               snapshot.data['seriesList'],
                    //               animate: false,
                    //               barGroupingType: charts.BarGroupingType.stacked,
                    //             ),
                    //           )
                    //         ],
                    //       ),
                    //       )
                    //     ),
                    // ),
                    Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: ExpandablePanel(
                            header: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Activities',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            expanded: FutureBuilder(
                              future: loadActivities(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasError) {
                                  print(snapshot.error);
                                  return Scaffold(
                                    body: Center(
                                      child: Text('Error'),
                                    ),
                                  );
                                } else if (!snapshot.hasData) {
                                  return Scaffold(
                                    body: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                } else {
                                  List<Activity> activities =
                                      Activity.fromJSONArray(
                                          snapshot.data.body);
                                  activities.sort((a, b) => b.createdTime.compareTo(a.createdTime));
                                  return Column(
                                    children: activities
                                        .map((a) => ActivityCard(
                                              title: a.title,
                                              taskId: a.taskId,
                                              employeeId: a.creatorId,
                                              createdTime: a.createdTime,
                                              type: 'employee',
                                            ))
                                        .toList(),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
