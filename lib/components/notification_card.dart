import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_workforce/models.dart';
import 'package:mobile_workforce/pages/report_detail_page.dart';

class NotiCard extends StatelessWidget {
  final Noti noti;
  NotiCard({Key key, this.noti}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  noti.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  noti.description,
                ),
              )
            ],
          ),
        ),
    );
  }
}
