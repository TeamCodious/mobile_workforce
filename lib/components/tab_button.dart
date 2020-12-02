import 'package:flutter/material.dart';

class TabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Function onPressed;

  TabButton({
    Key key,
    @required this.text,
    @required this.onPressed,
    @required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: NavigationToolbar.kMiddleSpacing / 2,
      ),
      child: RaisedButton(
        elevation: 0,
        highlightElevation: 0,
        highlightColor: Colors.grey[300],
        child: Text(
          text,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide(
            color: Colors.grey[300],
            width: 2,
          ),
        ),
        color: isSelected ? Colors.grey[300] : Colors.transparent,
        onPressed: onPressed,
      ),
    );
  }
}
