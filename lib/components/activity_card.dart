import 'package:flutter/material.dart';

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
    String duration;
    int time = DateTime.now().millisecondsSinceEpoch - createdTime;
    if (time >= 31556952000) {
      duration = (time ~/ 31556952000).toString() + ' yr ago';
    } else if (time >= 2592000000) {
      duration = (time ~/ 2592000000).toString() + ' mn ago';
    } else if (time >= 86400000) {
      duration = (time ~/ 86400000).toString() + ' d ago';
    } else if (time >= 3600000) {
      duration = (time ~/ 3600000).toString() + ' hr ago';
    } else if (time >= 3600000) {
      duration = (time ~/ 60000).toString() + ' m ago';
    } else {
      duration = 'just now';
    }

    String s;
    if (type == 'task') {
      if (title == 'Created a new task') {
        s = 'This task is created';
      } else if (title == 'Created a new report') {
        s = 'A report is created';
      } else if (title == 'Confirmed a report') {
        s = 'A report is confirmed';
      }
    }

    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            type == 'employee' ? title : s,
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
}
