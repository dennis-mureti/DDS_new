import 'package:distributor/ui/views/crm/outofRoute/outofroutes/out_of_route_view_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/views/crm/outofRoute/feedback.dart';
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

                      // Determine the status color for approvedStatus
                      Color statusColor;
                      if (route.approvedStatus == "PENDING") {
                        statusColor = Colors.red;
                      } else if (route.approvedStatus == "APPROVED") {
                        statusColor = Colors.green;
                      } else {
                        statusColor = Colors.green;
                      }

                      // Determine the color for visitStatus
                      Color visitStatusColor;
                      switch (route.visitStatus) {
                        case "SCHEDULED":
                          visitStatusColor = Colors.black;
                          break;
                        case "COMPLETED":
                          visitStatusColor = Colors.blue;
                          break;
                        case "STARTED":
                          visitStatusColor = Colors.orange;
                          break;
                        case "APPROVED":
                          visitStatusColor = Colors.green;
                          break;
                        default:
                          visitStatusColor = Colors.grey; // Default color
                          break;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0, top: 10),
                        child: InkWell(
                          onTap: () async {
                            // Check if there is any started visit
                            bool hasStartedVisit = model.outOfRoutesList
                                .any((r) => r.visitStatus == "STARTED");

                            if (route.visitStatus == "SCHEDULED" &&
                                hasStartedVisit) {
                              // Show dialog if a visit is already started
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Check-in not allowed"),
                                    content: const Text(
                                        "Not allowed to proceed with this visit because you have another visit started."),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return; // Early return, do not navigate
                            }

                            // Allow navigation for "STARTED" visits
                            if (route.visitStatus == "STARTED") {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FeedbackView(
                                    visitId: route.requestId,
                                  ),
                                ),
                              );
                              if (result is AllOutofRoute) {
                                onTileTap(result); // Handle tile tap callback
                              }
                            }

                            // Allow navigation for "SCHEDULED" visits if no started visits exist
                            if (route.visitStatus == "SCHEDULED" &&
                                !hasStartedVisit) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FeedbackView(
                                    visitId: route.requestId,
                                  ),
                                ),
                              );
                              if (result is AllOutofRoute) {
                                onTileTap(result); // Handle tile tap callback
                              }
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
                                const SizedBox(height: 8),
                                // New Row: Visit Status
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    route.visitStatus ?? "No Status",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          visitStatusColor, // Set dynamic color
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  route.visitStatus?.toLowerCase() ==
                                          "completed"
                                      ? "Check-in not allowed for completed visits"
                                      : "Proceed to Check-in",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: route.visitStatus?.toLowerCase() ==
                                            "completed"
                                        ? Colors.red
                                        : Colors.green,
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
