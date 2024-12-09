import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/core/enums.dart';
import 'package:distributor/services/adhoc_cart_service.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:distributor/services/journey_service.dart';
import 'package:distributor/services/logistics_service.dart';
import 'package:distributor/services/stock_controller_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class AdhocSalesViewModel extends ReactiveViewModel {
  CustomerService _customerService = locator<CustomerService>();
  NavigationService _navigationService = locator<NavigationService>();
  DialogService _dialogService = locator<DialogService>();
  LogisticsService _logisticsService = locator<LogisticsService>();
  AdhocCartService _adhocCartService = locator<AdhocCartService>();
  JourneyService _journeyService = locator<JourneyService>();

  initializeCustomerDetails() async {}

  navigateToCart() async {
    if (isWalkInCustomer) {
      //@TODO Convert to the init service default database
      _adhocCartService.setSellingPriceList("walk in");
    }
    await _navigationService.navigateTo(Routes.adhocCartView,
        arguments: AdhocCartViewArguments(
            isWalkin: isWalkInCustomer, customer: customer));
    _adhocCartService.resetTotal();
  }

  bool get userHasJourneys {
    if (_logisticsService.userJourneyList.length > 0 &&
            _logisticsService.currentJourney != null &&
            journeyStatus?.toLowerCase() == 'in transit' ||
        _userService.user.hasSalesChannel) {
      return true;
    } else {
      return false;
    }
  }

  ApiService _apiService = locator<ApiService>();
  String get token => _userService.user.token;
  navigateToPaymentView() async {}

  StockControllerService _stockControllerService =
      locator<StockControllerService>();

  UserService _userService = locator<UserService>();
  List<String> customerTypes = ['Walk_In', 'Contract'];

  List<String> get paymentModes =>
      ['MPESA', 'Equitel', 'CASH', "Invoice Later"];

  Future fetchPaymentModes() async {}

  String _customerType;
  String get customerType => _customerType;

  int noOfSteps = 1;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _isCompleted = false;
  bool get isCompleted => _isCompleted;
  updateIsCompleted(bool val) {
    _isCompleted = val;
    notifyListeners();
  }

  updateCustomerType(String val) {
    _customerType = val.trim();
    _adhocCartService.setCustomerType(val);
    notifyListeners();
  }

  initCustomerType(CustomerType c) {
    if (c != null) {
      switch (c) {
        case CustomerType.Contract:
          _customerType = 'Contract';
          break;
        case CustomerType.Walk_In:
          _customerType = 'Walk_In';
          break;
      }
    }
  }

  bool get isWalkInCustomer {
    if (customerType.toLowerCase() == 'walk_in') {
      return true;
    } else {
      return false;
    }
  }

  AdhocSalesViewModel(Customer customer, {CustomerType customerType})
      : _customer = customer {
    initCustomerType(customerType);
  }

  Customer _customer;
  Customer get customer => _customer;
  updateCustomer(Customer c) {
    _customer = c;
    _adhocCartService.setCustomerId(c.name);
    _adhocCartService.setCustomerName(c.name);
    _adhocCartService.setWarehouse(c.branch);
    _adhocCartService.setSellingPriceList(c.defaultPriceList);
    notifyListeners();
  }

  void onStepTapped(int value) {
    _currentIndex = value;
    notifyListeners();
  }

  void onStepCancel() {
    if (currentIndex != 0) {
      _currentIndex--;
    }
    notifyListeners();
  }

  void onStepContinue() {
    if (currentIndex != noOfSteps) {
      _currentIndex++;
    } else {
      updateIsCompleted(true);
    }
    notifyListeners();
  }

  String _customerName;
  String get customerName => _customerName ?? "Walk In";
  updateCustomerName(String val) {
    if (val.isNotEmpty) {
      _customerName = val;
      notifyListeners();
    }
    _adhocCartService.setCustomerName(customerName);
    _adhocCartService.setWarehouse(deliveryJourney.route);
    _adhocCartService.setCustomerId(null);
    _adhocCartService.setSellingPriceList("walk in");
  }

  List<Customer> _customerList;
  List<Customer> get customerList {
    if (_customerList != null) {
      if (_customerList.length > 0) {
        return _customerList
          ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else {
        // print(_customerList.first.route);
        return _customerList
          ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      }
    } else {
      return <Customer>[];
    }
  }

  DeliveryJourney get deliveryJourney => _journeyService.currentJourney;

  fetchCustomers() async {
    var result = await _customerService.customers;
    if (result is List<Customer>) {
      _customerList = result;
      notifyListeners();
    } else {
      _customerList = <Customer>[];
      notifyListeners();
    }
  }

  List<Product> _productList;
  List<Product> get productList => _productList;

  fetchStockBalance() async {
    var result = await _stockControllerService.getStockBalance();
    if (result is List<Product>) {
      _productList = result;
      notifyListeners();
    } else if (result is CustomException) {
      _productList = <Product>[];
      notifyListeners();
    }
  }

  Map _posProfile;
  Map get posProfile => _posProfile;

  getUserPOSProfile() async {
    _posProfile = await _stockControllerService.getUserPOSProfile();
    notifyListeners();
  }

  String _remarks;
  String get remarks => _remarks;
  void updateRemarks(String value) {
    _remarks = value;
    notifyListeners();
  }

  String _customerId;
  String get customerId => _customerId;
  setCustomerId(String val) {
    _adhocCartService.setCustomerId(val);
    _customerId = val;
    notifyListeners();
  }

  String get journeyStatus => _journeyService.journeyStatus;

  @override
  List<ReactiveServiceMixin> get reactiveServices =>
      [_logisticsService, _adhocCartService, _journeyService];

  void initReactive() {
    _adhocCartService.resetTotal();
  }

  init() async {
    await _adhocCartService.init();
  }
}
