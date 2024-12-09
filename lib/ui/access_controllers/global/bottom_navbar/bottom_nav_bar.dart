import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/conf/style/lib/colors.dart';
import 'package:distributor/ui/access_controllers/global/bottom_navbar/bottom_navbar_viewmodel.dart';
import 'package:distributor/ui/views/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class BottomNavBar extends StatelessWidget {
  final int index;
  final Function onTap;
  final HomeViewModel homeViewModel;
  const BottomNavBar(
      {@required this.onTap, @required this.homeViewModel, this.index, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BottomNavBarViewModel>.reactive(
      onModelReady: (model) => model.init(),
      builder: (context, model, child) => BottomNavigationBar(
          elevation: 4,
          // fixedColor: Colors.pink,
          iconSize: 19,
          type: BottomNavigationBarType.fixed,
          currentIndex: model.index,
          selectedIconTheme: IconThemeData(color: kColDDSPrimaryDark, size: 30),
          unselectedIconTheme:
              (IconThemeData(color: kColorLabelColor1.withOpacity(0.45))),
          showUnselectedLabels: false,
          showSelectedLabels: false,
          selectedLabelStyle:
              TextStyle(color: Colors.pink, fontWeight: FontWeight.w900),
          unselectedLabelStyle: TextStyle(color: Colors.indigo),
          items: [
            BottomNavigationBarItem(
              backgroundColor: Color(0xFF182848),
              icon: IconButton(
                splashColor: kColorDDSPrimaryDark,
                icon: Icon(Icons.home),
                onPressed: model.onJourneyTabTap()
                    ? () {
                        model.updateIndex(0);
                        onTap(model.index);
                        // onTap(Pages.routes, "Routes");
                      }
                    : null,
              ),
              label: 'Home'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              backgroundColor: Color(0xFF182848),
              icon: IconButton(
                splashColor: kColorDDSPrimaryDark,
                icon: Icon(Icons.swap_calls),
                onPressed: model.isEnabled(1)
                    ? model.onJourneyTabTap()
                        ? () {
                            model.updateIndex(1);
                            onTap(model.index);
                            // onTap(Pages.routes, "Routes");
                          }
                        : null
                    : null,
              ),
              label: 'Journey'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              backgroundColor: Color(0xFF182848),
              icon: IconButton(
                splashColor: kColorDDSPrimaryDark,
                icon: Icon(Icons.add_shopping_cart),
                onPressed: model.isEnabled(2)
                    ? model.onStockBalanceTap()
                        ? () {
                            model.updateIndex(2);
                            onTap(model.index);
                            // onTap(Pages.adhoc, "Adhoc Sales");
                          }
                        : null
                    : null,
              ),
              label: 'Adhoc Sales'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              backgroundColor: Color(0xFF182848),
              icon: IconButton(
                splashColor: kColorDDSPrimaryDark,
                icon: Icon(Icons.apps),
                onPressed: model.isEnabled(3)
                    ? model.onStockBalanceTap()
                        ? () {
                            model.updateIndex(3);
                            // onTap(Pages.products, "Stock Balance");
                            onTap(model.index);
                          }
                        : null
                    : null,
              ),
              label: 'Stock Balance'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              backgroundColor: Color(0xFF182848),
              icon: IconButton(
                splashColor: kColorDDSPrimaryDark,
                onPressed: model.isEnabled(4)
                    ? model.onCustomerTabTap()
                        ? () {
                            model.updateIndex(4);
                            onTap(model.index);
                            // onTap(Pages.customers, "Customers");
                          }
                        : null
                    : null,
                icon: Icon(Icons.people),
              ),
              label: 'Customers'.toUpperCase(),
            ),
          ]),
      viewModelBuilder: () => BottomNavBarViewModel(onTap, index),
    );
  }
}
