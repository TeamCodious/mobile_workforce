import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../global.dart';
import 'package:http/http.dart';
import 'package:mobile_workforce/models.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class TimeLine extends StatefulWidget {
  TimeLine({Key key, this.id}) : super(key: key);
  final String id;
  @override
  _TimeLineState createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  Timer timer;
  List<charts.Series<dynamic, String>> seriesList = [];

  @override
  void initState() {
    super.initState();
    loadTimes();
    print("started");
    timer = Timer.periodic(Duration(seconds: 10), (timer) {
      print("loaded Times");
      loadTimes();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    timer = null;
    super.dispose();
  }

  void loadTimes() async {
    String url3 =
        Uri.encodeFull(Global.URL + 'employees/' + widget.id + '/times');
    Response res3 = await get(url3, headers: Global.HEADERS);
    List<Time> times = Time.fromJSONArray(res3.body);
    times.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    charts.Series<dynamic, String> totalTime = new charts
            .Series<dynamic, String>(
        id: 'total_time',
        data: times,
        domainFn: (time, _) =>
            '${DateFormat.MMMd('en_US').format(DateTime.fromMillisecondsSinceEpoch(time.createdAt))}',
        measureFn: (time, _) => time.totalTime);
    charts.Series<dynamic, String> totalBreak = new charts
            .Series<dynamic, String>(
        id: 'total_break',
        data: times,
        domainFn: (time, _) =>
            '${DateFormat.MMMd('en_US').format(DateTime.fromMillisecondsSinceEpoch(time.createdAt))}',
        measureFn: (time, _) => time.totalBreak);
    setState(() {
      seriesList = [totalBreak, totalTime];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Card(
          child: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'Timeline',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 15),
              height: 250,
              child: charts.BarChart(
                seriesList,
                animate: false,
                barGroupingType: charts.BarGroupingType.stacked,
                selectionModels: [
                  new charts.SelectionModelConfig(
                      changedListener: (charts.SelectionModel model) {
                    final _date = model.selectedSeries[0]
                        .domainFn(model.selectedDatum[0].index);
                    final _totalTime =
                        model.selectedDatum.first.datum.totalTime.toString();
                    final _totalBreak =
                        model.selectedDatum.first.datum.totalBreak.toString();
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Date'),
                                      Text(_date),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Total work time (min)'),
                                      Text(_totalTime),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Total break time (min)'),
                                      Text(_totalBreak),
                                    ],
                                  )
                                ],
                              ),
                            ));
                  })
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
