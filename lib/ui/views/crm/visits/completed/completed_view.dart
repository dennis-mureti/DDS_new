import 'package:distributor/ui/views/crm/visits/details/details_view_model.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';
import 'package:intl/intl.dart'; // Import the intl package

class CompleteVisitsView extends StatelessWidget {
  final List<ScheduleDetails> detailsList;
  final Function(ScheduleDetails) onTileTap;

  const CompleteVisitsView({
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
            title: const Text('Completed Visits'),
          ),
          body: model.isBusy
              ? const Center(child: BusyWidget())
              : model.scheduleDetailsList.isEmpty
                  ? const Center(
                      child: Text("No Completed Visits Available for Today"),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        itemCount: model.scheduleDetailsList.length,
                        itemBuilder: (context, index) {
                          final schedule = model.scheduleDetailsList[index];

                          final completedVisits = schedule
                              .payload.scheduledVisits
                              ?.where((visit) =>
                                  visit.visitStatus?.toLowerCase() ==
                                  "completed")
                              .toList();

                          if (completedVisits == null ||
                              completedVisits.isEmpty) {
                            return const Center(
                              child: Text("No Completed Visits Available"),
                            );
                          }

                          return Column(
                            children: [
                              for (var visit in completedVisits)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: InkWell(
                                    onTap: null,
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
                                            "Check-in not allowed for completed visits",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.red,
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
