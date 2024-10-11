import 'package:distributor/ui/shared/text_styles.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/smart_widgets/stops_widget/stop_list_tile/stop_list_tile.dart';
import 'package:distributor/ui/widgets/smart_widgets/stops_widget/stops_list_widget_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class StopsListWidget extends StatelessWidget {
  final DeliveryJourney deliveryJourney;

  const StopsListWidget({this.deliveryJourney, Key key})
      : assert(deliveryJourney != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StopsListWidgetViewModel>.reactive(
        onModelReady: (model) => model.getJourneyDetails(),
        builder: (context, model, child) => model.isBusy
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: BusyWidget(),
                ),
              )
            : ListView(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                // mainAxisSize: MainAxisSize.max,
                children: model.deliveryJourney.stops
                    .map((DeliveryStop deliveryStop) {
                  return _buildWidget(deliveryStop, deliveryJourney, model);
                  // return StopListTile(
                  //   salesOrderId: deliveryStop.orderId,
                  //   deliveryJourney: deliveryJourney,
                  //   deliveryStop: deliveryStop,
                  // );
                }).toList()),
        viewModelBuilder: () =>
            StopsListWidgetViewModel(journeyId: deliveryJourney.journeyId));
  }

  Widget _buildWidget(DeliveryStop deliveryStop,
      DeliveryJourney deliveryJourney, StopsListWidgetViewModel model) {
    if (deliveryStop.isTechnicalStop == 1) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Material(
          elevation: 1,
          child: ListTile(
            onTap: () async {
              await model.navigateToTechnicalStop(deliveryStop);
              await model.getJourneyDetails();
              model.notifyListeners();
            },
            subtitle: deliveryStop.isVisited == 1
                ? Text('Completed')
                : Text('Pending'),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ADDITIONAL',
                  style: kSalesOrderIdTextStyle,
                ),
                Text(
                  deliveryStop.stopAtBranchId,
                  style: kCustomerNameTextStyle,
                ),
              ],
            ),
          ),
        ),
      );
    } else if (deliveryStop.orderId.isNotEmpty) {
      //Return a stop tile widget
      return StopListTile(
          salesOrderId: deliveryStop.orderId,
          deliveryJourney: deliveryJourney,
          deliveryStop: deliveryStop);
    } else {
      return Container();
    }
  }
}
