import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/pages/messages_page.dart';
import 'package:mobile_workforce/pages/tasks_page.dart';

class HomePage extends HookWidget {
  final _tabs = <String>['Tasks', 'Map', 'Messages', 'Reports', 'Settings'];

  @override
  Widget build(BuildContext context) {
    final tabIndex = useState(0);
    final tabController = useTabController(initialLength: 5);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_tabs[tabIndex.value]),
        actions: [
          Tooltip(
            message: 'Profile',
            child: ActionButton(
              onPressed: () {},
              icon: Icon(Icons.person),
            ),
          )
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
                  ? Icon(Icons.settings)
                  : Icon(Icons.settings_outlined),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          TasksPage(),
          Center(
            child: const Text('Map'),
          ),
          MessagesPage(),
          Center(
            child: const Text('Notifications'),
          ),
          Center(
            child: const Text('Setting'),
          ),
        ],
      ),
    );
  }
}
