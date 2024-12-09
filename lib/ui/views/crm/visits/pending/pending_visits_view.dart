import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/ui/views/crm/visits/details/details_view.dart';
import 'package:distributor/ui/views/crm/visits/pending/pending_visits_view_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';

class PendingVisitsView extends StatelessWidget {
  final List<PendingVisit> pendingVisitsList;
  final Function(PendingVisit) onTileTap;

  const PendingVisitsView({
    Key key,
    this.pendingVisitsList,
    this.onTileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PendingVisitsViewModel>.reactive(
      onModelReady: (model) async {
        await model.init();
        print('Pending Visits after fetch: ${model.pendingVisitsList}');
      },
      viewModelBuilder: () => PendingVisitsViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pending Visits'),
            backgroundColor: kColDDSPrimaryDark,
          ),
          body: model.isBusy
              ? const Center(child: BusyWidget())
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListView.builder(
                    itemCount: model.pendingVisitsList.length,
                    itemBuilder: (context, index) {
                      final visit = model.pendingVisitsList[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0, top: 10),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScheduleDetailsView(),
                              ),
                            );
                          },
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Date: ${visit.date}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'Visit Made: ${visit.visitsMade}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Status: Pending',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red, // Red for pending
                                      ),
                                    ),
                                  ],
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
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScheduleDetailsView(),
                ),
              );
              if (result != null) {
                // Handle result if needed
              }
            },
            backgroundColor: kColDDSPrimaryDark,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
