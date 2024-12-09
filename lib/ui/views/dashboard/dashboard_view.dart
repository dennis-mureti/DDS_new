import 'package:distributor/ui/views/dashboard/dashboard_viewmodel.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/dumb_widgets/shop_name.dart';
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
            ? Center(child: BusyWidget())
            : Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [kColDDSPrimaryDark, Color(0xFF4B6CB7)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 20.0, bottom: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            UIHelper.verticalSpaceLarge,
                            _buildUserDetail(model)
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  topLeft: Radius.circular(20.0)),
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
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(5.0),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          child: Text(
                                            "Today\'s Summary".toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'NerisBlack',
                                                color: kColDDSPrimaryLight),
                                          ),
                                        ),
                                        Spacer(),
                                        Container(
                                          child: Text(
                                            '${model.formattedDate}',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontFamily: 'NerisBlack',
                                                color: kColDDSPrimaryDark),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    color: Colors.transparent,
                                    height: 10,
                                  ),

                                  //Display the shop details

                                  model.showShop
                                      ? ShopNameWidget(
                                          storeName: model.salesChannel)
                                      : Container(),
                                  DashboardViewControllerView(),
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
      style: TextStyle(
          color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w500),
    );
  }
}
