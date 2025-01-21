import 'package:distributor/core/helper.dart';
import 'package:distributor/ui/views/orders/order_detail/order_detail_viewmodel.dart';
import 'package:distributor/ui/views/orders/sales_order_item_list/sales_order_item_list.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/smart_widgets/customer_summary/customer_summary_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class OrderDetailView extends StatelessWidget {
  final SalesOrder salesOrder;
  final DeliveryStop deliveryStop;
  final DeliveryJourney deliveryJourney;
  final String stopId;

  const OrderDetailView(
      {this.salesOrder,
      @required this.deliveryStop,
      @required this.deliveryJourney,
      @required this.stopId,
      Key key})
      : assert(salesOrder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OrderDetailViewModel>.reactive(
      onModelReady: (model) {
        model.init();
      },
      viewModelBuilder: () => OrderDetailViewModel(
          salesOrder: salesOrder,
          deliveryStop: deliveryStop,
          deliveryJourney: deliveryJourney),
      builder: (context, model, child) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            // actions: [
            //   PopupMenuButton(
            //     itemBuilder: (context) {
            //       return <PopupMenuEntry<Object>>[
            //         PopupMenuItem(
            //           child: Text('Full Delivery'),
            //           value: stopId != null ? 'full_delivery' : 'not_possible',
            //         ),
            //         PopupMenuItem(
            //           child: Text('Partial Delivery'),
            //           value:
            //               stopId != null ? 'partial_delivery' : 'not_possible',
            //         ),
            //         PopupMenuDivider(),
            //         PopupMenuItem(
            //           child: Text('Receive Returns'),
            //           value: 'receive_return',
            //         ),
            //         PopupMenuDivider(),
            //         PopupMenuItem(
            //           child: Text('Add Payment'),
            //           value: 'add_payment',
            //         ),
            //       ];
            //     },
            //     onSelected: (x) {
            //       model.handleOrderAction(x);
            //     },
            //   )
            // ],
            title: salesOrder != null
                ? Text(
                    '${salesOrder.customerName}',
                    overflow: TextOverflow.fade,
                  )
                : const Text(''),
            bottom: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              unselectedLabelColor: Colors.white.withOpacity(0.5),
              labelColor: Colors.white,
              indicatorColor: Colors.pink,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              tabs: const <Widget>[
                Tab(
                  text: 'Summary',
                ),
                Tab(
                  text: 'Particulars',
                ),
                // Tab(
                //   text: 'History',
                // )
              ],
            ),
          ),
          body: model.isBusy
              ? const Center(
                  child: BusyWidget(),
                )
              : TabBarView(
                  children: <Widget>[
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                            child: Material(
                              type: MaterialType.card,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          'Order No : ${salesOrder.orderNo}',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          '${salesOrder.orderStatus}'
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.purple,
                                              fontWeight: FontWeight.w700),
                                        )
                                      ],
                                    ),

                                    const Divider(),

                                    Container(
                                      child: Text(
                                          'Order Date: ${Helper.getDay(salesOrder.orderDate)}'),
                                    ),

                                    Container(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          salesOrder.orderStatus
                                                  .contains('To Bill')
                                              ? const Text(
                                                  'Due Date : Delivered')
                                              : Text(
                                                  'Due Date: ${Helper.getDay(salesOrder.dueDate)}')
                                        ],
                                      ),
                                    ),

                                    Text('Branch : ${salesOrder.branch}'),
                                    model.deliveryJourney == null
                                        ? Container()
                                        : Text(
                                            'Route : ${model.deliveryJourney.route}'),

                                    const Divider(),

                                    const SubheadingText('Remarks'),
                                    Text('${salesOrder.remarks}'),

                                    const Divider(),

                                    CustomerSummaryWidget(
                                        salesOrder.customerName),

                                    //@TODO: Add mobile number
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                      child: Material(
                        elevation: 3,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SalesOrderItemList(
                              salesOrderId: model.salesOrder.orderNo,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Container(
                    //   margin: EdgeInsets.fromLTRB(15, 10, 10, 0),
                    //   child: DeliveryNoteView(
                    //     salesOrder: model.salesOrder,
                    //     deliveryStop: deliveryStop,
                    //   ),
                    // )
                  ],
                ),
        ),
      ),
    );
  }
}
