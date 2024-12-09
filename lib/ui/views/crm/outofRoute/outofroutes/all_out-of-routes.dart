import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/views/crm/outofRoute/feedback.dart';
import 'package:distributor/ui/views/crm/outofRoute/outofroutes/out_of_route_view_model.dart';
import 'package:distributor/ui/views/crm/outofRoute/out_of_request_view.dart';
import 'package:tripletriocore/tripletriocore.dart';

class OutOfRoutesView extends StatelessWidget {
  final List<AllOutofRoute> outOfRoutesList; // List of Out of Routes
  final Function(AllOutofRoute) onTileTap;

  const OutOfRoutesView({
    Key key,
    this.outOfRoutesList,
    this.onTileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OutOfRoutesViewModel>.reactive(
      onModelReady: (model) async {
        await model.init();
        print('Out of Routes after fetch: ${model.outOfRoutesList}');
      },
      viewModelBuilder: () => OutOfRoutesViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Out of Routes'),
            backgroundColor: kColDDSPrimaryDark,
          ),
          body: model.isBusy
              ? const Center(child: BusyWidget())
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListView.builder(
                    itemCount: model.outOfRoutesList.length,
                    itemBuilder: (context, index) {
                      final route = model.outOfRoutesList[index];

                      // Determine the status color
                      Color statusColor;
                      if (route.approvedStatus == "PENDING") {
                        statusColor = Colors.red;
                      } else if (route.approvedStatus == "APPROVED") {
                        statusColor = Colors.green;
                      } else {
                        statusColor = Colors.green;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0, top: 10),
                        child: InkWell(
                          onTap: () async {
                            // Navigate to FeedbackView and pass the route
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FeedbackView(),
                              ),
                            );
                            if (result is AllOutofRoute) {
                              onTileTap(result); // Handle tile tap callback
                            }
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
                                // Top Row: Customer Name and Requested Date
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        route.customerName ??
                                            "No Name", // Customer name
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      route.dateRequested ??
                                          "N/A", // Requested date
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Bottom Row: Sales Rep Name and Status
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Sales Rep: ${route.salesRepFirstName} ${route.salesRepLastName}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        route.approvedStatus ?? "Unknown",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
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
              // Navigate to the new screen when the FAB is pressed
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OutOfRouteView(), // Replace with your desired screen
                ),
              );
              if (result != null) {
                // Handle result if needed
              }
            },
            backgroundColor: kColDDSPrimaryDark, // Adjust the color as needed
            child: const Icon(Icons.add), // You can customize the icon here
          ),
        );
      },
    );
  }
}

// class FeedbackView extends StatelessWidget {
//   final AllOutofRoute route;

//   const FeedbackView({Key key, this.route}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Feedback View'),
//       ),
//       body: Center(
//         child: Text('Feedback for route: ${route.customerCode}'),
//       ),
//     );
//   }
// }
