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
      ..assigneeIds = data['assignees'];
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
          ..assigneeIds = t['assignees'])
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

  static User fromJSON(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return User()
      ..id = data['id']
      ..username = data['username']
      ..fullname = data['full_name']
      ..email = data['email']
      ..role = data['employee_role']
      ..phoneNumber = data['phone_no'];
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
          ..phoneNumber = u['phone_no'])
        .toList();
  }
}

class Location_BackUp {
  String id;
  double latitude;
  double longitude;
  int time;
  Location_BackUp({this.id, this.latitude, this.longitude, this.time});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'time': time,
    };
  }
}

class Login {
  String token;
  bool online;
  
}