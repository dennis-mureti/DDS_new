import 'package:distributor/app/locator.dart';
import 'package:distributor/services/access_controller_service.dart';

import 'package:stacked/stacked.dart';

class BottomNavBarViewModel extends BaseViewModel {
  final Function onTap;
  int _index = 0;
  int get index => _index;

  updateIndex(int val) {
    _index = val;
    notifyListeners();
  }

  BottomNavBarViewModel(this.onTap, int index) : _index = index ?? 0;
  AccessControlService _accessControlService = locator<AccessControlService>();

  bool _enableCustomerTab = false;
  bool get enableCustomerTab => _enableCustomerTab;

  bool _enableJourneyTab = false;
  bool get enableJourneyTab => _accessControlService.enableJourneyTab;

  bool get enableHomeTab => true;

  bool _enableProductTab = false;
  bool get enableProductTab => _enableProductTab;

  //Initialize the permissions
  init() async {}

  bool onStockBalanceTap() {
    if (_enableProductTab = false) {
      return false;
    } else {
      return true;
    }
  }

  onCustomerTabTap() {
    if (_enableCustomerTab = false) {
      return false;
    } else {
      return true;
    }
  }

  onJourneyTabTap() {
    if (_enableJourneyTab = false) {
      return false;
    } else {
      return true;
    }
  }

  isEnabled(int index) {
    bool isEnabled = false;
    switch (index) {
      case 0: //Home
        break;
      case 1: //Journey
        return _accessControlService.enableJourneyTab;
        break;
      case 2: //Adhoc
        return _accessControlService.enableAdhocView;
        break;
      case 3: //Stock view
        return _accessControlService.enableStockTab;
        break;
      case 4: // Customers
        return _accessControlService.enableCustomerTab;
        break;
      case 5:
        return _enableJourneyTab;
        break;
      default:
        return false;
        break;
    }
    return isEnabled;
  }
}
