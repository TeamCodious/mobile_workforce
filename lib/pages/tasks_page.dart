import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_workforce/components/tab_button.dart';
import 'package:mobile_workforce/components/task_card.dart';
import 'package:mobile_workforce/pages/create_task_page.dart';

class TasksPage extends HookWidget {
  final tasksPlanned = ['Task 1', 'Task 2', 'Task 3'];
  final tasksDone = ['Task 4', 'Task 5'];
  final tasksOngoing = ['Task 6', 'Task 7'];

  @override
  Widget build(BuildContext context) {
    final tabIndex = useState(1);
    final tabController = useTabController(initialLength: 3, initialIndex: 1);

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
      floatingActionButton: Tooltip(
        message: 'Create new task',
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            Icons.add,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => CreateTaskPage()));
          },
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TabButton(
                text: 'Planned',
                onPressed: scrollToTab(0),
                isSelected: tabController.index == 0,
              ),
              TabButton(
                text: 'Ongoing',
                onPressed: scrollToTab(1),
                isSelected: tabController.index == 1,
              ),
              TabButton(
                text: 'Completed',
                onPressed: scrollToTab(2),
                isSelected: tabController.index == 2,
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                ListView.builder(
                  itemBuilder: (context, index) => TaskCard(
                    title: tasksPlanned[index],
                  ),
                  itemCount: tasksPlanned.length,
                ),
                ListView.builder(
                  itemBuilder: (context, index) => TaskCard(
                    title: tasksOngoing[index],
                  ),
                  itemCount: tasksOngoing.length,
                ),
                ListView.builder(
                  itemBuilder: (context, index) => TaskCard(
                    title: tasksDone[index],
                  ),
                  itemCount: tasksDone.length,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
