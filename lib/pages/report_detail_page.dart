import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/global.dart';
import 'package:mobile_workforce/models.dart';
import 'package:mobile_workforce/state.dart';

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
        actions: [
          Tooltip(
              message: 'Chat with reporter',
              child: ActionButton(icon: Icon(Icons.message), onPressed: () {})),
        ],
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
            final DateTime cft = DateTime.fromMillisecondsSinceEpoch(
                snapshot.data['report'].confirmedTime);
            final formattedCft =
                '${DateFormat.yMMMMd('en_US').format(cft)} ${DateFormat('jm').format(cft)}';

            finishTask() async {
              String url = Uri.encodeFull(Global.URL +
                  'tasks/' +
                  snapshot.data['task'].id +
                  '/change?type=finish');
              String body =
                  '{"time": ${DateTime.now().millisecondsSinceEpoch}}';
              Response res = await patch(url, body: body);
              if (res.statusCode == 204) {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => ReportDetailPage(
                              id: snapshot.data['report'].id,
                            )));
                print('done');
              }
            }

            confirmReport() async {
              String url = Uri.encodeFull(Global.URL +
                  'reports/' +
                  snapshot.data['report'].id +
                  '/confirm?confirmer=${CurrentUserId.id}');
              String body = '{"isConfirmed": true}';
              Response res = await patch(url, body: body);
              if (res.statusCode == 204) {
                print('done');
              }
            }

            deleteReport() async {
              String url = Uri.encodeFull(Global.URL + 'reports/' + id);
              Response res = await delete(url);
              if (res.statusCode == 204) {
                print('done');
              }
              Navigator.pop(context);
            }

            return Container(
              margin: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Report state',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Text(
                      snapshot.data['report'].confirmed
                          ? 'Confirmed'
                          : 'Unconfirmed',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  snapshot.data['report'].confirmed
                      ? Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Confirmed time',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Container(),
                  snapshot.data['report'].confirmed
                      ? Container(
                          margin: EdgeInsets.only(bottom: 20),
                          child: Text(
                            formattedCft,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        )
                      : Container(),
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
                  Spacer(),
                  snapshot.data['report'].confirmed
                      ? Container()
                      : Container(
                          margin: EdgeInsets.all(5),
                          height: 40,
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(right: 5),
                                  child: RaisedButton(
                                    onPressed: () async {
                                      String response = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                content: Text(
                                                    'Are you sure to delete this report?'),
                                                actions: [
                                                  FlatButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context, 'Yes');
                                                      },
                                                      child: Text('Yes')),
                                                  FlatButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context, 'No');
                                                      },
                                                      child: Text('No')),
                                                ],
                                              ));
                                      if (response == 'Yes') {
                                        deleteReport();
                                      }
                                    },
                                    child: Text('Delete'),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: RaisedButton(
                                    onPressed: () async {
                                      String response = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                content: Text(
                                                    'Are you sure to confirm that this task is done?'),
                                                actions: [
                                                  FlatButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context, 'Yes');
                                                      },
                                                      child: Text('Yes')),
                                                  FlatButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context, 'No');
                                                      },
                                                      child: Text('No')),
                                                ],
                                              ));
                                      if (response == 'Yes') {
                                        confirmReport();
                                        finishTask();
                                      }
                                    },
                                    child: Text('Confirm'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
