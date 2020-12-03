import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/pages/map_page.dart';
import 'package:mobile_workforce/pages/messages_page.dart';
import 'package:mobile_workforce/pages/settings_page.dart';
import 'package:mobile_workforce/pages/tasks_page.dart';

class HomePage extends HookWidget {
  final _tabs = <String>['Tasks', 'Map', 'Messages', 'Reports', 'Employees'];

  @override
  Widget build(BuildContext context) {
    final tabIndex = useState(0);
    final tabController = useTabController(initialLength: 5);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_tabs[tabIndex.value]),
        leading: Tooltip(
          message: 'Profile',
          child: ActionButton(
            onPressed: () {},
            icon: Icon(Icons.person),
          ),
        ),
        actions: [
          Tooltip(
            message: 'Settings',
            child: ActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => SettingsPage()));
              },
              icon: Icon(Icons.settings),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        color: Theme.of(context).colorScheme.primary,
        child: TabBar(
          controller: tabController,
          onTap: (index) {
            tabIndex.value = index;
          },
          tabs: [
            Tab(
              child: tabIndex.value == 0
                  ? Icon(Icons.fact_check)
                  : Icon(Icons.fact_check_outlined),
            ),
            Tab(
              child: tabIndex.value == 1
                  ? Icon(Icons.map)
                  : Icon(Icons.map_outlined),
            ),
            Tab(
              child: tabIndex.value == 2
                  ? Icon(Icons.sms)
                  : Icon(Icons.sms_outlined),
            ),
            Tab(
              child: tabIndex.value == 3
                  ? Icon(Icons.notifications)
                  : Icon(Icons.notifications_outlined),
            ),
            Tab(
              child: tabIndex.value == 4
                  ? Icon(Icons.people)
                  : Icon(Icons.people_outline),
            ),
          ],
        ),
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          TasksPage(),
          MapPage(),
          MessagesPage(),
          Center(
            child: const Text('Notifications'),
          ),
          Center(
            child: const Text('Employees'),
          ),
        ],
      ),
    );
  }
}
