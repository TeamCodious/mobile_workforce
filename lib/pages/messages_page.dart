import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_workforce/components/message_card.dart';
import 'package:mobile_workforce/components/tab_button.dart';

class MessagesPage extends HookWidget {
  final taskMessages = <String>['Message 1', 'Message 2'];
  final directMessages = <String>['Message 3', 'Message 4'];

  @override
  Widget build(BuildContext context) {
    final tabIndex = useState(0);
    final tabController = useTabController(initialLength: 2);

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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TabButton(
                text: 'Task messages',
                onPressed: scrollToTab(0),
                isSelected: tabController.index == 0,
              ),
              TabButton(
                text: 'Direct messages',
                onPressed: scrollToTab(1),
                isSelected: tabController.index == 1,
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                ListView.builder(
                  itemBuilder: (context, index) => MessageCard(
                    title: taskMessages[index],
                  ),
                  itemCount: taskMessages.length,
                ),
                ListView.builder(
                  itemBuilder: (context, index) => MessageCard(
                    title: directMessages[index],
                  ),
                  itemCount: directMessages.length,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
