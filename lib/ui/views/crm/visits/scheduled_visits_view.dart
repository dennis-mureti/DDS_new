import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/ui/views/crm/custom_list_tile.dart';
import 'package:distributor/ui/views/crm/Visits/scheduled_view_model.dart';
import 'package:distributor/ui/views/crm/schedule/schedule_visit_view.dart';
import 'package:distributor/ui/views/crm/visits/details/details_view.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class ScheduledView extends StatelessWidget {
  final Function(Visits) onTap;

  const ScheduledView({Key key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ScheduleViewModel>.reactive(
      onModelReady: (model) async {
        await model.init();
        print('Visits after fetch: ${model.visitList}');
      },
      viewModelBuilder: () => ScheduleViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Scheduled Visits'),
            backgroundColor: kColDDSPrimaryDark,
          ),
          body: model.isBusy
              ? const Center(child: BusyWidget())
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListView.builder(
                    itemCount: model.visitList.length,
                    itemBuilder: (context, index) {
                      final visit = model.visitList[index];
                      if (visit.customerVisits == null) {
                        return const SizedBox(); // Handle empty scheduled visits
                      }
                      // Define status color logic
                      Color statusColor = Colors.grey; // Default color
                      if (visit.status == 'Approved') {
                        statusColor = Colors.green;
                      } else if (visit.status == 'Pending') {
                        statusColor = Colors.red;
                      } else if (visit.status == 'Declined') {
                        statusColor = Colors.black;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: InkWell(
                          onTap: visit.status == 'Approved'
                              ? () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ScheduleDetailsView(
                                        onTileTap: (selectedVisit) {
                                          // Handle tile tap if necessary
                                        },
                                      ),
                                    ),
                                  );
                                  if (result is Visits) onTap(result);
                                }
                              : null, // Disable onTap for non-Approved statuses
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Top Row: Scheduled Visits and Customer Issues
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Scheduled Visits: ${visit.scheduledVisits ?? 'N/A'}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Customer Issues: ${visit.issues ?? 'N/A'}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20),
                                // Bottom Row: Status and Action Button
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 0.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Status
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0, vertical: 6.0),
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'Status: ${visit.status ?? 'Unknown'}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      // Action Button (Three Dots)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          color: Colors.black,
                                        ),
                                        onPressed: visit.status == 'Approved'
                                            ? () async {
                                                final result =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ScheduleDetailsView(
                                                      onTileTap:
                                                          (selectedVisit) {
                                                        // Handle tile tap if necessary
                                                      },
                                                    ),
                                                  ),
                                                );
                                                if (result is Visits)
                                                  onTap(result);
                                              }
                                            : null, // Disable button for non-Approved statuses
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navigate to Schedule Visit screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      VisitView(), // Replace with your actual schedule view
                ),
              );
            },
            backgroundColor: kColDDSPrimaryDark,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}
