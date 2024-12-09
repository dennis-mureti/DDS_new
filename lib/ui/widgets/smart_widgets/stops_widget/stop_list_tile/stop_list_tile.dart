import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/smart_widgets/stops_widget/stop_list_tile/stop_list_tile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class StopListTile extends StatelessWidget {
  final String salesOrderId;
  final DeliveryJourney deliveryJourney;
  final DeliveryStop deliveryStop;
  const StopListTile(
      {@required this.salesOrderId,
      @required this.deliveryJourney,
      @required this.deliveryStop,
      Key key})
      : assert(salesOrderId != null, deliveryStop != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StopListTileViewModel>.reactive(
      onModelReady: (model) => model.init(),
      viewModelBuilder: () => StopListTileViewModel(deliveryJourney.journeyId,
          salesOrderId: salesOrderId, deliveryStop: deliveryStop),
      builder: (context, model, child) => model.deliveryNote == null
          ? Center(child: BusyWidget())
          : Container(
              // margin: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Material(
                type: MaterialType.card,
                // elevation: 1,
                child: ListTile(
                  visualDensity: VisualDensity.compact,
                  onTap: () async {
                    await model.navigateToDeliveryDetailView(
                        deliveryJourney, deliveryStop);
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        model.deliveryStop.deliveryNoteId,
                        style: kTileLeadingTextStyle,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          model.deliveryStop.customerId,
                          style: kTileLeadingSecondaryTextStyle,
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      model.deliveryNote.isSynced
                          ? Text(
                              '${model.deliveryStop.orderStatus}'.toUpperCase(),
                              style: kTileSubtitleTextStyle,
                            )
                          : Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  model.deliveryNote.deliveryStatus,
                                  style: kTileSubtitleTextStyle,
                                ),
                              ],
                            ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
