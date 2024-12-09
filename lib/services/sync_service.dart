import 'package:auto_route/auto_route.dart';
import 'package:distributor/app/locator.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:observable_ish/observable_ish.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class SyncService with ReactiveServiceMixin {
  final apiService = locator<ApiService>();
  final userService = locator<UserService>();

  SyncService() {
    listenToReactiveValues([_isBusy, _unprocessedOrders]);
  }

  ///
  ///The status of the synch
  ///
  RxValue<bool> _isBusy = RxValue<bool>(initial: false);

  ///
  /// The number of unprocessed orders
  ///
  RxValue<int> _unprocessedOrders = RxValue<int>(initial: 0);

  bool get isBusy => _isBusy.value;
  int get unprocessedOrders => _unprocessedOrders.value;
  Api get api => apiService.api;
  String get token => userService.user.token;

  setBusy(bool val) {
    _isBusy.value = val;
  }

  clearCache() async {
    await api.clearAPICache();
  }

  /// Clear the customer data
  clearCustomerData() async {}

  syncData() async {}

  fetchData() async {}

  syncJourneyData() async {
    // Get the journey details

    // Get the details of the DN
  }

  syncCustomerListData() async {
    setBusy(true);
    await api.fetchAllCustomers(token);
    setBusy(false);
  }

  syncCustomerData({@required String customerId}) async {
    setBusy(true);
    // Get orders
    // Get accounts
    // Get issues
    setBusy(false);
  }

  //Sync price list data
  syncPriceListData() async {
    setBusy(true);
    setBusy(false);
  }

  syncUserSummaryInfo() async {
    // Get list for user
  }

  syncJourneyInfo() async {}
}
