import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final coordinate = LatLng(16.8409, 96.1735);

    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: coordinate, zoom: 15),
      ),
    );
  }
}
