import 'package:flutter/material.dart';
import 'package:mobile_workforce/global.dart';
import 'package:http/http.dart';
import 'package:mobile_workforce/models.dart';

class ActivityCard extends StatelessWidget {
  final title;
  final employeeId;
  final taskId;
  final createdTime;
  final type;
  ActivityCard(
      {Key key,
      this.title,
      this.employeeId,
      this.taskId,
      this.createdTime,
      this.type})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    load() async {
      String url1 = Uri.encodeFull(Global.URL + 'employees/' + employeeId);
      Response res1 = await get(url1);
      User employee = User.fromJSON(res1.body);

      Task task;
      if (taskId != null) {
        String url2 = Uri.encodeFull(Global.URL + 'tasks/' + taskId);
        Response res2 = await get(url2);
        task = Task.fromJSON(res2.body);
      }

      return {
        "employee": employee,
        "task": task,
      };
    }

    return FutureBuilder(
        future: load(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Scaffold(
              body: Center(
                child: Text('Error'),
              ),
            );
          } else if (!snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            String duration;
            int time = DateTime.now().millisecondsSinceEpoch - createdTime;
            if (time >= 31556952000) {
              duration = (time ~/ 31556952000).toString() + ' years ago';
            } else if (time >= 2592000000) {
              duration = (time ~/ 2592000000).toString() + ' months ago';
            } else if (time >= 86400000) {
              duration = (time ~/ 86400000).toString() + ' days ago';
            } else if (time >= 3600000) {
              duration = (time ~/ 3600000).toString() + ' hours ago';
            } else if (time >= 3600000) {
              duration = (time ~/ 60000).toString() + ' min ago';
            } else {
              duration = 'just now';
            }

            String s;
            if (type == 'task') {
              if (title == 'Created a new task') {
                s = ' created this task';
              } else if (title == 'Created a new report') {
                s = ' reported this task is done';
              } else if (title == 'Confirmed a report') {
                s = ' confirmed this task is done';
              }
            }

            return Container(
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    type == 'employee'
                        ? title
                        : snapshot.data['employee'].username + s,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
