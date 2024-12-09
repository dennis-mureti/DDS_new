import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/ui/views/crm/activities/activities_view_model.dart';
import 'package:distributor/ui/views/crm/checkin/checkin_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';

class ActivitiesView extends StatefulWidget {
  final int visitId;
  const ActivitiesView({Key key, this.visitId}) : super(key: key);

  @override
  _ActivitiesViewState createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<ActivitiesView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ActivitiesViewModel>.reactive(
      onModelReady: (model) async {
        // You can call async methods in initState or onModelReady but avoid blocking the UI thread
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

                              // Divider below check-in details
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                child: Divider(
                                  color: Colors.black,
                                  thickness: 0.5,
                                ),
                              ),

                              const SizedBox(height: 20),
                              _buildActivityButtons(context),
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

              // Overlay BusyWidget when loading
              // if (model.isBusy)
              //   Container(
              //     color: Colors.black.withOpacity(0.5),
              //     child: const Center(child: BusyWidget()),
              //   ),
            ],
          ),
        );
      },
      viewModelBuilder: () => ActivitiesViewModel(),
    );
  }

  // Widget for the check-in details
  Widget _buildCheckInDetails(ActivitiesViewModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Check In',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                model.isCheckedIn && model.checkInTime != null
                    ? DateFormat('hh:mm a').format(model.checkInTime)
                    : 'Start',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Duration',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                model.duration,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget for the activity buttons
  Widget _buildActivityButtons(BuildContext context) {
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

    return GridView.builder(
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
          onPressed: () async {
            if (activity[0] == 'In Stock') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckInView(),
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
    );
  }

  // Widget for the action buttons
  Widget _buildActionButtons(BuildContext context, ActivitiesViewModel model) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_a_photo, color: Colors.white),
          label: const Text('Add shelf image'),
          style: ElevatedButton.styleFrom(
            primary: Colors.blue.shade700,
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Divider(
            color: Colors.black,
            thickness: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        // ElevatedButton.icon(
        //   // onPressed: model.toggleCheckin(),
        //   onPressed: () =>
        //       model.toggleCheckin(context, visit.visitId.toString()),
        //   icon: Icon(
        //     model.isCheckedIn ? Icons.logout : Icons.login,
        //     color: Colors.black,
        //   ),
        //   label: Text(
        //     model.isCheckedIn ? 'Check Out' : 'Check In',
        //     style: const TextStyle(
        //         color: Colors.black, fontWeight: FontWeight.bold),
        //   ),
        //   style: ElevatedButton.styleFrom(
        //     primary: model.isCheckedIn ? Colors.red : Colors.green,
        //     padding: const EdgeInsets.symmetric(vertical: 15.0),
        //     minimumSize: const Size(double.infinity, 50),
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(10.0),
        //     ),
        //   ),
        // ),
        ElevatedButton.icon(
          onPressed: () => model.toggleCheckin(context, widget.visitId),
          icon: Icon(
            model.isCheckedIn ? Icons.logout : Icons.login,
            color: Colors.black,
          ),
          label: Text(
            model.isCheckedIn ? 'Check Out' : 'Check In',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            primary: model.isCheckedIn ? Colors.red : Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ],
    );
  }
}
