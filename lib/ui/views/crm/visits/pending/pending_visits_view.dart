import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/ui/views/crm/checkin/checkin_view.dart';
import 'package:distributor/ui/views/crm/checkin/gt_checkin_view.dart';
import 'package:distributor/ui/views/crm/visits/details/details_view_model.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';
import 'package:intl/intl.dart'; // Import the intl package

class PendingVisitsView extends StatelessWidget {
  final List<ScheduleDetails> detailsList;
  final Function(ScheduleDetails) onTileTap;

  const PendingVisitsView({
    Key key,
    this.detailsList,
    this.onTileTap,
  }) : super(key: key);

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
            title: const Text('Pending Visits'),
            backgroundColor: kColDDSPrimaryDark,
          ),
          body: model.isBusy
              // ? const Center(child: BusyWidget())
              ? const Center(child: BusyWidget())
              : model.scheduleDetailsList.isEmpty
                  ? const Center(
                      child: Text("No Pending Visits Available for Today"),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        itemCount: model.scheduleDetailsList.length,
                        itemBuilder: (context, index) {
                          final schedule = model.scheduleDetailsList[index];

                          // Filter out the visits with status 'started'
                          final startedVisits = schedule.payload.scheduledVisits
                              ?.where((visit) =>
                                  visit.visitStatus?.toLowerCase() == "started")
                              ?.toList();

                          // If no started visits are found, show a message
                          if (startedVisits == null || startedVisits.isEmpty) {
                            return const Center(
                              child: Text("No Pending Visits Available"),
                            );
                          }

                          return Column(
                            children: [
                              for (var visit in startedVisits)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: InkWell(
                                    onTap: (visit.visitStatus?.toLowerCase() !=
                                            "completed")
                                        ? () async {
                                            final route = visit.customerType ==
                                                    "MT"
                                                ? MaterialPageRoute(
                                                    builder: (context) =>
                                                        CheckInView(
                                                      visitId: visit.id.toInt(),
                                                      customerName: visit.name,
                                                    ),
                                                  )
                                                : visit.customerType == "GT"
                                                    ? MaterialPageRoute(
                                                        builder: (context) =>
                                                            GTCheckInView(
                                                          visitId:
                                                              visit.id.toInt(),
                                                          customerName:
                                                              visit.name,
                                                        ),
                                                      )
                                                    : null;

                                            if (route != null) {
                                              final result =
                                                  await Navigator.push(
                                                context,
                                                route,
                                              );
                                              if (result is ScheduleDetails) {
                                                onTileTap(result);
                                              }
                                            }
                                          }
                                        : null,
                                    child: Container(
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            spreadRadius: 2,
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                          BoxShadow(
                                            color:
                                                Colors.grey.withOpacity(0.05),
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
                                                  visit.visitStatus ?? "N/A"),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Action Message
                                          Text(
                                            visit.visitStatus?.toLowerCase() ==
                                                    "completed"
                                                ? "Check-in not allowed for completed visits"
                                                : "Proceed to Check-in",
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
