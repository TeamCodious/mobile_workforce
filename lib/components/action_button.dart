import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final Icon icon;
  final Function onPressed;
  final EdgeInsets margin;

  ActionButton({
    @required this.icon,
    @required this.onPressed,
    this.margin = const EdgeInsets.all(NavigationToolbar.kMiddleSpacing / 2),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        clipBehavior: Clip.antiAlias,
        shape: CircleBorder(),
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(
              NavigationToolbar.kMiddleSpacing / 2,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}
