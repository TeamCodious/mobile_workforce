import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/components/employee_card.dart';

class TaskDetailPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        margin: EdgeInsets.all(5),
        height: 40,
        width: double.infinity,
        child: RaisedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text('Report'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RaisedButton(
                      onPressed: () {},
                      child: Text('Default report'),
                    ),
                    RaisedButton(
                      onPressed: () {},
                      child: Text('Custom report'),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Text('Report'),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Task Detail'),
        actions: [
          Tooltip(
              message: 'Chat about this task',
              child: ActionButton(icon: Icon(Icons.message), onPressed: () {})),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 50),
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 50),
              child: Text(
                'Meeting with Customer',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ongoing',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    '3:58 remaining',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 15),
              height: 80,
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text(
                                'Admins',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    EmployeeCard(
                                      name: 'John',
                                      role: 'Manager',
                                    ),
                                    EmployeeCard(
                                      name: 'Ben',
                                      role: 'Manager',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '2',
                              style: TextStyle(fontSize: 15),
                            ),
                            Text(
                              'Admins',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text(
                                'Assignees',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    EmployeeCard(
                                      name: 'Joe',
                                      role: 'Assignee',
                                    ),
                                    EmployeeCard(
                                      name: 'Bob',
                                      role: 'Internship',
                                    ),
                                    EmployeeCard(
                                      name: 'Jenny',
                                      role: 'Assignee',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '3',
                              style: TextStyle(fontSize: 15),
                            ),
                            Text(
                              'Assignees',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: ExpandablePanel(
                    header: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Text(
                            'Start time',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            '5 DEC 2020 10:00 AM',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Due time',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            '5 DEC 2020 11:55 AM',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: ExpandablePanel(
                    header: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    expanded: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc commodo eleifend mi. Curabitur mattis, orci nec tincidunt placerat, orci ligula molestie libero, sit amet tristique metus augue in orci.',
                        softWrap: true,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: ExpandablePanel(
                    header: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    expanded: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Junction 8, 8 miles, Kyaik Waing Pagoda Rd, Yangon',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          color: Colors.green,
                          height: 200,
                          child: Center(
                            child: Text('Map'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: ExpandablePanel(
                    header: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Activities',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    expanded: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'John created this task',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '5 min ago',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
