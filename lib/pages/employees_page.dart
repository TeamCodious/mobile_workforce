import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/components/employee_card.dart';
import 'package:mobile_workforce/components/tab_button.dart';
import 'package:mobile_workforce/global.dart';
import 'package:mobile_workforce/models.dart';
import 'package:mobile_workforce/state.dart';

class EmployeesPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final tabIndex = useState(0);
    final tabController = useTabController(initialLength: 2);

    loadManagersAndEmployees() async {
      String url1 = Uri.encodeFull(
          'https://tunfjy82s4.execute-api.ap-southeast-1.amazonaws.com/prod_v1/employees?type=managers');
      Response res1 = await get(url1);
      List<User> managers = User.fromJSONArray(res1.body)
          .where((m) => m.id != CurrentUserId.id)
          .toList();

      String url2 = Uri.encodeFull(Global.URL + 'employees?type=employees');
      Response res2 = await get(url2);

      List<User> employees = User.fromJSONArray(res2.body)
          .where((e) => e.id != CurrentUserId.id)
          .toList();

      Map<String, List<User>> managersAndEmployees = {
        'managers': managers,
        'employees': employees
      };

      return managersAndEmployees;
    }

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
      body: FutureBuilder(
          future: loadManagersAndEmployees(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
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
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TabButton(
                        text: 'Managers',
                        onPressed: scrollToTab(0),
                        isSelected: tabController.index == 0,
                      ),
                      TabButton(
                        text: 'Employees',
                        onPressed: scrollToTab(1),
                        isSelected: tabController.index == 1,
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        snapshot.data['managers'].length > 0
                            ? ListView.builder(
                                itemBuilder: (context, index) => EmployeeCard(
                                  name:
                                      snapshot.data['managers'][index].username,
                                  id: snapshot.data['managers'][index].id,
                                  role: snapshot.data['managers'][index].role,
                                  button: ActionButton(
                                    icon: Icon(Icons.message),
                                    onPressed: () {},
                                  ),
                                ),
                                itemCount: snapshot.data['managers'].length,
                              )
                            : Center(
                                child: Text(
                                  'No managers',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                        snapshot.data['employees'].length > 0
                            ? ListView.builder(
                                itemBuilder: (context, index) => EmployeeCard(
                                  name: snapshot
                                      .data['employees'][index].username,
                                  id: snapshot.data['employees'][index].id,
                                  role: snapshot.data['employees'][index].role,
                                  button: ActionButton(
                                    icon: Icon(Icons.message),
                                    onPressed: () {},
                                  ),
                                ),
                                itemCount: snapshot.data['employees'].length,
                              )
                            : Center(
                                child: Text(
                                  'No employees',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }
}
