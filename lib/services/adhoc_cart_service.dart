import 'package:distributor/app/locator.dart';
import 'package:distributor/core/models/app_models.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:distributor/services/init_service.dart';
import 'package:distributor/services/journey_service.dart';
import 'package:distributor/services/location_repository.dart';
import 'package:distributor/services/logistics_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:injectable/injectable.dart';
import 'package:observable_ish/observable_ish.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

@lazySingleton
class AdhocCartService with ReactiveServiceMixin {
  ApiService _apiService = locator<ApiService>();
  UserService _userService = locator<UserService>();
  LogisticsService _logisticsService = locator<LogisticsService>();
  final _locationService = locator<LocationRepository>();
  JourneyService _journeyService = locator<JourneyService>();
  final _customerService = locator<CustomerService>();

  ApplicationParameter get appParams => _apiService.appParams;

  bool get enforceCreditLimit => appParams.enforceCreditLimit;
  bool get enforceCustomerSecurity => appParams.enforceCustomerSecurity;

  UserLocation _userLocation;
  UserLocation get userLocation => _userLocation;

  getCurrentLocation() async {
    var result = await _locationService.getLocation();
    if (result is UserLocation) {
      _userLocation = result;
    }
  }

  finalizeOrder(String invoiceId) async {
    var response =
        await _apiService.api.finalizeSale(token: token, invoiceId: invoiceId);
    return response;
  }

  List<String> _paymentModes;

  List<String> get paymentModes {
    List<String> _modes = [];
    if (customerType.toLowerCase() == 'contract') {
      // if (showMPesa) {
      //   _modes.add('MPESA');
      // }
      // if (showAirtel) {
      //   _modes.add('EQUITEL');
      // }
      _modes.addAll(
        ['CASH', 'INVOICE'],
      );
      return _modes;
    } else {
      // if (showMPesa) {
      //   _modes.add('MPESA');
      // }
      // if (showAirtel) {
      //   _modes.add('EQUITEL');
      // }
      _modes.add('CASH');
      return _modes;
    }
  }

  String get customerType => _customerType.value;

  RxValue<List<Product>> _itemsInCart = RxValue(initial: <Product>[]);
  List<Product> get itemsInCart => _itemsInCart.value;

  RxValue<List> _paymentModeDetails = RxValue(initial: []);
  List get paymentModeDetails => _paymentModeDetails.value;

  RxValue<bool> _showMPesa = RxValue(initial: false);
  RxValue<bool> _showEquitel = RxValue(initial: false);
  RxValue<bool> _enableContinueToPayment = RxValue(initial: false);

  bool get showMPesa => _showMPesa.value;
  bool get showAirtel => _showEquitel.value;
  bool get enableContinueToPayment => _enableContinueToPayment.value;

  updateContinueToPayment() {
    if (total == 0) {
      _enableContinueToPayment.value = false;
    } else {
      _enableContinueToPayment.value = true;
    }
  }

  var _mpesaDetail;
  get mpesaDetail => _mpesaDetail;

  CustomerSecurity _customerSecurity;
  CustomerSecurity get customerSecurity => _customerSecurity;

  init() async {
    if (_logisticsService.currentJourney != null) {
      // var mpesaRes =
      //     await getPOSAccount('MPESA', _journeyService.currentJourney.branch);
      // if (mpesaRes is List) {
      //   if (mpesaRes.isNotEmpty) {
      //     _showMPesa.value = true;
      //     _mpesaDetail = mpesaRes;
      //   }
      // }
      // var airtelRes =
      //     await getPOSAccount('EQUITEL', _journeyService.currentJourney.branch);
      // if (airtelRes is List) {
      //   if (airtelRes.isNotEmpty) {
      //     _showEquitel.value = true;
      //   }
      // }
      // await getPaymentModes(_journeyService.currentJourney.route);
    }
    // await getCurrentLocation();
  }

  initializeCustomerData(
      Customer customer, List<Product> customerProductList) async {
    if (enforceCreditLimit) {
      _creditLimit.value =
          await _customerService.getCustomerLimit(customer.name);
      _creditBalance.value = _creditLimit.value;
    }

    if (enforceCustomerSecurity) {
      var result = await _customerService.getCustomerSecurity(customer);
      _customerSecurity = CustomerSecurity.fromMap(result);
      _securityBalance.value =
          double.tryParse(_customerSecurity.securityAmount) ?? 0.0;

      _securityAmount.value =
          double.tryParse(customerSecurity.securityAmount) ?? 0;
    }
    _customerProductList = customerProductList;
  }

  getPOSAccount(String modeOfPayment, branchId) async {
    var result = await _apiService.api.getPOSAccount(
        modeOfPayment, _userService.user.token,
        branchId: branchId);
    return result;
  }

  getPaymentModes(String branchId) async {
    for (int i = 0; i < paymentModes.length; i++) {
      await getPOSAccount(paymentModes[i], branchId);
    }
  }

  Api get api => _apiService.api;
  String get token => _userService.user.token;

  RxValue _customer = RxValue();
  RxValue _total = RxValue(initial: 0);
  RxValue _paymentMode = RxValue(initial: "");
  RxValue _customerId = RxValue(initial: null);
  RxValue _customerName = RxValue(initial: "");
  RxValue _sellingPriceList = RxValue(initial: "");
  RxValue<List<SalesOrderItem>> _items = RxValue(initial: <SalesOrderItem>[]);
  RxValue _remarks = RxValue(initial: "");
  RxValue _customerType = RxValue(initial: "");
  RxValue _warehouse = RxValue(initial: "");

  /// Credit balance of the minishop
  RxValue _creditBalance = RxValue(initial: 0.0);

  /// Security amount of the minishop customer
  RxValue _securityAmount = RxValue(initial: 0.0);

  /// Security balance of the minishop customer
  RxValue _securityBalance = RxValue(initial: 0.0);

  // Credit limit of the customer
  RxValue _creditLimit = RxValue(initial: 0.0);

  double get securityBalance => _securityBalance.value;
  double get securityAmount => _securityAmount.value;
  double get creditBalance => _creditBalance.value;
  double get creditLimit => _creditLimit.value;
  Customer get customer => _customer.value;
  List<Product> _customerProductList;
  List<Product> get customerProductList => _customerProductList;

  calculateSecurity(Product item, var quantity) {
    // Is customer calculated for the security? If no, return 0.0
    if (customerSecurity.calcSecurity.toLowerCase() != "yes") {
      return _securityAmount.value;
    }
    // If it is a fixed security, return the security amount
    if (customerSecurity.securityType.toLowerCase() != "variable") {
      return double.parse(customerSecurity.securityAmount);
    }
    var securityAmount = double.tryParse(customerSecurity.securityAmount) ?? 0;
    // var result = (quantity * securityAmount).toDouble();

    var itemFactor = double.tryParse(item.itemFactor) ?? 0.5;
    var result = (quantity * securityAmount * itemFactor).toDouble();
    print(result);
    _securityBalance.value += result;
    print("This is the security to ADD:::: ${securityBalance}");

    // itemsInCart.forEach((i) {
    //   // var ite = ddsItemRepository.getItemByCode(item.itemCode!);
    //   // Now calculate the variable security
    //   if (i.itemCode.toLowerCase() == item.itemCode.toLowerCase()) {
    //     print(item.quantity);
    //
    //     var quantity = item.quantity ?? 0;
    //     var securityAmount = int.tryParse(customerSecurity.securityAmount) ?? 0;
    //     // var result = (quantity * securityAmount * item.itemFactor).toDouble();
    //     var result = (quantity * securityAmount).toDouble();
    //     // var result = (quantity * securityAmount).toDouble();
    //     _securityBalance.value += result;
    //     print("This is the security to ADD:::: ${securityBalance}");
    //   }
    // });
  }

  AdhocCartService() {
    listenToReactiveValues([
      _total,
      _paymentMode,
      _customerId,
      _remarks,
      _customerName,
      _items,
      _itemsInCart,
      _showEquitel,
      _showMPesa,
      _warehouse,
      _customerType,
      _sellingPriceList,
      _securityBalance,
      _securityAmount,
      _creditBalance
    ]);
    init();
  }

  num get total => _total.value ?? 0;
  String get customerId => _customerId.value ?? null;
  String get warehouse => _warehouse.value;

  List<SalesOrderItem> get items => _items.value;
  String get sellingPriceList => _sellingPriceList.value;
  String get paymentMode => _paymentMode.value;
  String get remarks => _remarks.value ?? "";

  setPaymentMode(String val) {
    _paymentMode.value = val;
  }

  increaseSalesOrderItems(Product p, quantity) {
    if (_itemsInCart.value.contains(p)) {
      // Get the element that contains the product in the sales item
      for (int i = 0; i < _items.value.length; i++) {
        if (_items.value[i].item == p) {
          // Increase the value of the sales order item
          _items.value[i].quantity += quantity;
          notifyListeners();
        }
      }
    } else {
      _itemsInCart.value.add(p);
      SalesOrderItem s = SalesOrderItem(item: p, quantity: quantity);
      _items.value.add(s);
      notifyListeners();
    }

    //@TODO : Calculate the security

    //@TODO : Calculate the credit balance
  }

  resetTotal() {
    _total.value = 0;
    _itemsInCart.value.clear();
    _items.value.clear();
    notifyListeners();
  }

  decreaseSalesOrderItems(Product p, quantity) {
    if (_itemsInCart.value.contains(p)) {
      // Get the element that contains the product in the sales item
      for (int i = 0; i < _items.value.length; i++) {
        if (_items.value[i].item == p) {
          // Decrease the value of the sales order item
          _items.value[i].quantity -= quantity;

          if (items[i].quantity == 0) {
            _itemsInCart.value.remove(p);
            _items.value.removeAt(i);
          }
        }
      }
    }
    notifyListeners();
  }

  setCustomerType(String val) {
    _customerType.value = val;
  }

  setCustomerId(var val) {
    _customerId.value = val;
  }

  setCustomerName(String val) {
    _customerName.value = val;
  }

  setSellingPriceList(String val) {
    _sellingPriceList.value = val;
  }

  addToTotal(num val, {Product item}) {
    _total.value = _total.value + val;
    //Reduce the credit balance
    _creditBalance.value -= _total.value + val;
    updateContinueToPayment();

    //Calculate security limit
    // calculateSecurity(item, (val));
  }

  setRemarks(String val) {
    _remarks.value = val;
  }

  subtractFromTotal(num val, {Product item}) {
    if (_total.value != 0) {
      _total.value = _total.value - val;
      //Update the credit balance
      _creditBalance.value += _total.value - val;
      // Update the security
      // calculateSecurity(item, val);

      updateContinueToPayment();
    }
  }

  get customerName => _customerName.value;

  createPayment() async {
    // await getCurrentLocation();
    Map<String, dynamic> data = {
      "customerId": customerId,
      "customerName": customerName,
      "items": items
          .map((e) => {
                "itemCode": e.item.itemCode,
                "itemName": e.item.itemName,
                "itemRate": e.item.itemPrice,
                "quantity": e.quantity
              })
          .toList(),
      "payment": {
        "amount": total,
        "externalAccountId": "string",
        "externalTxnID": "string",
        "externalTxnNarrative": "string",
        "payerAccount": "string",
        "payerName": "string",
        "paymentMode": paymentMode == 'INVOICE' ? 'ACCOUNT' : paymentMode,
        "userTxnNarrative": "string"
      },
      "deliveryLocation":
          "${userLocation?.latitude},${userLocation?.longitude}",
      "remarks": remarks,
      "sellingPriceList": sellingPriceList,
      "warehouseId":
          _userService.user.salesChannel ?? _journeyService.currentJourney.route
    };

    var result = await api.createPOSPayment(
        modeOfPayment: paymentMode == 'INVOICE' ? 'ACCOUNT' : paymentMode,
        data: data,
        token: token);

    return result;
  }

  setWarehouse(String branch) {
    _warehouse.value = branch;
  }

  final _initService = locator<InitService>();

  get enableAdhocSale =>
      _initService.appEnv.flavorValues.applicationParameter.enableAdhocSales;

  fetchAdhocSalesList({DateTime postingDate}) async {
    String route = "";
    if (enableAdhocSale && !_userService.user.hasSalesChannel) {
      route = _journeyService.currentJourney.route;
    } else {
      route = _userService.user.salesChannel;
    }
    List result = await _apiService.api.getAdhocSales(
        _userService.user.token, route,
        postingDate: postingDate ?? DateTime.now());

    if (result.isNotEmpty) {
      return result.map<AdhocSale>((e) => AdhocSale.fromResponse(e)).toList();
    }
    return <AdhocSale>[];
  }

  fetchAdhocDetail(String referenceNo, String token, String baseType) async {
    var result =
        await _apiService.api.adhocSaleDetails(referenceNo, token, baseType);

    if (result != null) {
      return AdhocDetail.fromResponse(result);
    }
    return result;
  }

  cancelAdhocSale(String referenceNo, String token, AdhocDetail adhocDetail,
      String baseType, String customerId) async {
    return await _apiService.api.reverseSale(referenceNo, token, "Pick Up");
  }

  editTransaction(String baseType, String referenceNo,
      Map<String, dynamic> POSSaleRequest) async {
    return await _apiService.api.reverseSale(referenceNo, token, "Pick Up",
        POSSaleRequest: POSSaleRequest);
  }

  void resetCart() {}
}
