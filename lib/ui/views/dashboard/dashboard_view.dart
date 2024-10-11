import 'package:distributor/src/ui/views/pos/shared/dashboard_cta.dart';
import 'package:distributor/ui/views/dashboard/dashboard_viewmodel.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/smart_widgets/dashboard_controller/dashboard_view_controller_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

import '../../../conf/dds_brand_guide.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
        onModelReady: (model) => model.init(),
        builder: (context, model, child) => model.isBusy
            ? const Center(child: BusyWidget())
            : Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [kColDDSPrimaryDark, Color(0xFF4B6CB7)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // UIHelper.verticalSpaceLarge,
                            _buildUserDetail(model)
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20.0),
                                topLeft: Radius.circular(20.0),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  5.0, 10.0, 5.0, 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Center(
                                    child: Container(
                                      height: 2.0,
                                      width: 50.0,
                                    ),
                                  ),

                                  model.isMiniShop
                                      ? Container(
                                          height: 40,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Outlet : ${model.user.salesChannel}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        )
                                      : DashboardViewControllerView(),
                                  model.isMiniShop
                                      ? Container(
                                          height: 330,
                                          child: GridView.count(
                                            crossAxisCount: 3,
                                            children: [
                                              DashboardCTAButton(
                                                  color: Colors.red,
                                                  label: 'Post Sale',
                                                  onTap: () =>
                                                      // model.navigateToPostSale(),
                                                      model
                                                          .navigateToAddAdhocSale()),
                                              DashboardCTAButton(
                                                label: 'Create Quotation',
                                                color: Colors.orange,
                                                onTap: () => model
                                                    .navigateToCreateQuotationView(),
                                              ),
                                              DashboardCTAButton(
                                                label: 'View Invoices',
                                                color: Colors.yellow,
                                                onTap: () => model
                                                    .navigateToInvoicingView(),
                                              ),
                                              DashboardCTAButton(
                                                label: 'Stock Transfer Request',
                                                color: Colors.green,
                                                onTap: () => model
                                                    .navigateToStockTransferRequest(),
                                              ),
                                              DashboardCTAButton(
                                                label: 'Receive Stocks',
                                                color: Colors.blue,
                                                onTap: () => model
                                                    .navigateToStockTransferRequest(),
                                              ),
                                              // DashboardCTAButton(
                                              //     label: 'InterOutlet Stock Request',
                                              //     onTap: () => model
                                              //         .navigateToStockTransferRequest()),
                                              DashboardCTAButton(
                                                  color: Colors.purple,
                                                  label: 'Pending Transactions',
                                                  onTap: () => model
                                                      .navigateToPendingTransactions()),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: Container(
                                  //     child: Row(
                                  //       children: [
                                  //         Text(
                                  //           "Reports".toUpperCase(),
                                  //           style: TextStyle(
                                  //               fontSize: 13,
                                  //               // fontFamily: 'NerisBlack',
                                  //               color: kColDDSPrimaryLight),
                                  //         ),
                                  //         Spacer(),
                                  //         GestureDetector(
                                  //           child: Text('View All'),
                                  //           onTap: () =>
                                  //               model.navigateToSalesTab(),
                                  //         )
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: Container(
                                  //     child: Row(
                                  //       children: [
                                  //         Text(
                                  //           "Day Summary".toUpperCase(),
                                  //           style: TextStyle(
                                  //               fontSize: 13,
                                  //               // fontFamily: 'NerisBlack',
                                  //               color: kColDDSPrimaryLight),
                                  //         ),
                                  //         Spacer(),
                                  //         GestureDetector(
                                  //           child: Text('View All'),
                                  //           onTap: () =>
                                  //               model.navigateToSalesTab(),
                                  //         )
                                  //       ],
                                  //     ),
                                  //   ),
                                  // )

                                  // DashboardViewControllerView(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        viewModelBuilder: () => DashboardViewModel());
  }

  _buildUserDetail(DashboardViewModel model) {
    return Text(
      'Welcome back' + ', ${model.user.full_name}',
      style: const TextStyle(
          color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.w500),
    );
  }
}
