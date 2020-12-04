import 'package:flutter/material.dart';
import 'package:mobile_workforce/pages/task_detail_page.dart';

class TaskCard extends StatelessWidget {
  final title;
  final taskId;
  final duration;
  TaskCard({Key key, this.title, this.taskId, this.duration}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => TaskDetailPage(
                        taskId: taskId,
                      )));
        },
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  duration,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
