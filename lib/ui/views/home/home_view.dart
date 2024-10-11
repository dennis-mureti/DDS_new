import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/core/enums.dart';
import 'package:distributor/core/helper.dart';
import 'package:distributor/src/ui/common/network_sensitive_widget.dart';
import 'package:distributor/src/ui/views/adhoc_listing/adhoc_listing_view.dart';
import 'package:distributor/src/ui/views/pos/invoicing/invoicing_view.dart';
import 'package:distributor/src/ui/views/quotation_view/quotation_listing_view.dart';
import 'package:distributor/ui/access_controllers/global/bottom_navbar/bottom_nav_bar.dart';
import 'package:distributor/ui/shared/brand_colors.dart';
import 'package:distributor/ui/views/customers/customer_view.dart';
import 'package:distributor/ui/views/dashboard/dashboard_view.dart';
import 'package:distributor/ui/views/home/home_viewmodel.dart';
import 'package:distributor/ui/views/stock/stock_view.dart';
import 'package:distributor/ui/widgets/drawer.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/reactive/transaction_popup/transaction_popup_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

import '../routes/route_listing_view.dart';

class HomeView extends StatelessWidget {
  final int index;

  const HomeView({Key key, this.index}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    return ViewModelBuilder<HomeViewModel>.reactive(
      onModelReady: (model) => model.init(),
      fireOnModelReadyOnce: false,
      disposeViewModel: false,
      createNewModelOnInsert: true,
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          actionsIconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          title: _buildTitle(model.currentIndex),
          actions: <Widget>[
            // ConnectionStatusWidget(syncData: model.syncData),
            // IconButton(
            //   onPressed: () => model.refresh(),
            //   icon: Icon(FontAwesome.refresh),
            // ),
            model.currentIndex == 2
                ? Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          model.navigateToAddAdhocSale();
                          ;
                        },
                        icon: Icon(Icons.add_circle_outline),
                        tooltip: 'Add Adhoc Sale',
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) => <PopupMenuEntry<Object>>[
                          PopupMenuItem(
                            child: Text('Post Sale'),
                            value: 'make_adhoc_sale',
                          ),
                          PopupMenuDivider(),
                          PopupMenuItem(
                            child: Text('Stock Transfer Request'),
                            value: 'stock_transfer_request',
                          ),
                          // PopupMenuDivider(),
                          // PopupMenuItem(
                          //   child: Text('Inter Outlet Transfer Request'),
                          //   value: 'inter_outlet_transfer_request',
                          // )
                        ],
                        onSelected: (val) {
                          model.takeAction(val);
                        },
                      )
                    ],
                  )
                : model.currentIndex == 3
                    ? IconButton(
                        onPressed: () {
                          model.navigateToCreateQuotation();
                        },
                        icon: Icon(Icons.add_circle_outline),
                        tooltip: 'Create Quotation',
                      )
                    : model.currentIndex == 5
                        ? TransactionPopupView(
                            onSelected: model.onStockBalancePopupSelected)
                        : Container(),
            // model.currentIndex == 4
            //     ? IconButton(
            //         icon: Icon(Icons.calendar_month),
            //         onPressed: () async {
            //           var result = await showDateRangePicker(
            //               context: context,
            //               firstDate:
            //                   DateTime.now().subtract(Duration(days: 30)),
            //               lastDate: DateTime.now());
            //           if (result is DateTimeRange) {
            //             model.updateFinalizedOrderRange(result);
            //           }
            //         },
            //       )
            //     : Container()

            // MapIconButton(),
          ],
        ),
        // floatingActionButton: model.currentIndex == 2
        //     ? SpeedDial(
        //         icon: Icons.shopping_cart_outlined,
        //         children: [
        //           SpeedDialChild(
        //             child: Icon(Icons.face),
        //             label: 'Walk In Customer',
        //             backgroundColor: Colors.amberAccent,
        //             onTap: () {/* Do someting */},
        //           ),
        //           SpeedDialChild(
        //             child: Icon(Icons.email),
        //             label: 'Contract Customer',
        //             backgroundColor: Colors.amberAccent,
        //             onTap: () {/* Do something */},
        //           ),
        //         ],
        //       )
        //     : Container(),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.white,
            visualDensity: VisualDensity.compact,
          ),
          child: BottomNavBar(
            homeViewModel: model,
            onTap: model.updateCurrentIndex,
            index: index,
          ),
        ),
        drawer: Drawer(
          child: CustomDrawer(),
        ),
        backgroundColor:
            model.currentIndex != 0 ? backgroundColor : Colors.white,
        body: model.isBusy
            ? Center(
                child: BusyWidget(),
              )
            : _buildContent(model.currentIndex, model),
      ),
      viewModelBuilder: () => HomeViewModel(index, connectionStatus),
    );
  }

  _buildContent(int index, HomeViewModel model) {
    switch (index) {
      case 0:
        return Stack(
          children: [
            DashboardView(),
          ],
        );
        break;
      case 1:
        return Column(
          children: [
            // LocationWidget(),
            Expanded(child: RoutesListingView()),
            model.enableOffline ? NetworkSensitiveWidget() : Container(),
          ],
        );
        break;
      case 2:
        return Column(
          children: [
            Expanded(child: AdhocListingView()),
            model.enableOffline ? NetworkSensitiveWidget() : Container(),
          ],
        );
        break;
      case 3:
        return Column(
          children: [
            Expanded(child: QuotationListingView()),
            model.enableOffline ? NetworkSensitiveWidget() : Container(),
          ],
        );
        break;
      case 4:
        return Column(
          children: [
            Expanded(
              child: InvoicingView(),
            ),
            model.enableOffline ? NetworkSensitiveWidget() : Container(),
          ],
        );
        break;
      case 5:
        return Column(
          children: [
            Expanded(child: StockView()),
          ],
        );
        break;
      case 6:
        return Column(
          children: [
            // LocationWidget(),
            Expanded(child: CustomerView()),
            model.enableOffline ? NetworkSensitiveWidget() : Container(),
          ],
        );
        break;
      default:
        return Stack(
          children: [
            // NetworkSensitiveWidget(),
            // LocationWidget(),
            DashboardView(),
          ],
        );
        break;
    }
  }

  _buildTitle(int index) {
    switch (index) {
      case 0:
        return Text(
          'Home',
          style: kAppBarTextStyle,
        );
        break;
      case 1:
        return Text(
          'Journey',
          style: kAppBarTextStyle,
        );
        break;
      case 2:
        return Text(
          'Selling',
          style: kAppBarTextStyle,
        );
        break;
      case 3:
        return Text(
          'Quotations',
          style: kAppBarTextStyle,
        );
        break;
      case 4:
        return Text(
          'Invoicing',
          style: kAppBarTextStyle,
        );
        break;
      case 5:
        return Text(
          'Stock Balance',
          style: kAppBarTextStyle,
        );
        break;
      case 6:
        return Text(
          'Customers',
          style: kAppBarTextStyle,
        );
        break;
      default:
        return Text(
          'Home',
          style: kAppBarTextStyle,
        );
        break;
    }
  }
}

class ShowDateFilter extends HookViewModelWidget<HomeViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, HomeViewModel model) {
    return TextButton(
      child: Row(
        children: [
          Text(
            Helper.formatDate(model.startDate),
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(width: 5),
          Icon(
            Icons.calendar_today,
            color: Colors.black,
          ),
        ],
      ),
      onPressed: () async {
        await showModalBottomSheet(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      Text('Select A Date'),
                      Row(
                        children: [
                          Container(
                            child: Text('Date'),
                            width: 100,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${Helper.formatDate(model.startDate)}'),
                                IconButton(
                                  icon: Icon(Icons.calendar_today),
                                  onPressed: () async {
                                    var result = await showDatePicker(
                                        context: context,
                                        initialDate: model.startDate,
                                        firstDate: DateTime.now()
                                            .subtract(Duration(days: 365)),
                                        lastDate: DateTime.now());
                                    if (result is DateTime) {
                                      model.setStartDate(result);
                                      setState(() {});
                                      model.commitDateSelection();
                                    }
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      // FlatButtonWidget(
                      //     label: 'Go', onTap: model.commitDateSelection)
                    ],
                  ),
                );
              });
            });
      },
    );
  }
}
