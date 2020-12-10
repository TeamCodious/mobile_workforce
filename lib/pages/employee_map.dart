import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart';
import '../global.dart';
import '../models.dart';

class EmployeeMap extends StatefulWidget {
  EmployeeMap({Key key, this.id, this.iniLat, this.iniLong}) : super(key: key);
  final String id;
  final double iniLat;
  final double iniLong;
  @override
  _EmployeeMapState createState() => _EmployeeMapState();
}

class _EmployeeMapState extends State<EmployeeMap> {
  Timer timer;
  List<User> employees = [];
  Set<Marker> markers = Set();
  BitmapDescriptor taskLocationIcon;
  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5), 'assets/task_marker.png')
        .then((value) => taskLocationIcon = value);
    _getMarkers();

    _getMarkers();
    timer = Timer.periodic(Duration(seconds: 10), (timer) {
      print("hello");
      _getMarkers();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    timer = null;
    super.dispose();
  }

  void _getMarkers() async {
    String url = Uri.encodeFull(
        'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/employees/${widget.id}');
    Response response = await get(url, headers: Global.HEADERS);
    final user = User.fromJSON(response.body);
    String urlTask = Uri.encodeFull(
        'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/employees/${widget.id}/tasks?type=assignee');
    Response responseTask = await get(urlTask, headers: Global.HEADERS);
    setState(() {
      markers = Task.fromJSONArray(responseTask.body)
          .map((e) => Marker(
                markerId: MarkerId(e.id),
                infoWindow: InfoWindow(title: e.title),
                position: LatLng(
                  e.latitude,
                  e.longitude,
                ),
                icon: taskLocationIcon,
              ))
          .toSet();
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
            target: LatLng(widget.iniLat, widget.iniLong),
            zoom: 15,
          ),
          markers: markers,
        ));
  }
}
