import 'package:flutter/material.dart';

class BusyWidget extends StatelessWidget {
  const BusyWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      child: Center(
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/images/dds_logo.png',
                width: 15,
                height: 15,
              ),
            ),
            CircularProgressIndicator(
              backgroundColor: Color(0xFFFFA000),
            ),
          ],
        ),
      ),
    );
  }
}
