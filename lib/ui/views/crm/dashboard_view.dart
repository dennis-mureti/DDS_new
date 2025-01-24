import 'package:distributor/ui/views/crm/activities/activities_view.dart';
import 'package:distributor/ui/views/crm/dashboard_tiles.dart';
import 'package:distributor/ui/views/crm/dashboard_viewmodel.dart';
import 'package:distributor/ui/views/crm/outofRoute/outofroutes/all_out-of-routes.dart';
import 'package:distributor/ui/views/crm/planner/planner.dart';
import 'package:distributor/ui/views/crm/visits/completed/completed_view.dart';
import 'package:distributor/ui/views/crm/visits/details/details_view.dart';
import 'package:distributor/ui/views/crm/visits/pending/pending_visits_view.dart';
import 'package:distributor/ui/views/customers/customer_view.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import '../../../conf/dds_brand_guide.dart';

class CRMDashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CRMDashboardViewModel>.reactive(
      onModelReady: (model) async {
        await model.loadDayState();
        model.init();
      },
      builder: (context, model, child) {
        if (model.isBusy) {
          return const Center(child: BusyWidget());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _onRefresh(model); // Trigger the refresh logic
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kColDDSPrimaryDark, Color(0xFF4B6CB7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with User Details
                Container(
                  margin: const EdgeInsets.all(15.0),
                  child: _buildUserDetail(model),
                ),
                Expanded(
                  child: _buildDashboardGrid(model),
                ),
                _buildStartDayButton(model, context),
              ],
            ),
          ),
        );
      },
      viewModelBuilder: () => CRMDashboardViewModel(),
    );
  }

  // The method to handle the refresh logic
  Future<void> _onRefresh(CRMDashboardViewModel model) async {
    // Reset the data or fetch new data
    await model.loadDayState(); // Example of refreshing the data
    model.init(); // Reinitialize or refresh the view model data
  }

  Widget _buildDashboardGrid(CRMDashboardViewModel model) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          padding: const EdgeInsets.all(10.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15.0,
            mainAxisSpacing: 15.0,
            childAspectRatio: 1.1,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            final title = _getTitle(index);
            final icon = _getIcon(index);
            final number = _getNumberForTitle(model, title);

            // Disable tile interaction if day is not started
            final isTileEnabled = model.isDayStarted;

            return GestureDetector(
              onTap: isTileEnabled
                  ? () async {
                      await _onTilePressed(context, title);
                    }
                  : null,
              child: DashboardTile(
                icon: icon,
                title: title,
                number: number.toString(),
                onActionPressed: isTileEnabled
                    ? () async {
                        await _onTilePressed(context, title);
                      }
                    : null,
                isDayStarted: model.isDayStarted,
                color: isTileEnabled ? null : Colors.grey.shade200,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStartDayButton(
      CRMDashboardViewModel model, BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: ElevatedButton(
        onPressed: () {
          // Toggle the day state and trigger start/end logic
          model.toggleDay(context);
        },
        style: ElevatedButton.styleFrom(
          primary:
              model.isDayStarted ? Colors.red.shade700 : Colors.blue.shade900,
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              model.isDayStarted ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
              size: 24.0,
            ),
            const SizedBox(width: 8.0),
            Text(
              model.isDayStarted ? 'End Day' : 'Start Day',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetail(CRMDashboardViewModel model) {
    final String todayDate =
        DateFormat('EEEE, MMM dd, yyyy').format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          todayDate,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Welcome back, ${model.user.full_name}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _onTilePressed(BuildContext context, String title) async {
    final model = context.read<CRMDashboardViewModel>();
    if (!model.isDayStarted) {
      _showStartDayDialog(context);
      return;
    }

    // Original tile navigation logic
    if (title == 'Scheduled Visits') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScheduleDetailsView(),
        ),
      );
    } else if (title == 'Completed Visits') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompleteVisitsView(),
        ),
      );
    } else if (title == 'Checkin Activities') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActivitiesView(),
        ),
      );
    } else if (title == 'Planner') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlannerPage(),
        ),
      );
    } else if (title == 'Customer Info') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Customer Info'),
            ),
            body: CustomerView(),
          ),
        ),
      );
    } else if (title == 'Out of Route') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OutOfRoutesView(),
        ),
      );
    } else if (title == 'Pending Visits') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PendingVisitsView(),
        ),
      );
    } else {
      print("Action pressed for $title");
    }
  }

  void _showStartDayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Day Not Started"),
          content: const Text("Please start the day before proceeding."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Getters for the icons and titles
  IconData _getIcon(int index) {
    const icons = [
      Icons.request_quote_outlined,
      Icons.watch_later_outlined,
      Icons.chat_outlined,
      Icons.edit_calendar_outlined,
      Icons.calendar_month,
      Icons.fact_check_outlined,
    ];
    return icons[index % icons.length];
  }

  String _getTitle(int index) {
    const titles = [
      'Customer Info',
      'Scheduled Visits',
      'Completed Visits',
      'Pending Visits',
      'Out of Route',
      'Planner',
    ];
    return titles[index % titles.length];
  }

  int _getNumberForTitle(CRMDashboardViewModel model, String title) {
    switch (title) {
      case 'Customer Info':
        return model.getCustomerCount();
      case 'Scheduled Visits':
        return model.getScheduledVisitsCount();
      case 'Completed Visits':
        return model.getCompletedVisitsCount();
      case 'Pending Visits':
        return model.getPendingVisitsCount();
      case 'Out of Route':
        return model.getOutOfRouteCount();
      case 'Planner':
        return 0; // Placeholder for Planner count
      default:
        return 0;
    }
  }
}
