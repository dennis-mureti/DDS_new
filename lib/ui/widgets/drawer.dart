import 'package:distributor/conf/style/lib/colors.dart';
import 'package:distributor/ui/views/home/home_viewmodel.dart';
import 'package:distributor/ui/widgets/drawer_button/drawer_secondary_button.dart';
import 'package:distributor/ui/widgets/dumb_widgets/drawer_listTile.dart';
import 'package:flutter/material.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

import '../../conf/dds_brand_guide.dart';

class CustomDrawer extends HookViewModelWidget<HomeViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, HomeViewModel model) {
    return Container(
      decoration: BoxDecoration(
        color: kColorNeutral,
        // image: DecorationImage(
        //   image: AssetImage('assets/images/dds_logo.png'),
        //   opacity: 0.2,
        //   alignment: Alignment.bottomCenter,
        // ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: kColorDDSPrimaryDark),
            width: MediaQuery.of(context).size.width * .15,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DrawerSecondaryButton(
                  iconData: Icons.help,
                  onTap: model.navigateToHelpView,
                ),
                DrawerSecondaryButton(
                  iconData: Icons.info,
                  onTap: model.navigateToInfoView,
                ),
                DrawerSecondaryButton(
                  iconData: Icons.bug_report_sharp,
                  onTap: model.navigateToBugView,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                    child: Row(
                  children: <Widget>[
                    Expanded(
                      child: UserAccountsDrawerHeader(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        accountEmail: Text(
                          '${model.user.email ?? model.user.mobile}',
                          style: TextStyle(color: Colors.black),
                        ),
                        accountName: Text(
                          '${model.user.full_name}',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                )),
                DrawerListTile(
                  isEnabled: model.enableHomeTab,
                  label: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    model.navigateToHome(0);
                  },
                  iconData: Icons.home,
                ),
                DrawerListTile(
                  label: 'Journey',
                  onTap: () {
                    Navigator.pop(context);
                    model.navigateToHome(1);
                  },
                  iconData: Icons.swap_calls,
                  isEnabled: model.enableJourneyTab,
                ),
                // DrawerListTile(
                //   label: 'Territories',
                //   onTap: () {
                //     Navigator.pop(context);
                //     model.navigateToTerritoryView();
                //   },
                //   iconData: Icons.fence,
                //   isEnabled: model.user.fences.isNotEmpty,
                // ),
                DrawerListTile(
                  isEnabled: model.enableAdhocTab,
                  label: 'Selling',
                  onTap: () {
                    Navigator.pop(context);
                    model.navigateToHome(2);
                  },
                  iconData: Icons.add_shopping_cart,
                ),
                DrawerListTile(
                  isEnabled: model.enableProductTab,
                  label: 'Stock Controller',
                  onTap: () {
                    Navigator.pop(context);
                    model.navigateToHome(3);
                  },
                  iconData: Icons.apps,
                ),

                DrawerListTile(
                  isEnabled: model.enableCustomerTab,
                  label: 'Customers',
                  onTap: () {
                    Navigator.pop(context);
                    model.navigateToHome(4);
                  },
                  iconData: Icons.people,
                ),
                // ListTile(
                //   trailing: Icon(Icons.notifications),
                //   title: Text('Notifications'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     model.navigateToHome(5);
                //   },
                // ),
                Divider(),

                // ListTile(
                //   title: Text(
                //     'SYNC DATA',
                //     style: TextStyle(
                //         fontFamily: 'NerisBlack', color: kColDDSPrimaryDark),
                //   ),
                //   onTap: () async {
                //     Navigator.pop(context);
                //     model.syncData();
                //   },
                // ),

                ListTile(
                  title: Text(
                    'CHANGE PASSWORD',
                    style: TextStyle(
                        fontFamily: 'NerisBlack', color: kColDDSPrimaryDark),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    model.navigateToChangePassword();
                  },
                ),

                ListTile(
                  title: Text(
                    'LOG OUT',
                    style: TextStyle(
                        fontFamily: 'NerisBlack', color: kColDDSPrimaryDark),
                  ),
                  onTap: () async {
                    model.logout();
                  },
                ),
                // Center(
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Text(model.appEnv.name),
                //   ),
                // ),
                //
                // Center(
                //   child: Padding(
                //     child: Text('Version : ${model.version}'),
                //     padding: const EdgeInsets.all(8.0),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
