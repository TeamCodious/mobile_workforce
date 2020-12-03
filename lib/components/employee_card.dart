import 'package:flutter/material.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/pages/employee_detail_page.dart';

class EmployeeCard extends StatelessWidget {
  final name;
  final role;
  final ActionButton button;
  EmployeeCard({Key key, this.name, this.role, this.button}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => EmployeeDetailPage()));
        },
        child: Container(
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              if (button != null) button,
            ],
          ),
        ),
      ),
    );
  }
}
