import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart';
import 'package:mobile_workforce/components/tab_button.dart';
import 'package:mobile_workforce/components/task_card.dart';
import 'package:mobile_workforce/models.dart';
import 'package:mobile_workforce/pages/create_task_page.dart';
import 'package:mobile_workforce/state.dart';

class TasksPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final tabIndex = useState(1);
    final tabController = useTabController(initialLength: 3, initialIndex: 1);

    final tasks = useState([]);

    final plannedTasks =
        tasks.value.where((t) => t.taskState == 'Planned').toList();
    final ongoingTasks =
        tasks.value.where((t) => t.taskState == 'Ongoing').toList();
    final completedTasks =
        tasks.value.where((t) => t.taskState == 'Completed').toList();

    loadTasks() async {
      String url = Uri.encodeFull(
          'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/employees/' +
              CurrentUserId.id +
              '/tasks');
      Response response = await get(url);
      tasks.value = Task.fromJSONArray(response.body);
    }

    useEffect(() {
      tabController.addListener(() {
        tabIndex.value = tabController.index;
      });
      return () {};
    });

    useEffect(() {
      loadTasks();
      return () {};
    }, []);

    Function scrollToTab(int i) {
      return () {
        tabController.animateTo(i);
      };
    }

    String calculateDuration(Task task) {
      String duration;
      if (task.taskState == 'Completed') {
        final pTime = DateTime.now().millisecondsSinceEpoch - task.dueTime;
        if (pTime >= 31556952000) {
          duration =
              'ended ' + (pTime ~/ 31556952000).toString() + ' years ago';
        } else if (pTime >= 2592000000) {
          duration =
              'ended ' + (pTime ~/ 2592000000).toString() + ' months ago';
        } else if (pTime >= 86400000) {
          duration = 'ended ' + (pTime ~/ 86400000).toString() + ' days ago';
        } else if (pTime >= 3600000) {
          duration = 'ended ' + (pTime ~/ 3600000).toString() + ' hours ago';
        } else if (pTime >= 3600000) {
          duration = 'ended ' + (pTime ~/ 60000).toString() + ' min ago';
        } else {
          duration = 'ended just now';
        }
      } else if (task.taskState == 'Ongoing') {
        final pTime = task.dueTime - DateTime.now().millisecondsSinceEpoch;
        if (pTime >= 31556952000) {
          duration = (pTime ~/ 31556952000).toString() + ' years remaining';
        } else if (pTime >= 2592000000) {
          duration = (pTime ~/ 2592000000).toString() + ' months remaining';
        } else if (pTime >= 86400000) {
          duration = (pTime ~/ 86400000).toString() + ' days remaining';
        } else if (pTime >= 3600000) {
          duration = (pTime ~/ 3600000).toString() + ' hours remaining';
        } else if (pTime >= 3600000) {
          duration = (pTime ~/ 60000).toString() + ' min remaining';
        } else {
          duration = 'a few seconds remaining';
        }
      } else if (task.taskState == 'Planned') {
        final pTime = task.startTime - DateTime.now().millisecondsSinceEpoch;
        if (pTime >= 31556952000) {
          duration = 'begin in ' + (pTime ~/ 31556952000).toString() + ' years';
        } else if (pTime >= 2592000000) {
          duration = 'begin in ' + (pTime ~/ 2592000000).toString() + ' months';
        } else if (pTime >= 86400000) {
          duration = 'begin in ' + (pTime ~/ 86400000).toString() + ' days';
        } else if (pTime >= 3600000) {
          duration = 'begin in ' + (pTime ~/ 3600000).toString() + ' hours';
        } else if (pTime >= 3600000) {
          duration = 'begin in ' + (pTime ~/ 60000).toString() + ' min';
        } else {
          duration = 'begin in a few seconds';
        }
      }
      return duration;
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
                plannedTasks.length > 0
                    ? ListView.builder(
                        itemBuilder: (context, index) => TaskCard(
                          title: plannedTasks[index].title,
                          taskId: plannedTasks[index].id,
                          duration: calculateDuration(plannedTasks[index]),
                        ),
                        itemCount: plannedTasks.length,
                      )
                    : Center(
                        child: Text(
                          'No tasks',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                ongoingTasks.length > 0
                    ? ListView.builder(
                        itemBuilder: (context, index) => TaskCard(
                          title: ongoingTasks[index].title,
                          taskId: ongoingTasks[index].id,
                          duration: calculateDuration(ongoingTasks[index]),
                        ),
                        itemCount: ongoingTasks.length,
                      )
                    : Center(
                        child: Text(
                          'No tasks',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                completedTasks.length > 0
                    ? ListView.builder(
                        itemBuilder: (context, index) => TaskCard(
                          title: completedTasks[index].title,
                          taskId: completedTasks[index].id,
                          duration: calculateDuration(completedTasks[index]),
                        ),
                        itemCount: completedTasks.length,
                      )
                    : Center(
                        child: Text(
                          'No tasks',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
