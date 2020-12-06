import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_workforce/models.dart';
import 'package:mobile_workforce/pages/report_detail_page.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  ReportCard({Key key, this.report}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final DateTime ct = DateTime.fromMillisecondsSinceEpoch(report.createdTime);
    final formattedCt =
        '${DateFormat.yMMMMd('en_US').format(ct)} ${DateFormat('jm').format(ct)}';
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => ReportDetailPage(
                        id: report.id,
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
                  report.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  formattedCt,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
