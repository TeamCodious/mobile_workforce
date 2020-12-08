import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart';
import 'package:mobile_workforce/components/action_button.dart';
import 'package:mobile_workforce/global.dart';
import 'package:mobile_workforce/models.dart';
import 'package:mobile_workforce/state.dart';

import '../global.dart';

class CreateReportPage extends HookWidget {
  final Task task;
  CreateReportPage({Key key, this.task}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final titleController = useTextEditingController();
    final isSaving = useState(false);

    _clear() {
      textController.clear();
      titleController.clear();
    }

    _validate() =>
        textController.text.isNotEmpty && titleController.text.isNotEmpty;

    _report() async {
      String url = Uri.encodeFull(Global.URL + '/reports/new');
      String formattedString =
          task.adminIds.map((a) => '"' + a + '"').toList().toString();
      String body =
          '{"task": "${task.id}", "reporter": "${CurrentUserId.id}", "receivers": $formattedString, "title": "${titleController.text}", "text": "${textController.text}", "confirmedTime" : 0}';
      Response res = await put(url, headers: Global.HEADERS, body: body);
      if (res.statusCode == 201) {
        Navigator.pop(context);
        print('done');
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Create report'),
      ),
      bottomSheet: Container(
          margin: EdgeInsets.all(5),
          height: 40,
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 5),
                  child: RaisedButton(
                    onPressed: () {
                      if (_validate()) {
                        _report();
                      }
                    },
                    child: Text('Report'),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 5),
                  child: RaisedButton(
                    onPressed: () {
                      _clear();
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                ),
              ),
            ],
          )),
      body: isSaving.value
          ? Center(child: Text('Saving...'))
          : SingleChildScrollView(
              child: Container(
                margin:
                    EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      autocorrect: false,
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Report title',
                      ),
                    ),
                    TextFormField(
                      autocorrect: false,
                      controller: textController,
                      decoration: InputDecoration(
                        labelText: 'Report description',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Additional files',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        ActionButton(
                          icon: Icon(Icons.add),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
