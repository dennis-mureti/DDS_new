import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/services/access_controller_service.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class CustomerDetailViewModel extends BaseViewModel {
  final Customer customer;
  final UserService _userService = locator<UserService>();
  final ApiService _apiService = locator<ApiService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final CustomerService _customerService = locator<CustomerService>();
  final DialogService _dialogService = locator<DialogService>();
  final AccessControlService _accessControlService =
      locator<AccessControlService>();
  SnackbarService _snackbarService = locator<SnackbarService>();

  User get user => _userService.user;
  Api get api => _apiService.api;

  int _tabLength = 4;
  int get tabLength => _tabLength;

  String _customerName;
  String get customerName => _customerName ?? customer.name;

  int _initialIndex = 0;
  int get initialIndex => _initialIndex;

  CustomerDetailViewModel({@required this.customer})
      : _customerName = customer.name;

  List<double> get coordinates {
    List<double> _coordinates = <double>[];
    if (customer.gpsLocation != null) {
      List<String> splitGPSString = customer.gpsLocation.split(',');
      splitGPSString.map((e) {
        coordinates.add(double.parse(e));
      }).toList();
    }
    return _coordinates;
  }

  bool get enableLinkPayment => _accessControlService.enableLinkPaymentMenu;
  bool get enablePlaceOrder => _accessControlService.enablePlaceOrderButton;
  bool get enableAdhocSale => _accessControlService.enableMakeAdhocSale;
  bool get enableAddPayment => _accessControlService.enableAddPaymentMenu;
  bool get enableAddIssue => _accessControlService.enableAddIssueMenu;

  Future navigateToCreateSalesOrderView(Customer customer) async {
    if (enablePlaceOrder) {
      var result = await _navigationService.navigateTo(
          Routes.createSalesOrderView,
          arguments: CreateSalesOrderViewArguments(customer: customer));
      await fetchCustomerOrders();
      return result;
    } else {
      await _dialogService.showDialog(
          title: 'Insufficient Permissions',
          description:
              'You do not have sufficient permissions to use this place an order.');
    }
  }

  bool canPlaceOrder() {
    if (_customerService.enablePlaceOrderButton()) {
      return true;
    } else {
      return false;
    }
  }

  bool get enableCreateOrderTab => _customerService.enablePlaceOrderButton();
  bool get enableAccountsTab => _customerService.enableAccountsTab;
  bool get enableOrdersTab => _customerService.enableOrdersTab;
  bool get enableIssuesTab => _customerService.enableIssuesTab;
  bool get enableInfoTab => _customerService.enableInfoTab;

  Future<bool> checkAuthority(int index) async {
    if (index == 2 && !enableAccountsTab) {
      await _dialogService.showDialog(
          title: 'Insufficient Permissions',
          description:
              'You do not have sufficient permissions to view customer accounts.');
      return false;
    } else {
      return true;
    }
  }

  Future fetchCustomerOrders() async {
    setBusy(true);
    await _customerService.fetchOrdersByCustomer(customer.customerCode);
    setBusy(false);
  }

  fetchAccounts() async {
    setBusy(true);
    await _customerService.getCustomerAccountTransactions(
        customerId: customer.id);
    setBusy(false);
    notifyListeners();
  }

  fetchIssues() async {
    setBusy(true);
    await _customerService.getCustomerIssues(customer.customerCode);
    setBusy(false);
    notifyListeners();
  }

  navigateToCustomers() async {
    await _navigationService.navigateTo(Routes.homeView);
  }

  void navigateToPaymentReferenceView(Customer customer) async {
    await _navigationService.navigateTo(Routes.paymentReferenceView,
        arguments: PaymentReferenceViewArguments(customer: customer));
  }

  navigateToPaymentReference() async {
    await _navigationService.navigateTo(Routes.paymentReferenceView,
        arguments: PaymentReferenceViewArguments(customer: customer));
  }

  void navigateToPage(String x) async {
    switch (x) {
      case 'link_payment':
        enableLinkPayment ? await navigateToPaymentReference() : null;
        break;
      case 'place_order':
        enablePlaceOrder ? await navigateToPlaceOrder() : null;
        break;
      case 'add_payment':
        enableAddPayment ? await navigateTOAddPayment() : null;
        break;
      case 'make_adhoc_sale':
        enableAdhocSale ? await navigateToMakeAdhocSale() : null;
        break;
      case 'add_issue':
        enableAddIssue ? await navigateToAddIssue() : null;
        break;
    }
  }

  navigateToPlaceOrder() async {
    var result = await _navigationService.navigateTo(
        Routes.createSalesOrderView,
        arguments: CreateSalesOrderViewArguments(customer: customer));
    if (result is bool) {
      if (result) {
        _snackbarService.showSnackbar(
            title: 'Success', message: 'The order was placed successfully');
        await fetchCustomerOrders();
      }
    }
  }

  navigateTOAddPayment() async {
    var result = await _navigationService.navigateTo(Routes.addPaymentView,
        arguments: AddPaymentViewArguments(customer: customer));
    if (result is bool) {
      await fetchAccounts();
      _snackbarService.showSnackbar(
          title: 'Success', message: 'The payment was added successfully.');
    }
  }

  navigateToMakeAdhocSale() async {
    var result = await _navigationService.navigateTo(Routes.addAdhocSaleView,
        arguments: AddAdhocSaleViewArguments(customer: customer));
  }

  void navigateToAddIssue() async {
    var result = await _navigationService.navigateTo(Routes.addIssueView,
        arguments: AddIssueViewArguments(customer: customer));
    if (result is bool) {
      await fetchIssues();
      _snackbarService.showSnackbar(
          title: 'Success', message: 'The issue was added successfully.');
    }
  }
}
