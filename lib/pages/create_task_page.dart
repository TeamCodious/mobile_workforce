import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/components/employee_card.dart';
import 'package:mobile_workforce/pages/coordinate_picker.dart';

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
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
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
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: Text(
                                    'Add admins',
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
                                          name: 'Ben',
                                          role: 'Manager',
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
                    name: 'John (You)',
                    role: 'Manager',
                  ),
                ],
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
                            builder: (BuildContext context) => AlertDialog(
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
