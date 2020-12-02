import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CreateTaskPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Create Task'),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Container(),
      ),
    );
  }
}
