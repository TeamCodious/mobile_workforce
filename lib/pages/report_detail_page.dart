import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mobile_workforce/global.dart';
import 'package:mobile_workforce/models.dart';

class ReportDetailPage extends HookWidget {
  final String id;
  ReportDetailPage({Key key, this.id}) : super(key: key);

  loadReport() async {
    String url1 = Uri.encodeFull(Global.URL + 'reports/' + id);
    Response res1 = await get(url1);
    Report report = Report.fromJSON(res1.body);

    String url2 = Uri.encodeFull(Global.URL + 'employees/' + report.reporter);
    Response res2 = await get(url2);
    User user = User.fromJSON(res2.body);

    String url3 = Uri.encodeFull(Global.URL + 'tasks/' + report.task);
    Response res3 = await get(url3);
    Task task = Task.fromJSON(res3.body);

    return {'report': report, 'user': user, 'task': task};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Report Detail'),
      ),
      body: FutureBuilder(
        future: loadReport(),
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
            final DateTime ct = DateTime.fromMillisecondsSinceEpoch(
                snapshot.data['report'].createdTime);
            final formattedCt =
                '${DateFormat.yMMMMd('en_US').format(ct)} ${DateFormat('jm').format(ct)}';
            return Container(
              margin: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 50),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Report title',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Text(
                      snapshot.data['report'].title,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Reporter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Text(
                      snapshot.data['user'].username,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Task name',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Text(
                      snapshot.data['task'].title,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Report time',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Text(
                      formattedCt,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Report description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Text(
                      snapshot.data['report'].text,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Additional files',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
