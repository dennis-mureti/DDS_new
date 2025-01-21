import 'package:distributor/ui/views/crm/visits/details/details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:distributor/ui/views/crm/checkin/checkin_view.dart';
import 'package:distributor/ui/views/crm/checkin/gt_checkin_view.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:stacked/stacked.dart';
import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:tripletriocore/tripletriocore.dart'; // Assuming the brand color is defined here

class ScheduleDetailsView extends StatelessWidget {
  final List<ScheduleDetails> detailsList;
  final Function(ScheduleDetails) onTileTap;

  const ScheduleDetailsView({
    Key key,
    this.detailsList,
    this.onTileTap,
  }) : super(key: key);

  // Helper method to check if any visit has the "Started" status
  bool hasStartedVisit(List<ScheduledVisit> visits) {
    return visits.any((visit) => visit.visitStatus?.toLowerCase() == "started");
  }

  void _showPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Action Not Allowed"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ScheduleDetailsViewModel>.reactive(
      onModelReady: (model) async {
        await model.init();
        print('Details after fetch: ${model.scheduleDetailsList}');
      },
      viewModelBuilder: () => ScheduleDetailsViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Schedule Details'),
            backgroundColor:
                kColDDSPrimaryDark, // Assuming this is a predefined color
          ),
          body: model.isBusy
              ? const Center(child: BusyWidget())
              : model.scheduleDetailsList.isEmpty
                  ? const Center(
                      child: Text("No Schedule details Available for Today"),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        itemCount: model.scheduleDetailsList.length,
                        itemBuilder: (context, index) {
                          final schedule = model.scheduleDetailsList[index];
                          final visits = schedule.payload.scheduledVisits ?? [];

                          // Check if there's any "Started" visit
                          bool anyStartedVisit = hasStartedVisit(visits);

                          return visits.isEmpty
                              ? const Center(
                                  child: Text("No Schedule details "),
                                )
                              : Column(
                                  children: [
                                    for (var visit in visits)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16.0),
                                        child: InkWell(
                                          onTap: () {
                                            // Check if any visit is in "Started" status
                                            if (visit.visitStatus
                                                    ?.toLowerCase() ==
                                                "started") {
                                              // Proceed to Check-in screen for "Started" status visits
                                              final route = visit
                                                          .customerType ==
                                                      "MT"
                                                  ? MaterialPageRoute(
                                                      builder: (context) =>
                                                          CheckInView(
                                                        visitId:
                                                            visit.id.toInt(),
                                                        customerName:
                                                            visit.name,
                                                      ),
                                                    )
                                                  : visit.customerType == "GT"
                                                      ? MaterialPageRoute(
                                                          builder: (context) =>
                                                              GTCheckInView(
                                                            visitId: visit.id
                                                                .toInt(),
                                                            customerName:
                                                                visit.name,
                                                          ),
                                                        )
                                                      : null;

                                              if (route != null) {
                                                Navigator.push(
                                                  context,
                                                  route,
                                                );
                                              }
                                            } else if (visit.visitStatus
                                                    ?.toLowerCase() ==
                                                "scheduled") {
                                              // If the visit is "Scheduled" but there's another "Started" visit
                                              if (anyStartedVisit) {
                                                _showPopup(
                                                  context,
                                                  "Not allowed to proceed with this visit because you have another visit started.",
                                                );
                                              } else {
                                                // Allow rerouting to the next visit if no "Started" visit exists
                                                final route = visit
                                                            .customerType ==
                                                        "MT"
                                                    ? MaterialPageRoute(
                                                        builder: (context) =>
                                                            CheckInView(
                                                          visitId:
                                                              visit.id.toInt(),
                                                          customerName:
                                                              visit.name,
                                                        ),
                                                      )
                                                    : visit.customerType == "GT"
                                                        ? MaterialPageRoute(
                                                            builder: (context) =>
                                                                GTCheckInView(
                                                              visitId: visit.id
                                                                  .toInt(),
                                                              customerName:
                                                                  visit.name,
                                                            ),
                                                          )
                                                        : null;

                                                if (route != null) {
                                                  Navigator.push(
                                                    context,
                                                    route,
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(16.0),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.05),
                                                  spreadRadius: 1,
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                // Customer Name
                                                Text(
                                                  visit.name ?? "N/A",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                // Customer Code
                                                Text(
                                                  'Customer Code: ${visit.code}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Customer type: ${visit.customerType}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                // Visit Date
                                                Text(
                                                  'Visit Date: ${visit.scheduleDate != null ? DateFormat('yyyy/MM/dd').format(visit.scheduleDate) : "N/A"}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                // Status
                                                Text(
                                                  visit.visitStatus ?? "N/A",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: _getStatusColor(
                                                        visit.visitStatus ??
                                                            "N/A"),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                // Action Message
                                                Text(
                                                  visit.visitStatus
                                                              ?.toLowerCase() ==
                                                          "completed"
                                                      ? "Check-in not allowed for completed visits"
                                                      : visit.visitStatus
                                                                  ?.toLowerCase() ==
                                                              "started"
                                                          ? "Continue to Check-in"
                                                          : "Scheduled Visit",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontStyle: FontStyle.italic,
                                                    color: visit.visitStatus
                                                                ?.toLowerCase() ==
                                                            "completed"
                                                        ? Colors.red
                                                        : Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                        },
                      ),
                    ),
        );
      },
    );
  }

  // Returns a color based on the status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "scheduled":
        return Colors.black;
      case "started":
        return Colors.orange;
      case "completed":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
