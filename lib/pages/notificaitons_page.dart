import 'package:flutter/material.dart';

class NotificaitonPage extends StatelessWidget {
  const NotificaitonPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(  
        title: Text("Notifications"),
        centerTitle: true,
      ),
      body: Center(  
        child: Text("Notifications"),
      ),
    );
  }
}