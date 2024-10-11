import 'package:flutter/material.dart';

class DashboardCTAButton extends StatelessWidget {
  final String label;
  final Function onTap;
  final Color color;
  const DashboardCTAButton(
      {Key key, @required this.label, this.onTap, @required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.grey,
        elevation: 3,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              // Container(
              //   width: 50,
              //   height: 50,
              //   decoration: BoxDecoration(
              //     border: Border.all(
              //         color: Colors.white.withOpacity(0.3), width: 3),
              //     shape: BoxShape.circle,
              //     color: Colors.white,
              //     // gradient: LinearGradient(colors: [
              //     //   Colors.white.withOpacity(0.05),
              //     //   color,
              //     // ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
              //   ),
              // ),
              // SizedBox(
              //   height: 10,
              // ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
