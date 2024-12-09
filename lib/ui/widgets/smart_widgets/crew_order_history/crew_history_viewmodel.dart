import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/order_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class CrewHistoryViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _orderService = locator<OrderService>();
  final _userService = locator<UserService>();
  final _apiService = locator<ApiService>();

  Api get api => _apiService.api;

  String get token => _userService.user.token;

  List<SalesOrder> _orders = [];
  List<SalesOrder> get orders => _orders;

  init() async {
    await _pushOfflineTransactionsOnViewRefresh();
    await _fetchOrders();
  }

  Future _pushOfflineTransactionsOnViewRefresh() async {
    setBusy(true);
    await api.pushOfflineTransactionsOnViewRefresh(token);
    setBusy(false);
    notifyListeners();
  }

  //fetch all orders
  Future _fetchOrders() async {
    setBusy(true);
    var result = await _orderService.fetchOrdersByUser(token);
    if (result is List<SalesOrder>) {
      _orders = result;
      if (_orders.isNotEmpty) {
        _orders.sort((b, a) => a.orderDate.compareTo(b.orderDate));
      }
    }
    setBusy(false);
    notifyListeners();
  }

  navigateToSalesOrder(SalesOrder salesOrder,
      {DeliveryJourney deliveryJourney, String stopId}) async {
    await _navigationService.navigateTo(Routes.orderDetailView,
        arguments: OrderDetailViewArguments(
            salesOrder: salesOrder,
            deliveryJourney: deliveryJourney,
            stopId: stopId));
    await _fetchOrders();
  }

  navigateToOrder(SalesOrder salesOrder, DeliveryJourney deliveryJourney,
      String stopId) async {}

  syncOrder() {}
}
