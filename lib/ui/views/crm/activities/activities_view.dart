import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/ui/views/crm/activities/activities_view_model.dart';
import 'package:distributor/ui/views/crm/checkin/checkin_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';

class ActivitiesView extends StatefulWidget {
  final int visitId;
  final String customerName;

  const ActivitiesView({Key key, this.visitId, this.customerName})
      : super(key: key);

  @override
  _ActivitiesViewState createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<ActivitiesView> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ActivitiesViewModel>.reactive(
      onModelReady: (model) {
        // Initialize or fetch data if needed.
      },
      builder: (context, model, child) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Activities',
              style: TextStyle(fontSize: 20),
            ),
            backgroundColor: kColDDSPrimaryDark,
            elevation: 0,
          ),
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Background gradient
              Container(
                width: double.infinity,
                height: screenHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kColDDSPrimaryDark, Color(0xFF4B6CB7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            topLeft: Radius.circular(20.0),
                          ),
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              _buildCheckInDetails(model),
                              const SizedBox(height: 8),
                              const Divider(
                                color: Colors.black,
                                thickness: 0.5,
                                indent: 20.0,
                                endIndent: 20.0,
                              ),
                              const SizedBox(height: 20),
                              _buildActivityButtons(context, model),
                              const SizedBox(height: 20),
                              _buildActionButtons(context, model),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      viewModelBuilder: () => ActivitiesViewModel(),
    );
  }

  Widget _buildCheckInDetails(ActivitiesViewModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoColumn(
            title: 'Check In',
            value: model.isCheckedIn && model.checkInTime != null
                ? DateFormat('hh:mm a').format(model.checkInTime)
                : 'Start',
          ),
          _buildInfoColumn(
            title: 'Duration',
            value: model.duration,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({@required String title, @required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityButtons(
      BuildContext context, ActivitiesViewModel model) {
    const activities = [
      ['Unavailable', Icons.block],
      ['In Stock', Icons.check_circle],
      ['SOS', Icons.warning],
      ['Activation', Icons.flash_on],
      ['Price Compliance', Icons.attach_money],
      ['Issues', Icons.report_problem],
      ['Feedback', Icons.feedback],
      ['Schedule', Icons.calendar_today],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.customerName != null) // Check if customerName is provided
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              widget.customerName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.5,
          ),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return ElevatedButton.icon(
              onPressed: () {
                if (activity[0] == 'Feedback') {
                  _showFeedbackDialog(context, model);
                } else if (activity[0] == 'In Stock') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckInView(
                        customerName: widget.customerName,
                      ),
                    ),
                  );
                } else {
                  print("Action pressed for ${activity[0]}");
                }
              },
              icon: Icon(activity[1], size: 20),
              label: Text(activity[0]),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue[100],
                onPrimary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ActivitiesViewModel model) {
    return ElevatedButton.icon(
      onPressed: () => model.toggleCheckin(
        context,
        widget.visitId,
      ),
      icon: Icon(
        model.isCheckedIn ? Icons.logout : Icons.login,
        color: Colors.black,
      ),
      label: Text(
        model.isCheckedIn ? 'Check Out' : 'Check In',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: model.isCheckedIn ? Colors.red : Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, ActivitiesViewModel model) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submit Feedback'),
          content: TextField(
            controller: _feedbackController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Enter your feedback here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_feedbackController.text.isNotEmpty) {
                  model.saveFeedback(_feedbackController.text);
                  _feedbackController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Feedback saved successfully!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: kColDDSPrimaryDark,
                // padding: const EdgeInsets.symmetric(vertical: 15.0),
                // minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
