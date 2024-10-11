import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/core/models/product_service.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/src/ui/views/pos/base_pos_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

enum CustomerTypesDisplay { none, walkin, contract }

enum PaymentModeDisplay { none, mobile, cash, mixed, cheque }

class CheckOutViewModel extends BasePOSViewModel {
  final _customerService = locator<CustomerService>();
  final _productService = locator<ProductService>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();

  bool get isValid => paymentMode != null && customerType != null;

  String get branch => _userService.user.branch;

  final _api = locator<ApiService>();
  get api => _api.api;

  final List orderedItems;

  final List<String> paymentMethods = ["Cash", "Mpesa", "Mixed", "Cheque"];

  String _customerType;
  PaymentModeDisplay _paymentModeDisplay = PaymentModeDisplay.none;
  CustomerTypesDisplay _customerTypesDisplay = CustomerTypesDisplay.none;

  CheckOutViewModel(this.orderedItems);

  PaymentModeDisplay get paymentModeDisplay => _paymentModeDisplay;
  CustomerTypesDisplay get customerTypesDisplay => _customerTypesDisplay;

  String get customerType => _customerType;

  get displayCustomers => _customerType.toLowerCase() == 'contract';

  String _paymentMode;
  String get paymentMode => _paymentMode;

  get isMixedPaymentMode =>
      _paymentMode?.toLowerCase() != 'cash' ||
      paymentMode?.toLowerCase() != 'mobile';

  get total => calculateTotal();

  calculateTotal() {
    var total = 0;
    orderedItems.forEach((element) {
      total += element.quantity * element.itemPrice;
    });
    return total;
  }

  setCustomerType(String val) {
    _customerType = val;
    switch (val.toLowerCase()) {
      case 'contract':
        _customerTypesDisplay = CustomerTypesDisplay.contract;
        break;
      case 'walkin':
        _customerTypesDisplay = CustomerTypesDisplay.walkin;
        break;
      default:
        _customerTypesDisplay = CustomerTypesDisplay.none;
    }
    notifyListeners();
  }

  printReceipt() async {}

  //Set the payment method
  void setPaymentMode(String value) {
    _paymentMode = value;
    //Update the display
    switch (value.toLowerCase()) {
      case 'cash':
        _paymentModeDisplay = PaymentModeDisplay.cash;
        break;
      case 'mpesa':
        _paymentModeDisplay = PaymentModeDisplay.mobile;
        break;
      case 'multipay':
        _paymentModeDisplay = PaymentModeDisplay.mixed;
        break;
      case 'cheque':
        _paymentModeDisplay = PaymentModeDisplay.cheque;
        break;
      default:
        _paymentModeDisplay = PaymentModeDisplay.none;
    }
    notifyListeners();
  }

  bool isConfirmedPayment = false;

  bool get isValidated => isConfirmedPayment;
  set isValidated(bool value) {
    isConfirmedPayment = value;
    notifyListeners();
  }

  void validateTransaction() {}

  String _customerName = "";
  String _phoneNumber = "";
  String _transactionCode = "";

  String get customerName => _customerName;
  String get phoneNumber => _phoneNumber;
  String get transactionCode => _transactionCode;

  setCustomerName(String val) {
    _customerName = val;
    notifyListeners();
  }

  setPhoneNumber(String val) {
    _phoneNumber = val;
    notifyListeners();
  }

  setTransactionCode(String val) {
    _transactionCode = val;
    notifyListeners();
  }

  initiatePushStk() {
    setBusy(true);
    setBusy(false);
  }

  validateTransactionCode(String val) {
    setBusy(true);
    notifyListeners();
    setBusy(false);
  }

  confirmPaymentReceipt() {
    notifyListeners();
  }

  List<Customer> _customerList = <Customer>[];
  List<Customer> get customersList => _customerList;

  fetchCustomers() async {
    setBusy(true);
    _customerList = await _customerService.fetchCustomers();
    setBusy(false);
  }

  Customer _contractCustomer;
  Customer get contractCustomer => _contractCustomer;
  updateContractCustomer(Customer c) {
    _contractCustomer = c;
    notifyListeners();
  }

  init() async {
    await fetchCustomers();
  }

  postSale() async {
    // await getCurrentLocation();
    setBusy(true);
    Map<String, dynamic> data = {
      "customerId": contractCustomer != null
          ? contractCustomer.customerCode
          : customerName,
      "customerName":
          contractCustomer != null ? contractCustomer.name : customerName,
      "items": orderedItems
          .map((e) => {
                "itemCode": e.itemCode,
                "itemName": e.itemName,
                "id": e.itemCode,
                "quantity": e.quantity,
                "branch": branch,
                "initialQuantity": "",
                "itemPrice": e.itemPrice,
                "customer": contractCustomer != null
                    ? contractCustomer.name
                    : customerName,
                "customerType": customerType,
                "itemTotalPrice": e.quantity * e.itemPrice,
                "itemRate": e.itemPrice,
              })
          .toList(),
      "dueDate": DateTime.now().toIso8601String(),
      "total": total,
      "type": customerType,
      "payment": {
        "phone": "${phoneNumber}",
        "drawerName": drawerName,
        "chequeNumber": chequeNumber,
        "amount": total,
        "mpesa_amount": total - cashAmount,
        "externalAccountId": "string",
        "externalTxnID": "string",
        "externalTxnNarrative": "string",
        "payerAccount": "string",
        "payerName": "string",
        "paymentMode": paymentMode,
        "userTxnNarrative": "string"
      },
      "deliveryLocation": "",
      "remarks": "",
      "sellingPriceList": "4SumPriceList",
      "warehouseId": "",
      "towarehouse": ""
    };
    var result =
        await _productService.postSale(data, modeOfPayment: paymentMode);
    setBusy(false);
    if (result is CustomException) {
      await _dialogService.showDialog(
          title: 'Place Order Failed', description: result.description ?? "");
    } else {
      await _dialogService.showDialog(
          title: 'Place Order Succeeded',
          description: "The order was placed successfully");
      await _navigationService.navigateTo(Routes.homeView,
          arguments: HomeViewArguments(index: 2));
    }
  }

  int _cashAmount = 0;
  int get cashAmount => _cashAmount ?? 0;

  int get difference => total - cashAmount > 0 ? total - cashAmount : 0;

  setCashAmount(String value) {
    _cashAmount = int.parse(value);
    notifyListeners();
  }

  String _drawerName = "";
  String _chequeNumber = "";

  String get drawerName => _drawerName;
  String get chequeNumber => _chequeNumber;

  void setDrawerName(String value) {
    _drawerName = value;
    notifyListeners();
  }

  void setChequeNumber(String value) {
    _chequeNumber = value;
    notifyListeners();
  }
}
