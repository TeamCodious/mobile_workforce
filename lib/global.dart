import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_workforce/models.dart';
import 'package:mobile_workforce/state.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Global {
  static const BACKGROUND_TASK_ID = 2000;
  static const USER_ID_KEY = "com.example.userID";
  static const USER_ROLE = "com.example.role";
  static const WORKING_STATE = "com.example.workingState";
  static const URL =
      "https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/";
  static void setWorking() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Global.WORKING_STATE, 'ON');
    CurrentUserId.updateWorkingState('ON');
  }
  static void setBreak() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Global.WORKING_STATE, 'BREAK');
    CurrentUserId.updateWorkingState('BREAK');
  }
  static void setFinish() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Global.WORKING_STATE, 'OFF');
    CurrentUserId.updateWorkingState('OFF');
  }
}

Future<bool> isInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  } else {
    return false;
  }
}

class SQLite {
  static Future<Database> setUpDB() async {
    return openDatabase(
      join(await getDatabasesPath(), 'location.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE locations(id TEXT PRIMARY KEY, latitude NUMERIC, longitude NUMERIC, time INTEGER)",
        );
      },
      version: 1,
    );
  }

  static Future<void> insertPosition(Position position) async {
    final uuid = Uuid();
    final LocationBackUp location = LocationBackUp(
        id: uuid.v4(),
        latitude: position.latitude,
        longitude: position.longitude,
        time: DateTime.now().toUtc().millisecondsSinceEpoch);
    final Database db = await setUpDB();
    await db.insert(
      'locations',
      location.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    final los = await locations();
    print(los.length);
  }

  static Future<List<LocationBackUp>> locations() async {
    final Database db = await setUpDB();
    final List<Map<String, dynamic>> maps = await db.query('locations');
    return List.generate(maps.length, (i) {
      return LocationBackUp(
          id: maps[i]['id'],
          latitude: maps[i]['latitude'],
          longitude: maps[i]['longitude'],
          time: maps[i]['time']);
    });
  }

  static Future<bool> hasBackUps() async {
    final backups = await locations();
    return backups.isNotEmpty;
  }

  static void deleteBackups() async {
    final Database db = await setUpDB();
    await db.delete("locations");
  }

  static Future<void> deleteLocation(String id) async {
    final db = await setUpDB();
    await db.delete(
      'locations',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
