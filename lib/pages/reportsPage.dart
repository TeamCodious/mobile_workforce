import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart';
import 'package:mobile_workforce/components/report_card.dart';
import 'package:mobile_workforce/components/tab_button.dart';
import 'package:mobile_workforce/global.dart';
import 'package:mobile_workforce/models.dart';
import 'package:mobile_workforce/state.dart';

class ReportsPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final tabIndex = useState(0);
    final tabController = useTabController(initialLength: 2);

    loadReports() async {
      String type = CurrentUserId.role == 'Manager' ? 'receiver' : 'reporter';
      String url = Uri.encodeFull(Global.URL +
          'employees/' +
          CurrentUserId.id +
          '/reports?type=' +
          type);
      Response res = await get(url, headers: Global.HEADERS);
      List<Report> reports = Report.fromJSONArray(res.body);
      List<Report> confirmedReports =
          reports.where((r) => r.confirmed).toList();
      List<Report> unconfirmedReports =
          reports.where((r) => !r.confirmed).toList();

      return {
        'confirmedReports': confirmedReports,
        'unconfirmedReports': unconfirmedReports
      };
    }

    useEffect(() {
      tabController.addListener(() {
        tabIndex.value = tabController.index;
      });
      return () {};
    });

    Function scrollToTab(int i) {
      return () {
        tabController.animateTo(i);
      };
    }

    return Scaffold(
      body: FutureBuilder(
          future: loadReports(),
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
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TabButton(
                        text: 'Unconfirmed',
                        onPressed: scrollToTab(0),
                        isSelected: tabController.index == 0,
                      ),
                      TabButton(
                        text: 'Confirmed',
                        onPressed: scrollToTab(1),
                        isSelected: tabController.index == 1,
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        snapshot.data['unconfirmedReports'].length > 0
                            ? ListView.builder(
                                itemBuilder: (context, index) => ReportCard(
                                  report: snapshot.data['unconfirmedReports']
                                      [index],
                                ),
                                itemCount:
                                    snapshot.data['unconfirmedReports'].length,
                              )
                            : Center(
                                child: Text(
                                  'No reports',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                        snapshot.data['confirmedReports'].length > 0
                            ? ListView.builder(
                                itemBuilder: (context, index) => ReportCard(
                                  report: snapshot.data['confirmedReports']
                                      [index],
                                ),
                                itemCount:
                                    snapshot.data['confirmedReports'].length,
                              )
                            : Center(
                                child: Text(
                                  'No reports',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }
}
