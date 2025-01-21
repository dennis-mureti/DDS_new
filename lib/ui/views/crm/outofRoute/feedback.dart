import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/ui/views/crm/outofRoute/out_of_request_view_model.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class FeedbackView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final int visitId;

  FeedbackView({Key key, this.visitId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OutOfRouteViewModel>.reactive(
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Feedback'),
            backgroundColor: kColDDSPrimaryDark,
          ),
          body: model.isBusy
              ? const Center(child: BusyWidget())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Check-in details at the top
                      _buildCheckInDetails(model),
                      const SizedBox(height: 16),
                      if (model.isCheckedIn) ...[
                        const Text(
                          'Out of Route Feedback',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: model.feedbackController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Enter your feedback here...',
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Feedback cannot be empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Check-in/Check-out button
                      ElevatedButton(
                        onPressed: () {
                          if (model.isCheckedIn) {
                            // Enforce feedback before checkout
                            if (model.feedbackController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please provide feedback before checking out.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              // Proceed to check out
                              model.toggleCheckin(context, visitId);
                            }
                          } else {
                            // Check-in action
                            model.toggleCheckin(context, visitId);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary:
                              model.isCheckedIn ? Colors.red : Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: model.isBusy
                            ? const BusyWidget()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    model.isCheckedIn
                                        ? 'Check Out'
                                        : 'Check In',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
        );
      },
      viewModelBuilder: () => OutOfRouteViewModel(),
    );
  }

  // Widget _buildCheckInDetails(OutOfRouteViewModel model) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         _buildInfoColumn(
  //           title: 'Check In',
  //           value: model.isCheckedIn && model.checkInTime != null
  //               ? DateFormat('hh:mm a').format(model.checkInTime)
  //               : 'Start',
  //         ),
  //         _buildInfoColumn(
  //           title: 'Duration',
  //           value: model.duration,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildInfoColumn({String title, String value}) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         title,
  //         style: const TextStyle(color: Colors.black, fontSize: 16),
  //       ),
  //       const SizedBox(height: 5),
  //       Text(
  //         value,
  //         style: const TextStyle(
  //           color: Colors.grey,
  //           fontSize: 15,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildCheckInDetails(OutOfRouteViewModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDetailColumn(
              'Check In',
              model.isCheckedIn
                  ? 'Check-In in Progress'
                  : (model.checkInTime != null
                      ? DateFormat('hh:mm a').format(model.checkInTime)
                      : 'Start')),
          _buildDetailColumn(
            'Duration',
            model.isCheckedIn
                ? 'Check-In in Progress'
                : model.duration ?? '0 min',
          ),
        ],
      ),
    );
  }

  Column _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontSize: 16)),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
                color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
