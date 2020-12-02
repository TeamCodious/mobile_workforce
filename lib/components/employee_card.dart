import 'package:flutter/material.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/pages/employee_detail.dart';

class EmployeeCard extends StatelessWidget {
  final name;
  final role;
  EmployeeCard({Key key, this.name, this.role}) : super(key: key);
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
          padding: EdgeInsets.symmetric(horizontal: 3),
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
              ActionButton(
                icon: Icon(Icons.message),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
