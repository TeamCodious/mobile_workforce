import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/components/employee_card.dart';
import 'package:mobile_workforce/global.dart';
import 'package:mobile_workforce/models.dart';
import 'package:mobile_workforce/pages/coordinate_picker.dart';
import 'package:mobile_workforce/pages/home_page.dart';
import 'package:mobile_workforce/state.dart';

class CreateTaskPage extends HookWidget {
  final mapController = Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final startDateTimeInputController = useTextEditingController();
    final dueDateTimeInputController = useTextEditingController();
    final locationNameController = useTextEditingController();
    final startDate = useState(DateTime.now());
    final dueDate = useState(DateTime.now());
    final coordinate = useState(LatLng(16.8409, 96.1735));
    final isSaving = useState(false);

    final adminIds = useState([CurrentUserId.id]);
    final adminRefresh = useState(false);
    final assigneeRefresh = useState(false);
    final leaderRefresh = useState(false);
    final assigneeIds = useState([]);
    final leaderId = useState("");

    Future<void> showDateTimePicker(ValueNotifier<DateTime> date) async {
      final selectedDate = await showDatePicker(
        context: context,
        initialDate: date.value,
        firstDate: DateTime(2020),
        lastDate: DateTime(2040),
      );
      if (selectedDate != null) {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (selectedTime != null) {
          date.value = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        }
      }
    }

    Future<void> updateCoordinate(LatLng newCoordinate) async {
      coordinate.value = newCoordinate;
      final controller = await mapController.future;
      await controller.animateCamera(CameraUpdate.newLatLng(newCoordinate));
    }

    Future<void> showCoordinatePicker() async {
      final newCoordinate = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  CoordinatePicker(coordinate.value)));
      if (newCoordinate != null) {
        await updateCoordinate(newCoordinate);
      }
    }

    bool _validate() {
      return titleController.text.isNotEmpty &&
          descriptionController.text.isNotEmpty;
    }

    String formattedAdminString =
        adminIds.value.map((e) => '"' + e + '"').toList().toString();

    String formattedAssigneeString =
        assigneeIds.value.map((e) => '"' + e + '"').toList().toString();

    _save() async {
      String url =
          Uri.encodeFull(Global.URL + 'tasks/new?creator=' + CurrentUserId.id);

      String body =
          '{"title": "${titleController.text}", "description": "${descriptionController.text}", "assignees": $formattedAssigneeString, "owners": $formattedAdminString, "task_state": "Planned", "start_time": ${startDate.value.millisecondsSinceEpoch}, "due_time": ${dueDate.value.millisecondsSinceEpoch}, "manager": "${leaderId.value}", "latitude": ${coordinate.value.latitude}, "longitude": ${coordinate.value.longitude}, "location": "${locationNameController.text}", "actual_start_time": 0, "actual_finish_time": 0}';
      print(body);

      Response response = await put(url, headers: Global.HEADERS, body: body);
      if (response.statusCode == 201) {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => HomePage()));
      } else {
        Navigator.pop(context);
      }
    }

    loadAddedAdmins() async {
      String url = Uri.encodeFull(Global.URL + 'employees');

      String body = '{"employees": ${formattedAdminString.toString()}}';
      return post(url, headers: Global.HEADERS, body: body);
    }

    loadLeader() async {
      String url = Uri.encodeFull(Global.URL + 'employees/' + leaderId.value);
      return get(url, headers: Global.HEADERS);
    }

    loadAddedAssignees() async {
      String url = Uri.encodeFull(Global.URL + 'employees');

      String body = '{"employees": ${formattedAssigneeString.toString()}}';
      return post(url, headers: Global.HEADERS, body: body);
    }

    useEffect(() {
      startDateTimeInputController.text =
          '${DateFormat.yMMMMd('en_US').format(startDate.value)} ${DateFormat('jm').format(startDate.value)}';
      return () {};
    }, [startDate.value]);

    useEffect(() {
      dueDateTimeInputController.text =
          '${DateFormat.yMMMMd('en_US').format(dueDate.value)} ${DateFormat('jm').format(dueDate.value)}';
      return () {};
    }, [dueDate.value]);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Create Task'),
      ),
      bottomSheet: Container(
        margin: EdgeInsets.all(5),
        height: 40,
        width: double.infinity,
        child: RaisedButton(
          onPressed: () {
            if (_validate()) {
              isSaving.value = true;
              _save();
            }
          },
          child: Text('Save'),
        ),
      ),
      body: isSaving.value
          ? Center(
              child: Text('Saving...'),
            )
          : SingleChildScrollView(
              child: Container(
                margin:
                    EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 40),
                child: Column(
                  children: [
                    TextFormField(
                      autocorrect: false,
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                    TextFormField(
                      autocorrect: false,
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    TextFormField(
                      readOnly: true,
                      autocorrect: false,
                      controller: startDateTimeInputController,
                      decoration: InputDecoration(
                        labelText: 'Start time',
                      ),
                      onTap: () async {
                        await showDateTimePicker(startDate);
                      },
                    ),
                    TextFormField(
                      readOnly: true,
                      autocorrect: false,
                      controller: dueDateTimeInputController,
                      decoration: InputDecoration(
                        labelText: 'Due time',
                      ),
                      onTap: () async {
                        await showDateTimePicker(dueDate);
                      },
                    ),
                    TextFormField(
                      // readOnly: true,
                      autocorrect: false,
                      controller: locationNameController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                      ),
                    ),
                    Container(
                      height: 140,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: GoogleMap(
                        onMapCreated: (controller) =>
                            mapController.complete(controller),
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: coordinate.value,
                          zoom: 15,
                        ),
                        markers: List.of([
                          Marker(
                            markerId: MarkerId(
                              coordinate.value.toString(),
                            ),
                            position: coordinate.value,
                          )
                        ]).toSet(),
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        zoomControlsEnabled: false,
                        onTap: (_) async {
                          await showCoordinatePicker();
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Admins',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        ActionButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              loadManagers() async {
                                String url = Uri.encodeFull(
                                    Global.URL + 'employees?type=managers');
                                return get(url, headers: Global.HEADERS);
                              }

                              showDialog(
                                  context: context,
                                  builder:
                                      (BuildContext context) => AlertDialog(
                                            title: Text(
                                              'Add admins',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            content: StatefulBuilder(
                                              builder: (context, setState) =>
                                                  FutureBuilder(
                                                      future: loadManagers(),
                                                      builder:
                                                          (BuildContext context,
                                                              AsyncSnapshot
                                                                  snapshot) {
                                                        if (snapshot.hasError) {
                                                          print(snapshot.error);
                                                          return Scaffold(
                                                            body: Center(
                                                              child:
                                                                  Text('Error'),
                                                            ),
                                                          );
                                                        } else if (!snapshot
                                                            .hasData) {
                                                          return Scaffold(
                                                            body: Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            ),
                                                          );
                                                        } else {
                                                          final List<
                                                              User> users = User
                                                                  .fromJSONArray(
                                                                      snapshot
                                                                          .data
                                                                          .body)
                                                              .where((u) =>
                                                                  !adminIds
                                                                      .value
                                                                      .contains(
                                                                          u.id))
                                                              .toList();
                                                          if (users.length >
                                                              0) {
                                                            return Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: users
                                                                  .map((u) =>
                                                                      EmployeeCard(
                                                                        name: u
                                                                            .username,
                                                                        role: u
                                                                            .role,
                                                                        button:
                                                                            ActionButton(
                                                                          icon:
                                                                              Icon(Icons.add),
                                                                          onPressed:
                                                                              () {
                                                                            adminIds.value.add(u.id);
                                                                            setState(() {
                                                                              users.remove(users.where((uu) => u.id == uu.id));
                                                                            });
                                                                            adminRefresh.value =
                                                                                true;
                                                                          },
                                                                        ),
                                                                      ))
                                                                  .toList(),
                                                            );
                                                          } else {
                                                            return Container(
                                                              child: Text(
                                                                'No more managers',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      }),
                                            ),
                                          ));
                            }),
                      ],
                    ),
                    StatefulBuilder(
                      builder: (context, setState) => FutureBuilder(
                          future: loadAddedAdmins(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (adminRefresh.value) {
                                setState(() {
                                  adminRefresh.value = false;
                                });
                              }
                            });

                            if (snapshot.hasError) {
                              print(snapshot.error);
                              return Center(
                                child: Text('Error'),
                              );
                            } else if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              List<User> admins =
                                  User.fromJSONArray(snapshot.data.body);

                              return Column(
                                children: admins
                                    .map((a) => EmployeeCard(
                                          name: a.id == CurrentUserId.id
                                              ? a.username + ' (You)'
                                              : a.username,
                                          role: a.role,
                                          button: a.id == CurrentUserId.id
                                              ? null
                                              : ActionButton(
                                                  icon: Icon(Icons.remove),
                                                  onPressed: () {
                                                    adminIds.value.remove(a.id);
                                                    adminRefresh.value = true;
                                                    setState(() {
                                                      admins.remove(
                                                          admins.where((aa) =>
                                                              aa.id == a.id));
                                                    });
                                                  },
                                                ),
                                        ))
                                    .toList(),
                              );
                            }
                          }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Leader',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        leaderId.value == ""
                            ? ActionButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  loadAssignees() async {
                                    String url = Uri.encodeFull(Global.URL +
                                        'employees?type=employees');
                                    return get(url, headers: Global.HEADERS);
                                  }

                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                            title: Text(
                                              'Choose leader',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            content: StatefulBuilder(
                                              builder: (context, setState) =>
                                                  FutureBuilder(
                                                      future: loadAssignees(),
                                                      builder:
                                                          (BuildContext context,
                                                              AsyncSnapshot
                                                                  snapshot) {
                                                        if (snapshot.hasError) {
                                                          print(snapshot.error);
                                                          return Scaffold(
                                                            body: Center(
                                                              child:
                                                                  Text('Error'),
                                                            ),
                                                          );
                                                        } else if (!snapshot
                                                            .hasData) {
                                                          return Scaffold(
                                                            body: Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            ),
                                                          );
                                                        } else {
                                                          final List<User>
                                                              users =
                                                              User.fromJSONArray(
                                                                  snapshot.data
                                                                      .body);
                                                          if (users.length >
                                                              0) {
                                                            return Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: users
                                                                  .map((u) =>
                                                                      EmployeeCard(
                                                                        name: u
                                                                            .username,
                                                                        role: u
                                                                            .role,
                                                                        button:
                                                                            ActionButton(
                                                                          icon:
                                                                              Icon(Icons.add),
                                                                          onPressed:
                                                                              () {
                                                                            leaderId.value =
                                                                                u.id;
                                                                            leaderRefresh.value =
                                                                                true;
                                                                            Navigator.pop(context);
                                                                          },
                                                                        ),
                                                                      ))
                                                                  .toList(),
                                                            );
                                                          } else {
                                                            return Container(
                                                              child: Text(
                                                                'No more employees',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      }),
                                            ),
                                          ));
                                })
                            : Container(
                                height: 50,
                              ),
                      ],
                    ),
                    leaderId.value == ""
                        ? Container()
                        : StatefulBuilder(
                            builder: (context, setState) => FutureBuilder(
                                future: loadLeader(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (leaderRefresh.value) {
                                      setState(() {
                                        leaderRefresh.value = false;
                                      });
                                    }
                                  });

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
                                    User leader =
                                        User.fromJSON(snapshot.data.body);
                                    print('hi');
                                    print(leader.username);
                                    return EmployeeCard(
                                      name: leader.username,
                                      role: leader.role,
                                      button: ActionButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            leaderId.value = "";
                                          });
                                        },
                                      ),
                                    );

                                    // return Container();
                                  }
                                }),
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Assignees',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        ActionButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              loadAssignees() async {
                                String url = Uri.encodeFull(
                                    Global.URL + 'employees?type=employees');
                                return get(url, headers: Global.HEADERS);
                              }

                              showDialog(
                                  context: context,
                                  builder:
                                      (BuildContext context) => AlertDialog(
                                            title: Text(
                                              'Add assignees',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            content: StatefulBuilder(
                                              builder: (context, setState) =>
                                                  FutureBuilder(
                                                      future: loadAssignees(),
                                                      builder:
                                                          (BuildContext context,
                                                              AsyncSnapshot
                                                                  snapshot) {
                                                        if (snapshot.hasError) {
                                                          print(snapshot.error);
                                                          return Scaffold(
                                                            body: Center(
                                                              child:
                                                                  Text('Error'),
                                                            ),
                                                          );
                                                        } else if (!snapshot
                                                            .hasData) {
                                                          return Scaffold(
                                                            body: Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            ),
                                                          );
                                                        } else {
                                                          final List<
                                                              User> users = User
                                                                  .fromJSONArray(
                                                                      snapshot
                                                                          .data
                                                                          .body)
                                                              .where((u) =>
                                                                  !assigneeIds
                                                                      .value
                                                                      .contains(u
                                                                          .id) &&
                                                                  u.id !=
                                                                      leaderId
                                                                          .value)
                                                              .toList();
                                                          if (users.length >
                                                              0) {
                                                            return Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: users
                                                                  .map((u) =>
                                                                      EmployeeCard(
                                                                        name: u
                                                                            .username,
                                                                        role: u
                                                                            .role,
                                                                        button:
                                                                            ActionButton(
                                                                          icon:
                                                                              Icon(Icons.add),
                                                                          onPressed:
                                                                              () {
                                                                            assigneeIds.value.add(u.id);
                                                                            setState(() {
                                                                              users.remove(users.where((uu) => u.id == uu.id));
                                                                            });
                                                                            assigneeRefresh.value =
                                                                                true;
                                                                          },
                                                                        ),
                                                                      ))
                                                                  .toList(),
                                                            );
                                                          } else {
                                                            return Container(
                                                              child: Text(
                                                                'No more employees',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      }),
                                            ),
                                          ));
                            }),
                      ],
                    ),
                    StatefulBuilder(
                      builder: (context, setState) => FutureBuilder(
                          future: loadAddedAssignees(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (assigneeRefresh.value) {
                                setState(() {
                                  assigneeRefresh.value = false;
                                });
                              }
                            });

                            if (snapshot.hasError) {
                              print(snapshot.error);
                              return Center(
                                child: Text('Error'),
                              );
                            } else if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              List<User> assignees =
                                  User.fromJSONArray(snapshot.data.body);

                              return Column(
                                children: assignees
                                    .map((a) => EmployeeCard(
                                          name: a.username,
                                          role: a.role,
                                          button: ActionButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: () {
                                              assigneeIds.value.remove(a.id);
                                              assigneeRefresh.value = true;
                                              setState(() {
                                                assignees.remove(
                                                    assignees.where(
                                                        (aa) => aa.id == a.id));
                                              });
                                            },
                                          ),
                                        ))
                                    .toList(),
                              );
                            }
                          }),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
