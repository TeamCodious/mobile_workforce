import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class EmployeeDetailPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Employee Detail'),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 20),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Container(
                    color: Colors.red,
                    width: 80,
                    height: 80,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Fred',
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headline6.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Area Manager',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text('ABC Company Limited'),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [Text('2'), Text('Planned Tasks')],
              ),
              Column(
                children: [Text('1'), Text('Ongoing Tasks')],
              ),
              Column(
                children: [Text('3'), Text('Complete Tasks')],
              )
            ],
          ),
        ],
      ),
    );
  }
}
