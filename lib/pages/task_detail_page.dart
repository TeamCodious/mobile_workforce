import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/components/employee_card.dart';
import 'package:mobile_workforce/models.dart';
import 'package:mobile_workforce/state.dart';

class TaskDetailPage extends HookWidget {
  final taskId;
  final mapController = Completer<GoogleMapController>();

  TaskDetailPage({Key key, this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final coordinate = LatLng(16.8409, 96.1735);

    loadTask() async {
      String url = Uri.encodeFull(
          'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/tasks/' +
              taskId);
      return get(url);
    }

    return Scaffold(
      bottomSheet: Container(
        margin: EdgeInsets.all(5),
        height: 40,
        width: double.infinity,
        child: RaisedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text('Report'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RaisedButton(
                      onPressed: () {},
                      child: Text('Default report'),
                    ),
                    RaisedButton(
                      onPressed: () {},
                      child: Text('Custom report'),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Text('Report'),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Task Detail'),
        actions: [
          Tooltip(
              message: 'Chat about this task',
              child: ActionButton(icon: Icon(Icons.message), onPressed: () {})),
        ],
      ),
      body: FutureBuilder(
          future: loadTask(),
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
              Task task = Task.fromJSON(snapshot.data.body);
              final startTime =
                  DateTime.fromMillisecondsSinceEpoch(task.startTime);
              final formattedStartTime =
                  '${DateFormat.yMMMMd('en_US').format(startTime)} ${DateFormat('jm').format(startTime)}';
              final dueTime = DateTime.fromMillisecondsSinceEpoch(task.dueTime);
              final formattedDueTime =
                  '${DateFormat.yMMMMd('en_US').format(dueTime)} ${DateFormat('jm').format(dueTime)}';
              String duration;
              if (task.taskState == 'Completed') {
                final pTime =
                    DateTime.now().millisecondsSinceEpoch - task.dueTime;
                if (pTime >= 31556952000) {
                  duration = 'ended ' +
                      (pTime ~/ 31556952000).toString() +
                      ' years ago';
                } else if (pTime >= 2592000000) {
                  duration = 'ended ' +
                      (pTime ~/ 2592000000).toString() +
                      ' months ago';
                } else if (pTime >= 86400000) {
                  duration =
                      'ended ' + (pTime ~/ 86400000).toString() + ' days ago';
                } else if (pTime >= 3600000) {
                  duration =
                      'ended ' + (pTime ~/ 3600000).toString() + ' hours ago';
                } else if (pTime >= 3600000) {
                  duration =
                      'ended ' + (pTime ~/ 60000).toString() + ' min ago';
                } else {
                  duration = 'ended just now';
                }
              } else if (task.taskState == 'Ongoing') {
                final pTime =
                    task.dueTime - DateTime.now().millisecondsSinceEpoch;
                if (pTime >= 31556952000) {
                  duration =
                      (pTime ~/ 31556952000).toString() + ' years remaining';
                } else if (pTime >= 2592000000) {
                  duration =
                      (pTime ~/ 2592000000).toString() + ' months remaining';
                } else if (pTime >= 86400000) {
                  duration = (pTime ~/ 86400000).toString() + ' days remaining';
                } else if (pTime >= 3600000) {
                  duration = (pTime ~/ 3600000).toString() + ' hours remaining';
                } else if (pTime >= 3600000) {
                  duration = (pTime ~/ 60000).toString() + ' min remaining';
                } else {
                  duration = 'a few seconds remaining';
                }
              } else if (task.taskState == 'Planned') {
                final pTime =
                    task.startTime - DateTime.now().millisecondsSinceEpoch;
                if (pTime >= 31556952000) {
                  duration = 'begin in ' +
                      (pTime ~/ 31556952000).toString() +
                      ' years';
                } else if (pTime >= 2592000000) {
                  duration = 'begin in ' +
                      (pTime ~/ 2592000000).toString() +
                      ' months';
                } else if (pTime >= 86400000) {
                  duration =
                      'begin in ' + (pTime ~/ 86400000).toString() + ' days';
                } else if (pTime >= 3600000) {
                  duration =
                      'begin in ' + (pTime ~/ 3600000).toString() + ' hours';
                } else if (pTime >= 3600000) {
                  duration = 'begin in ' + (pTime ~/ 60000).toString() + ' min';
                } else {
                  duration = 'begin in a few seconds';
                }
              }
              return Container(
                margin: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 50),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 50),
                      child: Text(
                        task.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            task.taskState,
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            duration,
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 15),
                      height: 80,
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        loadAdmins() async {
                                          String url = Uri.encodeFull(
                                              'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/tasks/' +
                                                  taskId +
                                                  '/employees?type=owners');
                                          return get(url);
                                        }

                                        return AlertDialog(
                                          title: Text(
                                            'Admins',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: FutureBuilder(
                                            future: loadAdmins(),
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
                                                return Container(
                                                  height: 50,
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                );
                                              } else {
                                                final List<User> admins =
                                                    User.fromJSONArray(
                                                        snapshot.data.body);

                                                return SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: admins
                                                        .map(
                                                          (a) => EmployeeCard(
                                                            name: a.id ==
                                                                    CurrentUserId
                                                                        .id
                                                                ? a.username +
                                                                    ' (You)'
                                                                : a.username,
                                                            role: a.role,
                                                            button: a.id ==
                                                                    CurrentUserId
                                                                        .id
                                                                ? null
                                                                : ActionButton(
                                                                    icon: Icon(Icons
                                                                        .message),
                                                                    onPressed:
                                                                        () {},
                                                                  ),
                                                          ),
                                                        )
                                                        .toList(),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        );
                                      });
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      task.adminIds.length.toString(),
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      'Admins',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        loadAssignees() async {
                                          String url = Uri.encodeFull(
                                              'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/tasks/' +
                                                  taskId +
                                                  '/employees?type=assignees');
                                          return get(url);
                                        }

                                        return AlertDialog(
                                          title: Text(
                                            'Assignees',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: FutureBuilder(
                                            future: loadAssignees(),
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
                                                return Container(
                                                  height: 50,
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                );
                                              } else {
                                                final List<User> assignees =
                                                    User.fromJSONArray(
                                                        snapshot.data.body);

                                                return SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: assignees
                                                        .map(
                                                          (a) => EmployeeCard(
                                                            name: a.id ==
                                                                    CurrentUserId
                                                                        .id
                                                                ? a.username +
                                                                    ' (You)'
                                                                : a.username,
                                                            role: a.role,
                                                            button: a.id ==
                                                                    CurrentUserId
                                                                        .id
                                                                ? null
                                                                : ActionButton(
                                                                    icon: Icon(Icons
                                                                        .message),
                                                                    onPressed:
                                                                        () {},
                                                                  ),
                                                          ),
                                                        )
                                                        .toList(),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        );
                                      });
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      task.assigneeIds.length.toString(),
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      'Assignees',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: ExpandablePanel(
                            header: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Time',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            expanded: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 5),
                                  child: Text(
                                    'Start time',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    formattedStartTime,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    'Due time',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    formattedDueTime,
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
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: ExpandablePanel(
                            header: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            expanded: Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                task.description,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: ExpandablePanel(
                            header: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            expanded: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    'Junction 8, 8 miles, Kyaik Waing Pagoda Rd, Yangon',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 140,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: EdgeInsets.all(10),
                                  child: GoogleMap(
                                    onMapCreated: (controller) =>
                                        mapController.complete(controller),
                                    mapType: MapType.normal,
                                    initialCameraPosition: CameraPosition(
                                      target: coordinate,
                                      zoom: 15,
                                    ),
                                    markers: List.of([
                                      Marker(
                                        markerId: MarkerId(
                                          coordinate.toString(),
                                        ),
                                        position: coordinate,
                                      )
                                    ]).toSet(),
                                    scrollGesturesEnabled: false,
                                    zoomGesturesEnabled: false,
                                    rotateGesturesEnabled: false,
                                    tiltGesturesEnabled: false,
                                    zoomControlsEnabled: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
                            expanded: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'John created this task',
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '5 min ago',
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}
