import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/services/activity_service.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:distributor/services/init_service.dart';
import 'package:distributor/services/order_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class OrderConfirmationViewModel extends ReactiveViewModel {
  OrderService _orderService = locator<OrderService>();
  CustomerService _customerService = locator<CustomerService>();
  ApiService _apiService = locator<ApiService>();
  UserService _userService = locator<UserService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  ActivityService _activityService = locator<ActivityService>();

  Api get api => _apiService.api;

  User get user => _userService.user;
  final Customer customer;

  SalesOrderRequest _salesOrder;
  SalesOrderRequest get salesOrder => _salesOrder;

  OrderConfirmationViewModel(
      {@required this.customer, SalesOrderRequest salesOrderRequest})
      : assert(customer != null),
        _salesOrder = salesOrderRequest;

  final InitService _initService = locator<InitService>();

  bool get enableOffline => _initService
      .appEnv.flavorValues.applicationParameter.enableOfflineService;

  String get currency =>
      _initService.appEnv.flavorValues.applicationParameter.currency;

  navigateToProductSelection() async {
    _navigationService.popRepeated(1);
  }

  createSalesOrder(bool isOnline) async {
    var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Confirm Order',
        description:
            'Are you sure that the order you are about to place for ${customer.name} is accurate?}',
        confirmationTitle: 'Yes',
        cancelTitle: 'NO');
    if (dialogResponse.confirmed) {
      setBusy(true);
      var result;
      // = await _orderService.createSalesOrder(salesOrder, customer,isOnline: isOnline);
      result = await api.createSalesOrder(
          user.token, salesOrder, customer.customerCode,
          customerName: customer.name);
      // if (isOnline) {
      //   result = await api.createSalesOrder(
      //       user.token, salesOrder, customer.customerCode,
      //       customerName: customer.name);
      // } else {
      //   result = await api.createOfflineOrders(
      //       salesOrder, customer.customerCode,
      //       customerName: customer.name);
      // }
      setBusy(false);
      if (result is bool) {
        if (result) {
          await _customerService.fetchOrdersByCustomer(customer.customerCode);
          // _activityService.addActivity(Activity(
          //     activityTitle: 'Sales Order submitted',
          //     activityDesc:
          //         'Sales Order for ${customer.name} of ${customer.route} created and submitted.'));
          _navigationService.back(result: true);
        }
      } else if (result is CustomException) {
        await _dialogService.showDialog(
            title: result.title, description: result.description);
      }
    }
  }

  calculateSalesOrderItemTotal() {}

  @override
  // TODO: implement reactiveServices
  List<ReactiveServiceMixin> get reactiveServices =>
      [_customerService, _orderService];

  deleteItem(Product item, SalesOrderItem salesOrderItem) async {
    var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Delete Item Order',
        confirmationTitle: 'Yes',
        cancelTitle: 'No',
        description:
            'Are you sure you want to remove ${item.itemName} from ${customer.name}\'s order ?');
    if (dialogResponse.confirmed) {
      //Remove the item
      _salesOrder.items
          .removeWhere((element) => element.item.itemName == item.itemName);

      //Update the total
      _salesOrder.total -=
          salesOrderItem.quantity * salesOrderItem.item.itemPrice;

      notifyListeners();
    }
  }

  backToPlaceOrder() {
    _navigationService.replaceWith(Routes.createSalesOrderView,
        arguments: CreateSalesOrderViewArguments(customer: customer));
  }

  createOfflineSalesOrder() {}
}
