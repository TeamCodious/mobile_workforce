import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart';
import '../models.dart';
import '../state.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (CurrentUserId.role == 'Manager') {
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
  BitmapDescriptor pinLocationIcon;
  @override
  void initState() {
    super.initState();
    _getEmployees();
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
  void _getEmployees() async {
      String url = Uri.encodeFull(
          'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/employees?type=employees');
      Response response = await get(url);
      setState(() {
        employees = User.fromJSONArray(response.body).where((element) => element.latitude != null).toList();
      });
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
          // onMapCreated: initMap(context),
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
          markers: Set<Marker>.of(employees.map((e) => Marker(
                infoWindow: InfoWindow(title: e.fullname),
                markerId: MarkerId(e.username),
                position: LatLng(
                  e.latitude,
                  e.longitude,
                ),
                onTap: () {},
              ))),
            
        )
    );
  }
}

class EmployeeMapPage extends StatefulWidget {
  EmployeeMapPage({Key key}) : super(key: key);

  @override
  _EmployeeMapPageState createState() => _EmployeeMapPageState();
}

class _EmployeeMapPageState extends State<EmployeeMapPage> {
  BitmapDescriptor bit;
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
          'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/employees/${CurrentUserId.id}/tasks?type=owner');
      Response response = await get(url);
      setState(() {
        tasks = Task.fromJSONArray(response.body);
      });
      print(tasks.length);
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
          // onMapCreated: initMap(context),
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
            
        )
    );
  }
}

