import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LoginPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    String _username;
    String _password;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            SizedBox(
              height: 500,
            ),
            TextField(
              onChanged: (String s) => _username = s,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              onChanged: (String s) => _password = s,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            RaisedButton(
              onPressed: () {
                print(_username);
                print(_password);
              },
              child: const Text('Login'),
            )
          ],
        ),
      ),
    );
  }
}
