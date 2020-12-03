import 'package:flutter/material.dart';
import 'package:mobile_workforce/pages/task_detail_page.dart';

class TaskCard extends StatelessWidget {
  final title;
  TaskCard({Key key, this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => TaskDetailPage()));
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
                  '5 DEC 2020 23:55 PM',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
