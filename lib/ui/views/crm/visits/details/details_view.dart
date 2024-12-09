import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/ui/views/crm/activities/activities_view.dart';
import 'package:distributor/ui/views/crm/visits/details/details_view_model.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class ScheduleDetailsView extends StatelessWidget {
  final List<ScheduleDetails> detailsList;
  final Function(ScheduleDetails) onTileTap;

  const ScheduleDetailsView({
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
            title: const Text('Schedule Details'),
            backgroundColor: kColDDSPrimaryDark,
          ),
          body: model.isBusy
              ? const Center(child: BusyWidget())
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListView.builder(
                    itemCount: model.scheduleDetailsList.length ?? 0,
                    itemBuilder: (context, index) {
                      final schedule = model.scheduleDetailsList[index];

                      // Check if the schedule has any scheduledVisits
                      if (schedule.payload.scheduledVisits == null ||
                          schedule.payload.scheduledVisits.isEmpty) {
                        return const SizedBox(
                          child: Center(
                            child: Text("No Schedule details Available"),
                          ),
                        );
                      }

                      // Return a ListView for scheduledVisits within the current schedule
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            // Iterate through each scheduledVisit
                            for (var visit in schedule.payload.scheduledVisits)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: InkWell(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ActivitiesView(
                                            visitId: visit.visitId.toInt()),
                                      ),
                                    );
                                    if (result is ScheduleDetails) {
                                      onTileTap(result);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .green.shade50, // Background color
                                      borderRadius: BorderRadius.circular(
                                          8), // Rounded corners
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                              0.1), // Soft shadow color
                                          spreadRadius:
                                              2, // How far the shadow spreads
                                          blurRadius:
                                              8, // How soft the shadow looks
                                          offset: const Offset(0,
                                              4), // Downward and horizontal offset
                                        ),
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(
                                              0.05), // Lighter shadow for layering
                                          spreadRadius: 1,
                                          blurRadius: 6,
                                          offset: const Offset(
                                              0, 2), // Subtle offset for depth
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Top Row: Customer Code (left) and Customer Name (right)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Cust Code: ${visit.code}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                'Cust Name: ${visit.name}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Bottom Row: Route (left) and Visit Date (right)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Route: ${visit.route ?? "N/A"}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                'Visit Date: ${visit.scheduleDate ?? "N/A"}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  )),
        );
      },
    );
  }
}
