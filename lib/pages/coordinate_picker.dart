import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_workforce/components/action_button.dart';

class CoordinatePicker extends HookWidget {
  final LatLng coordinate;
  CoordinatePicker(this.coordinate, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _coordinate = useState(coordinate);
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a place'),
        titleSpacing: 0,
        actions: <Widget>[
          Tooltip(
            message: 'Save',
            child: ActionButton(
              icon: Icon(Icons.save),
              onPressed: () {
                Navigator.pop(context, _coordinate.value);
              },
            ),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: coordinate, zoom: 12),
        markers: List.of([
          Marker(
            markerId: MarkerId('id'),
            position: _coordinate.value,
          )
        ]).toSet(),
        onTap: (newCoordinate) {
          _coordinate.value = newCoordinate;
        },
        zoomControlsEnabled: false,
      ),
    );
  }
}
