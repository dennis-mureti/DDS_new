import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/ui/views/crm/visits/completed/complete_view_model.dart';
import 'package:distributor/ui/views/crm/visits/details/details_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';

class CompleteVisitsView extends StatelessWidget {
  final List<CompleteVisit> completeVisitsList;
  final Function(CompleteVisit) onTileTap;

  const CompleteVisitsView({
    Key key,
    this.completeVisitsList,
    this.onTileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CompleteVisitsViewModel>.reactive(
      onModelReady: (model) async {
        await model.init();
        print('Complete Visits after fetch: ${model.completeVisitsList}');
      },
      viewModelBuilder: () => CompleteVisitsViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Complete Visits'),
            backgroundColor: kColDDSPrimaryDark,
          ),
          body: model.isBusy
              ? const Center(child: BusyWidget())
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListView.builder(
                    itemCount: model.completeVisitsList.length,
                    itemBuilder: (context, index) {
                      final visit = model.completeVisitsList[index];

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
                                      'Status: Approved',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
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
              // Navigate to a new screen when the FAB is pressed
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
