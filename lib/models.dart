import 'dart:convert';

class Task {
  String id;
  String title;
  String description;
  int startTime;
  int dueTime;
  String taskState;
  List<dynamic> adminIds;
  List<dynamic> assigneeIds;
  double latitude;
  double longitude;
  String location;
  String manager;

  static Task fromJSON(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return Task()
      ..id = data['id']
      ..title = data['title']
      ..description = data['description']
      ..startTime = data['start_time']
      ..dueTime = data['due_time']
      ..taskState = data['task_state']
      ..adminIds = data['owners']
      ..assigneeIds = data['assignees']
      ..manager = data['manager']
      ..latitude = data['latitude'] ?? 0.0
      ..location = data['location'] ?? "nil"
      ..longitude = data['longitude'] ?? 0.0;
  }

  static List<Task> fromJSONArray(String jsonString) {
    final Iterable<dynamic> data = jsonDecode(jsonString);
    return data
        .map((t) => Task()
          ..id = t['id']
          ..title = t['title']
          ..description = t['description']
          ..startTime = t['start_time']
          ..dueTime = t['due_time']
          ..taskState = t['task_state']
          ..adminIds = t['owners']
          ..assigneeIds = t['assignees']
          ..manager = t['manager']
          ..latitude = t['latitude'] ?? 0.0
          ..location = t['location'] ?? "nil"
          ..longitude = t['longitude'] ?? 0.0)
        .toList();
  }
}

class User {
  String id;
  String username;
  String fullname;
  String email;
  String role;
  String phoneNumber;
  double latitude;
  double longitude;

  static User fromJSON(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return User()
      ..id = data['id']
      ..username = data['username']
      ..fullname = data['full_name']
      ..email = data['email']
      ..role = data['employee_role']
      ..phoneNumber = data['phone_no']
      ..latitude = data['latitude'] ?? null
      ..longitude = data['longitude'] ?? null;
  }

  static List<User> fromJSONArray(String jsonString) {
    final Iterable<dynamic> data = jsonDecode(jsonString);
    return data
        .map((u) => User()
          ..id = u['id']
          ..username = u['username']
          ..fullname = u['full_name']
          ..email = u['email']
          ..role = u['employee_role']
          ..phoneNumber = u['phone_no']
          ..latitude = u['latitude'] ?? null
          ..longitude = u['longitude'] ?? null)
        .toList();
  }
}

class LocationBackUp {
  String id;
  double latitude;
  double longitude;
  int time;
  LocationBackUp({this.id, this.latitude, this.longitude, this.time});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'time': time,
    };
  }
}

class Location {
  String id;
  double latitude;
  double longitude;
  int time;
  String employee;
  Location({this.id, this.latitude, this.longitude, this.time, this.employee});
  static Location fromJSON(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return Location()
      ..id = data['id']
      ..latitude = data['latitude']
      ..longitude = data['longitude']
      ..time = data['time']
      ..employee = data['employee'];
  }
}

class Report {
  String id;
  bool confirmed;
  List<dynamic> receivers;
  String reporter;
  String task;
  String title;
  String text;
  int createdTime;
  int confirmedTime;

  static Report fromJSON(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return Report()
      ..id = data['id']
      ..title = data['title']
      ..text = data['text']
      ..task = data['task']
      ..receivers = data['receivers']
      ..reporter = data['reporter']
      ..confirmed = data['confirmed']
      ..createdTime = data['createdAt']
      ..confirmedTime = data['confirmedTime'];
  }

  static List<Report> fromJSONArray(String jsonString) {
    final Iterable<dynamic> data = jsonDecode(jsonString);
    return data
        .map((r) => Report()
          ..id = r['id']
          ..title = r['title']
          ..text = r['text']
          ..task = r['task']
          ..receivers = r['receivers']
          ..reporter = r['reporter']
          ..confirmed = r['confirmed']
          ..createdTime = r['createdAt']
          ..confirmedTime = r['confirmedTime'])
        .toList();
  }
}
