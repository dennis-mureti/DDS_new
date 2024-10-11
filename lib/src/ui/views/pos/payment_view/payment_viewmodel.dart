import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/core/models/product_service.dart';
import 'package:distributor/services/adhoc_cart_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class PaymentViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _productService = locator<ProductService>();
  final _dialogService = locator<DialogService>();
  AdhocCartService _adhocCartService = locator<AdhocCartService>();
  num _total = 0;
  final String docType;

  calculateTotal() {
    // num total = 0;
    // items.forEach((element) {
    //   total += element['itemRate'] ?? 0 * element['quantity'];
    // });
    // return total;
    num total = 0;
    for (int x = 0; x < items.length; x++) {
      var sku = items[x];
      if (sku is Map) {
        total += sku['itemRate'] ?? sku['itemPrice'] * sku['quantity'];
      } else {
        total += sku.itemRate ?? sku.itemPrice * sku.quantity;
      }
    }
    return total;
  }

  get total {
    if (docType == "DN") {
      return calculateDNTotal();
    } else {
      return _adhocCartService.calculateTotal();
    }
  }

  calculateDNTotal() {
    num orderTotal = 0;
    // get the number of items
    int numberOfItems = items.length;
    for (int x = 0; x < numberOfItems; x++) {
      var item = items[x];
      num deliveredQty = item['deliveredQty'] ?? item['quantity'] ?? 0.0;
      var itemTotal = item['itemRate'] * deliveredQty;
      //Add this value to the total
      orderTotal += itemTotal;
    }
    return orderTotal;
  }

  final List items;
  final String ref;

  List paymentOptions = ["Cash", "Credit", "Cheque", "Multipay", "Mpesa"];

  String _paymentMode;
  String _phoneNumber;
  double _cashValue;

  String _drawerName;
  String _chequeNumber;

  PaymentViewModel(this.items, {String ref, double total, this.docType})
      : ref = ref ?? "",
        _total = total;

  String get paymentMode => _paymentMode;
  String get phoneNumber => _phoneNumber ?? "";
  double get cashValue => _cashValue ?? 0;

  String get drawerName => _drawerName ?? "";
  String get chequeNumber => _chequeNumber ?? "";

  double get difference => calculateTotal() - cashValue;

  setPaymentMode(var val) {
    _paymentMode = val;
    _adhocCartService.setPaymentMode(val);
    notifyListeners();
  }

  setPhoneNumber(String val) {
    _phoneNumber = val;
    _adhocCartService.setPhoneNumber(val);
    notifyListeners();
  }

  bool _displayDifferenceString = false;
  bool get displayDifferenceString => _displayDifferenceString;

  get change => cashValue - total;

  handleCashTransactions() {
    if (cashValue < total) {
      _displayDifferenceString = false;
      notifyListeners();
      return null;
    } else if (cashValue > total) {
      var difference = total - cashValue;
      // Display the difference
      _displayDifferenceString = true;
      commit();
    }
  }

  setCashAmount(String val) {
    _cashValue = double.parse(val);
    if (cashValue < total) {
      //disable the finalize
    }
    notifyListeners();
  }

  setDrawerName(String val) {
    _drawerName = val;
    notifyListeners();
  }

  setChequeNumber(String val) {
    _chequeNumber = val;
    notifyListeners();
  }

  commit() async {
    final Map<String, dynamic> payment = {
      "phone": "${phoneNumber}",
      "drawerName": drawerName,
      "chequeNumber": chequeNumber,
      "cheque_amount": "",
      "maturityDate": "",
      "phone": phoneNumber,
      "amount": total,
      "mpesa_amount": total - cashValue,
      "externalAccountId": "string",
      "externalTxnID": "string",
      "externalTxnNarrative": "string",
      "payerAccount": "string",
      "payerName": "string",
      "paymentMode": paymentMode,
      "userTxnNarrative": "string"
    };
    Map<String, dynamic> data = {
      "amount": calculateTotal(),
      "payment": payment,
      "phoneNumber": phoneNumber
    };
    // Check if the ref is empty
    if (ref.isNotEmpty) {
      // This is a delivery note
      // Use the DN processing api
      setBusy(true);
      data.addAll({"dnId": ref});
      var result = await _productService.fulfillDeliveryNotePayment(data);
      setBusy(false);
      if (result is CustomException) {
        await _dialogService.showDialog(
            title: 'Place Order Failed', description: result.description ?? "");
      } else {
        //Refresh the DN details
        _navigationService.back(result: true);
      }
    } else {
      // This is an adhoc sale
      setBusy(true);
      var result = await _adhocCartService.createPayment(cashValue : cashValue);
      setBusy(false);
      if (result is bool) {
        await _dialogService.showDialog(
            title: 'Success', description: 'The sale was posted successfully.');
        _adhocCartService.resetTotal();
        _navigationService.pushNamedAndRemoveUntil(
          Routes.homeView,
          arguments: HomeViewArguments(index: 2),
        );
      } else if (result is CustomException) {
        await _dialogService.showDialog(title: 'Error', description: result.description);
      }
      // await _productService.postSale(data, modeOfPayment: paymentMode);
    }
  }
}
