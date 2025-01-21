import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:tripletriocore/tripletriocore.dart';

class OrderHistoryTile extends StatelessWidget {
  final onTap;
  final SalesOrder salesOrder;
  final DeliveryJourney deliveryJourney;

  const OrderHistoryTile(this.onTap, this.salesOrder, this.deliveryJourney,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSynced = !salesOrder.orderNo.toLowerCase().contains("off");
    return Material(
      type: MaterialType.card,
      elevation: 2.0,
      child: ListTile(
        onTap: () async {
          onTap(salesOrder, deliveryJourney, null);
        },
        isThreeLine: true,
        subtitle: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
              // 'Order Date : ${Helper.getDay(salesOrder.orderDate.toString())} \nDue Date : ${Helper.getDay(salesOrder.dueDate.toString())}'),
              'Order Date : ${salesOrder.orderDate.toString()} \nDue Date : ${salesOrder.dueDate.toString()}'),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                isSynced
                    ? Container(
                        width: 0,
                      )
                    : const Icon(
                        (Icons.timer_sharp),
                        size: 16,
                      ),
                Text(
                  '${salesOrder.orderNo}',
                  style: kTileLeadingTextStyle,
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${salesOrder.orderStatus.toUpperCase()}',
                  style: kTileLeadingSecondaryTextStyle.copyWith(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
