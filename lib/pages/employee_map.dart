import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart';
import '../models.dart';

class EmployeeMap extends StatefulWidget {
  EmployeeMap({Key key, this.id}) : super(key: key);
  final String id;
  @override
  _EmployeeMapState createState() => _EmployeeMapState();
}

class _EmployeeMapState extends State<EmployeeMap> {
  Timer timer;
  List<User> employees = [];
  Set<Marker> markers = Set();
  @override
  void initState() {
    super.initState();
    _getMarkers();
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
  void _getMarkers() async {
      String url = Uri.encodeFull(
          'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/employees/${widget.id}');
      Response response = await get(url);
      final user = User.fromJSON(response.body);
      String urlTask = Uri.encodeFull(
          'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/employees/${widget.id}/tasks?type=assignee');
      Response responseTask = await get(urlTask);
      setState(() {
        markers = Task.fromJSONArray(responseTask.body).map((e) => Marker(markerId: MarkerId(e.id), infoWindow: InfoWindow(title: e.title),
                position: LatLng(
                  e.latitude,
                  e.longitude,
                ),)).toSet();
        markers.add(Marker(
                infoWindow: InfoWindow(title: user.fullname),
                markerId: MarkerId(user.username),
                position: LatLng(
                  user.latitude,
                  user.longitude,
                ),
              ));
        employees = [user].toList();
      });
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(  
        centerTitle: true,
        title: const Text('Current Location'),
      ),
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
            
        )
    );
  }
}