import 'package:flutter/material.dart';

class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String number;
  final VoidCallback onActionPressed;
  final Color color;
  final bool isDayStarted;

  const DashboardTile({
    Key key,
    this.icon,
    this.title,
    this.number,
    this.onActionPressed,
    this.color,
    this.isDayStarted = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isDayStarted) {
          onActionPressed?.call();
        } else {
          _showDayNotStartedDialog(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: isDayStarted
              ? (color ?? Colors.grey.shade200)
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isDayStarted ? Colors.blue.shade900 : Colors.grey,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: isDayStarted ? Colors.black87 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              number,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: isDayStarted ? Colors.redAccent : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDayNotStartedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Day Not Started'),
          content: const Text(
              'Please start your day before accessing this feature.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
