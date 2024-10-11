import 'package:flutter/material.dart';

class CustomExtendedButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  const CustomExtendedButton({Key key, @required this.label, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
