import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomListTile extends StatelessWidget {
  final String customerName;
  final String location;
  final String time;
  final DateTime scheduleStartDate;
  final DateTime scheduleEndDate;
  final String approvalStatus;
  final String dateApproved;
  final VoidCallback onActionPressed;

  const CustomListTile({
    Key key,
    this.customerName,
    this.location,
    this.time,
    this.scheduleStartDate,
    this.scheduleEndDate,
    this.approvalStatus,
    this.dateApproved,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  customerName,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.grey,
                      size: 20.0,
                    ),
                    const SizedBox(width: 5.0),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.grey,
                  size: 20.0,
                ),
                const SizedBox(width: 5.0),
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  scheduleStartDate != null
                      ? 'Start Date: ${dateFormatter.format(scheduleStartDate)}'
                      : 'Start Date: N/A',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  scheduleEndDate != null
                      ? 'End Date: ${dateFormatter.format(scheduleEndDate)}'
                      : 'End Date: N/A',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: $approvalStatus',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: _getApprovalStatusColor(approvalStatus),
                  ),
                ),
                IconButton(
                  onPressed: onActionPressed,
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to get the color based on the approval status
  Color _getApprovalStatusColor(String status) {
    // Handle the case where status is null
    status = status?.toLowerCase() ?? 'unknown'; // Default to 'unknown' if null

    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.yellow.shade700;
      case 'completed':
        return Colors.black;
      default:
        return Colors.grey.shade600;
    }
  }
}
