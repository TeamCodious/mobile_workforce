import 'package:flutter/material.dart';
import 'package:mobile_workforce/components/notification_card.dart';
import '../state.dart';
import '../global.dart';
import 'package:http/http.dart';
import '../models.dart';

class NotificaitonPage extends StatelessWidget {
  const NotificaitonPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _loadNotifications() async {
      String url = Uri.encodeFull(Global.URL +
          'employees/' +
          CurrentUserId.id +
          '/notifications');
      Response res = await get(url, headers: Global.HEADERS);
      return Noti.fromJSONArray(res.body);
    }

    return Scaffold(
      appBar: AppBar(  
        title: Text("Notifications"),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: _loadNotifications(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              print("[Error]: ${snapshot.error}");
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
              return snapshot.data.length > 0
                  ? ListView.builder(
                      itemBuilder: (context, index) => NotiCard(noti: snapshot.data[index]),
                      itemCount: snapshot.data.length,
                    )
                  : Center(
                      child: Text(
                        'No notifications',
                        style: TextStyle(fontSize: 15),
                      ),
                    );
            }
          }),
    );
  }
}