import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart';
import '../models.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Timer timer;
  List<User> employees = [];
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

// class MapPage extends HookWidget {

//   @override
//   Widget build(BuildContext context) {
//     final employees = useState(List<User>());
//     void getEmployees() async {
//       String url = Uri.encodeFull(
//           'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/employees?type=employees');
//       Response response = await get(url);
//       employees.value = User.fromJSONArray(response.body).where((element) => element.latitude != null).toList();
//     }
//     useEffect(() {
//       return () {};
//     });

//     // Timer.periodic(Duration(seconds: 10), (timer) {
//     //   print("hello");
//     //   getEmployees();
//     // });
//     return 
//   }
// }