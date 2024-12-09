import 'package:distributor/app/locator.dart';
import 'package:distributor/core/enums.dart';
import 'package:distributor/services/access_controller_service.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:observable_ish/observable_ish.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class CustomerService with ReactiveServiceMixin {
  AccessControlService _accessControlService = locator<AccessControlService>();
  ApiService _apiService = locator<ApiService>();
  UserService _userService = locator<UserService>();
  final _dialogService = locator<DialogService>();

  User get user => _userService.user;
  Api get api => _apiService.api;

  // List of customers
  List<Customer> _customerList;
  List<Customer> get customerList => _customerList;

  RxValue<CustomerAccount> _customerAccount = RxValue<CustomerAccount>();
  RxValue<List<Issue>> _customerIssues =
      RxValue<List<Issue>>(initial: <Issue>[]);

  CustomerAccount get customerAccount => _customerAccount.value;

  List<Issue> get issueList => _customerIssues.value;

  getCustomerLimit(var customerId) async {
    var result = await _apiService.api.getCustomerLimit(user.token, customerId);
    if (result is Map<String, dynamic>) {
      return double.parse(result['balance_amount']) ?? 0.00;
    } else {
      return 0.00;
    }
  }

  getCustomerSecurity(Customer customer) async {
    var result = await _apiService.api
        .getCustomerSecurity(customer: customer, token: user.token);
    return result;
  }

  getCustomerIssues(String customerCode) async {
    var result = await _apiService.api
        .getCustomersIssuesByCustomer(customerCode, user.token);
    if (result is List<Issue>) {
      _customerIssues.value = result;
      notifyListeners();
    } else {
      if (result is CustomException) {
        await _dialogService.showDialog(
            title: result.title, description: result.description);
      }
      _customerIssues.value = <Issue>[];
      notifyListeners();
    }
  }

  Future<List<Customer>> get customers async {
    List<Customer> _customer =
        await _apiService.api.fetchAllCustomers(user.token);
    return _customer;
  }

  sortCustomerByName() async {
    List<Customer> customers =
        await _apiService.api.fetchAllCustomers(user.token);
    return customers.sort((a, b) => a.name.compareTo(b.name));
  }

  List<SalesOrder> _salesOrderList = <SalesOrder>[];
  List<SalesOrder> get salesOrderList => _salesOrderList;

  CustomerService() {
    listenToReactiveValues([_customerIssues, _customerAccount]);
    init();
  }

  bool get enableAccountsTab {
    return _accessControlService.enableAccountsTab();
  }

  get enableIssuesTab {
    return _accessControlService.enableIssuesTab();
  }

  bool get enableInfoTab {
    return _accessControlService.enableInfoTab();
  }

  bool enablePlaceOrderButton() {
    bool result = false;
    if (_accessControlService.enablePlaceOrderButton) {
      result = true;
    }
    return result;
  }

  bool get enableOrdersTab => _accessControlService.enableOrdersTab;

  Future fetchCustomers() async {
    List<Customer> customer = await api.fetchAllCustomers(user.token);
    return customer;
  }

  init() {
    enableCustomerTab;
    enableAccountsTab;
    enablePlaceOrderButton;
    enableIssuesTab;
    //If accounts enabled
  }

  bool get enableCustomerTab => _accessControlService.enableCustomerTab;

  Future fetchCustomerOrdersNonReactive(String customerCode) async {
    var result =
        // await api.refreshCustomerOrders(customerCode, _userService.user.token);
        await fetchOrdersByCustomer(customerCode);
    return result;
  }

  Future fetchOrdersByCustomer(String customerCode) async {
    var result =
        await api.fetchOrderByCustomer(customerCode, _userService.user.token);

    if (result is List<SalesOrder>) {
      _salesOrderList = result;
      notifyListeners();
    } else {
      if (result is CustomException) {
        await _dialogService.showDialog(
            title: result.title, description: result.description);
      }
      _salesOrderList = <SalesOrder>[];
      notifyListeners();
    }
    return _salesOrderList;
  }

  addCustomerIssue(Map<String, dynamic> data, String customerCode) async {
    var result =
        await _apiService.api.createIssue(data, _userService.user.token);
    if (result is bool) {
      await getCustomerIssues(customerCode);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future getCustomerAccountTransactions({String customerId}) async {
    var result = await api.getCustomerAccountTransactions(
        customerId: customerId, token: _userService.user.token);
    if (result is CustomerAccount) {
      _customerAccount.value = result;
      notifyListeners();
    } else {
      await _dialogService.showDialog(
          title: result.title, description: result.description);
      _customerAccount.value = CustomerAccount();
      notifyListeners();
    }
  }

  getCustomerDetailById(var customerId) async {
    var result = await api.customerDetails(customerId, user.token);
    return result;
  }

  addPayment(
      {PaymentModes paymentModes, Payment payment, String customerId}) async {
    String paymentMode = paymentModes.toString().split(".").last;
    Map<String, dynamic> data = payment.toJson();
    var result = await api.createPayment(data, user.token, paymentMode);
    if (result is bool) {
      await getCustomerAccountTransactions(customerId: customerId);
    }
    return result;
  }

  listWarehouses() async {
    var result = await api.listWarehouses(user.token);
    print(result);
    return result;
  }
}
