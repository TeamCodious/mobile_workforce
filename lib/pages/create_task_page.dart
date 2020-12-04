import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/components/employee_card.dart';
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
    final assigneeIds = useState([]);

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

    _save() async {
      String url = Uri.encodeFull(
          'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/tasks/new');

      String body =
          '{"title": "${titleController.text}", "description": "${descriptionController.text}", "assignees": [], "owners": [], "tesk_state": "Planned", "start_time": ${startDate.value.millisecondsSinceEpoch}, "due_time": ${dueDate.value.millisecondsSinceEpoch}}';
      Response response = await put(url, body: body);
      if (response.statusCode == 201) {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => HomePage()));
      }
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
                      readOnly: true,
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
                                    'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/employees?type=managers');
                                return get(url);
                              }

                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        title: Text(
                                          'Add admins',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: FutureBuilder(
                                            future: loadManagers(),
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
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                );
                                              } else {
                                                final List<User> users =
                                                    User.fromJSONArray(
                                                            snapshot.data.body)
                                                        .where((u) => !adminIds
                                                            .value
                                                            .contains(u.id))
                                                        .toList();
                                                print(users[0].id);
                                                print(adminIds.value);
                                                return SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: users
                                                        .map((u) =>
                                                            EmployeeCard(
                                                              name: u.username,
                                                              role: u.role,
                                                              button:
                                                                  ActionButton(
                                                                icon: Icon(
                                                                    Icons.add),
                                                                onPressed:
                                                                    () {},
                                                              ),
                                                            ))
                                                        .toList(),
                                                  ),
                                                );
                                              }
                                            }),
                                      ));
                            }),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [],
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
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        title: Text(
                                          'Add assignees',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              EmployeeCard(
                                                name: 'Joe',
                                                role: 'Assignee',
                                                button: ActionButton(
                                                  icon: Icon(Icons.add),
                                                  onPressed: () {},
                                                ),
                                              ),
                                              EmployeeCard(
                                                name: 'Bob',
                                                role: 'Internship',
                                                button: ActionButton(
                                                  icon: Icon(Icons.add),
                                                  onPressed: () {},
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ));
                            }),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        EmployeeCard(
                          name: 'Jenny',
                          role: 'Assignee',
                          button: ActionButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
