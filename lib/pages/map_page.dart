import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart';
import '../models.dart';
import '../state.dart';
import './employee_map.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (CurrentUserId.role == "Manager") {
        return ManagerMapPage();
      } else {
        return EmployeeMapPage();
      }
    });
  }
}

class ManagerMapPage extends StatefulWidget {
  ManagerMapPage({Key key}) : super(key: key);

  @override
  _ManagerMapPageState createState() => _ManagerMapPageState();
}

class _ManagerMapPageState extends State<ManagerMapPage> {
  Timer timer;
  List<User> employees = [];
  List<Task> tasks = [];
  Set<Marker> markers = Set();
  @override
  void initState() {
    super.initState();
    _getMarkers();
    // timer = Timer.periodic(Duration(seconds: 10), (timer) {
    //   print("hello");
    // _getMarkers();
    // });
  }

  @override
  void dispose() {
    // timer.cancel();
    // timer = null;
    super.dispose();
  }

  void _getMarkers() async {
    String url = Uri.encodeFull(
        'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/employees?type=employees');
    Response response = await get(url);
    final array = User.fromJSONArray(response.body)
        .where((element) => element.latitude != null)
        .toList();
    String urlTask = Uri.encodeFull(
        'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/employees/${CurrentUserId.id}/tasks?type=owner');
    Response responseTask = await get(urlTask);
    setState(() {
      markers = Task.fromJSONArray(responseTask.body)
          .map((e) => Marker(
                markerId: MarkerId(e.id),
                infoWindow: InfoWindow(title: e.title),
                position: LatLng(
                  e.latitude,
                  e.longitude,
                ),
              ))
          .toSet();
      print(markers.length);
      markers.addAll(array
          .map((e) => Marker(
                infoWindow: InfoWindow(title: e.fullname),
                markerId: MarkerId(e.username),
                position: LatLng(
                  e.latitude,
                  e.longitude,
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              EmployeeMap(id: e.id)));
                },
              ))
          .toSet());
      employees = User.fromJSONArray(response.body)
          .where((element) => element.latitude != null)
          .toList();
      print(markers.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GoogleMap(
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(16.8409, 96.1735),
        zoom: 15,
      ),
      circles: Set<Circle>.of(employees.map((e) => Circle(
            circleId: CircleId(e.username),
            center: LatLng(e.latitude, e.longitude),
            fillColor: Colors.red.withOpacity(0.2),
            strokeWidth: 0,
            radius: 100,
          ))),
      markers: markers,
    ));
  }
}

class EmployeeMapPage extends StatefulWidget {
  EmployeeMapPage({Key key}) : super(key: key);

  @override
  _EmployeeMapPageState createState() => _EmployeeMapPageState();
}

class _EmployeeMapPageState extends State<EmployeeMapPage> {
  Timer timer;
  List<Task> tasks = [];
  @override
  void initState() {
    super.initState();
    _getTasks();
    // timer = Timer.periodic(Duration(seconds: 10), (timer) {
    //   print("hello");
    //   _getEmployees();
    // });
  }

  @override
  void dispose() {
    // timer.cancel();
    // timer = null;
    super.dispose();
  }

  void _getTasks() async {
    String url = Uri.encodeFull(
        'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/employees/${CurrentUserId.id}/tasks?type=all');
    Response response = await get(url);
    setState(() {
      tasks = Task.fromJSONArray(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GoogleMap(
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(16.8409, 96.1735),
        zoom: 15,
      ),
      markers: Set<Marker>.of(tasks.map((e) => Marker(
            infoWindow: InfoWindow(title: e.title),
            markerId: MarkerId(e.id),
            position: LatLng(
              e.latitude,
              e.longitude,
            ),
            onTap: () {},
          ))),
    ));
  }
}
