import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/core/enums.dart';
import 'package:distributor/core/helper.dart';
import 'package:distributor/src/ui/common/network_sensitive_widget.dart';
import 'package:distributor/ui/shared/brand_colors.dart';
import 'package:distributor/ui/widgets/action_button.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/dumb_widgets/empty_content_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

import 'order_confirmation_view_model.dart';

class OrderConfirmation extends StatelessWidget {
  final SalesOrderRequest salesOrderRequest;
  final Customer customer;

  const OrderConfirmation(
      {@required this.salesOrderRequest, @required this.customer, Key key})
      : assert(customer != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    bool isConnected = connectionStatus != ConnectivityStatus.Offline;
    final TextStyle textStyle = TextStyle(fontSize: 13, color: Colors.white);
    return ViewModelBuilder<OrderConfirmationViewModel>.reactive(
      viewModelBuilder: () => OrderConfirmationViewModel(
          customer: customer, salesOrderRequest: salesOrderRequest),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          // leading: IconButton(
          //   icon: Icon(FontAwesomeIcons.chevronLeft),
          //   onPressed: () async {
          //     model.navigateToProductSelection();
          //   },
          // ),
          title: Text(
            'Order Summary',
            style: kAppBarTextStyle,
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height - 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              model.enableOffline
                  ? NetworkSensitiveWidget()
                  : Container(
                      height: 0,
                    ),
              Material(
                elevation: 4,
                color: kColorMiniDarkBlue,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Customer'.toUpperCase(),
                            style: textStyle,
                          ),
                          Text(
                            salesOrderRequest.customer,
                            style: textStyle,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Due Date'.toUpperCase(),
                            style: textStyle,
                          ),
                          Text(
                            '${Helper.getDay(salesOrderRequest.dueDate)}',
                            style: textStyle,
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Number Of Items'.toUpperCase(),
                            style: textStyle,
                          ),
                          Text(
                            '${model.salesOrder.items.length}',
                            style: textStyle,
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Remarks'.toUpperCase(),
                            style: textStyle,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: Text(
                              '${salesOrderRequest.remarks}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order Total'.toUpperCase(),
                            style: textStyle,
                          ),
                          Text(
                            '${model.currency} ${Helper.formatCurrency(model.salesOrder.total)}',
                            style: textStyle,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Container(
                child: Expanded(
                  child: model.salesOrder.items.isEmpty
                      ? Center(
                          child: EmptyContentContainer(
                            label: 'There are no items left in the order.',
                          ),
                        )
                      : ListView.separated(
                          itemCount: model.salesOrder.items.length,
                          scrollDirection: Axis.vertical,
                          separatorBuilder: (context, index) {
                            return Divider(
                              height: 2,
                            );
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Container(
                                        child: Text(
                                          '${salesOrderRequest.items[index].quantity}',
                                          style: TextStyle(
                                              color: kColorMiniDarkBlue,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 4.0, left: 4),
                                        child: Text('x'),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${salesOrderRequest.items[index].item.itemName}',
                                      style: TextStyle(
                                          color: Color(0xFF212427),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${Helper.formatCurrency((salesOrderRequest.items[index].quantity * salesOrderRequest.items[index].item.itemPrice))}',
                                        style: TextStyle(
                                            color: Color(0xFF212427),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      ClipOval(
                                        child: InkWell(
                                          onTap: () => model.deleteItem(
                                              salesOrderRequest
                                                  .items[index].item,
                                              salesOrderRequest.items[index]),
                                          splashColor: Colors.pink,
                                          child: Material(
                                            elevation: 4,
                                            type: MaterialType.card,
                                            color: Colors.grey.withOpacity(0.5),
                                            child: SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: Icon(
                                                Icons.delete_forever_sharp,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      model.salesOrder.items.isEmpty ||
                              model.salesOrder.total == 0
                          ? ActionButton(
                              label: 'Back To Place Order',
                              onPressed: model.backToPlaceOrder,
                            )
                          : model.isBusy
                              ? Column(
                                  children: const <Widget>[
                                    BusyWidget(),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text('Please wait..placing order')
                                  ],
                                )
                              : ActionButton(
                                  onPressed: () =>
                                      model.createSalesOrder(isConnected),
                                  label: 'Place Order',
                                ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
