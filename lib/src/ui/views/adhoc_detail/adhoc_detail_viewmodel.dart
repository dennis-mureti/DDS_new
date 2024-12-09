import 'package:distributor/app/locator.dart';
import 'package:distributor/core/models/app_models.dart';
import 'package:distributor/core/models/invoice.dart';
import 'package:distributor/services/adhoc_cart_service.dart';
import 'package:distributor/services/init_service.dart';
import 'package:distributor/services/stock_controller_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/src/ui/views/print_view/print_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class AdhocDetailViewModel extends BaseViewModel {
  final String referenceNo;
  final _adhocService = locator<AdhocCartService>();
  final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _initService = locator<InitService>();

  StockControllerService _stockControllerService =
      locator<StockControllerService>();

  String get currency =>
      _initService.appEnv.flavorValues.applicationParameter.currency;

  List<Product> _productList;
  List<Product> get productList => _productList;

  fetchStockBalance() async {
    setBusy(true);
    var result = await _stockControllerService.getStockBalance();
    setBusy(false);
    if (result is List<Product>) {
      _productList = result;
      notifyListeners();
    } else if (result is CustomException) {
      _productList = <Product>[];
      notifyListeners();
      await _dialogService.showDialog(
          title: result.title, description: result.description);
    }
  }

  init() async {
    await getAdhocDetail();
    await fetchStockBalance();
  }

  //The originator
  //Caretaker
  //Memento
  // The memento pattern is implemented with three objects:
  // the originator, a caretaker and a memento.
  // The originator is some object that has an internal state.
  // The caretaker is going to do something to the originator,
  // but wants to be able to undo the change.
  // The caretaker first asks the originator for a memento object.
  // Then it does whatever operation (or sequence of operations) it was going to do.
  // To roll back to the state before the operations,
  // it returns the memento object to the originator.
  // The memento object itself is an opaque object (one which the caretaker cannot, or should
  // not, change).
  // When using this pattern, care should be taken if
  // the originator may change other
  // objects or resources—the memento pattern operates on a single object.
  String get token => _userService.user.token;

  AdhocDetailViewModel(this.referenceNo, this.customerId, this.baseType);

  bool _fetched = false;
  bool get fetched => _fetched;

  AdhocDetail _adhocDetail;
  AdhocDetail get adhocDetail => _adhocDetail;

  getAdhocDetail() async {
    setBusy(true);

    _adhocDetail =
        await _adhocService.fetchAdhocDetail(referenceNo, token, baseType);
    if (_adhocDetail.saleItems != null || _adhocDetail.saleItems.isNotEmpty) {
      _memento =
          _adhocDetail.saleItems.map((e) => SaleItem.fromMap(e)).toList();
    }
    setBusy(false);
    _fetched = true;
    notifyListeners();
  }

  //Memento
  List<SaleItem> _memento;
  List<SaleItem> get memento => _memento;

  confirmAction(String action) async {
    //Check if the transaction is today
    if (DateTime.parse(adhocDetail.transactionDate).day == DateTime.now().day) {
      switch (action) {
        case 'cancel_adhoc_sale':
          var dialogResponse = await _dialogService.showConfirmationDialog(
              title: 'Cancel Transaction',
              description:
                  'Are you sure you want to cancel this transaction ? You cannot undo this action.',
              cancelTitle: 'NO',
              confirmationTitle: 'Yes, I am sure');
          if (dialogResponse.confirmed) {
            await cancelTransaction();
          }
          break;
        case 'edit_adhoc_sale':
          toggleEditState();
          break;
      }
    } else {
      await _dialogService.showDialog(
          title: 'Date Expired',
          description: 'You cannot perform this action. ');
    }
  }

  //Flag to enable disable editable fields
  bool _inEditState = false;
  bool get inEditState => _inEditState;

  toggleEditState() async {
    if (inEditState) {
      var dialogResponse = await _dialogService.showConfirmationDialog(
          title: 'Confirm Clear Changes',
          description:
              'Are you sure you want to clear / reset the changes you have made');
      if (dialogResponse.confirmed) {
        _inEditState = !inEditState;
        clearChanges();
      }
    } else {
      _inEditState = !inEditState;
      notifyListeners();
    }
  }

  // c -> current quantity/value of that item code on the old transaction (the one being replaced)
  // b -> the balance of stock for the item code right now
  // This item can be edited to a value between 0 and b+c max.
  isValidRange(int b, int c, var val) {
    if (num.parse(val) > 0 && num.parse(val) <= (b + c)) {
      return true;
    } else {
      return false;
    }
  }

  editTransaction() async {
    var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Update Transaction',
        description:
            'Are you sure you want to update this transaction ? You cannot undo this action.',
        cancelTitle: 'NO',
        confirmationTitle: 'Yes, I am sure');
    if (dialogResponse.confirmed) {
      await reverseTransaction();
    }
    // toggleEditState();
  }

  cancelTransaction() async {
    bool result = await _adhocService.cancelAdhocSale(
        referenceNo, token, adhocDetail, baseType, customerId);
    if (result) {
      await _dialogService.showDialog(
          title: 'Success',
          description: 'The transaction was cancelled successfully.');
      _navigationService.back(result: true);
    } else {
      await _dialogService.showDialog(
          title: 'Cancellation Error',
          description: 'The transaction could not be cancelled.');
    }
    return;
  }

  reverseTransaction() async {
    //Compare the two lists

    Map<String, dynamic> POSSaleRequest = {
      "customerId": adhocDetail.customerId,
      "customerName": adhocDetail.customerName,
      "deliveryLocation": "",
      "items": _memento
          .map((e) => {
                "itemCode": e.itemCode,
                "itemName": e.itemName,
                "itemRate": e.itemRate,
                "quantity": e.quantity
              })
          .toList(),
      "payment": {
        "amount": 0,
        "externalAccountId": "string",
        "externalTxnID": "string",
        "externalTxnNarrative": "string",
        "payerAccount": "string",
        "payerName": "string",
        "paymentMode": "string",
        "userTxnNarrative": "string"
      },
      "remarks": "",
      "sellingPriceList": adhocDetail.sellingPriceList,
      "warehouseId": adhocDetail.warehouseId
    };

    bool result = await _adhocService.editTransaction(
        adhocDetail.baseType, referenceNo, POSSaleRequest);
    if (result) {
      await _dialogService.showDialog(
          title: 'Success', description: 'The action was successful.');
      _navigationService.back(result: true);
    } else {
      await _dialogService.showDialog(
          title: 'Reversal Error',
          description: 'The action was not successful.');
    }
    return;
  }

  final String customerId;
  final String baseType;

  bool get isCancelled =>
      adhocDetail.transactionStatus.toLowerCase() == 'cancelled';

  void updateProduct(String val) {}

  // current quantity/value of that item code on the old transaction (the one being replaced)
  // the balance of stock for the item code right now
  getMax(SaleItem salesItem) {
    return productList
            .firstWhere((element) => element.itemCode == salesItem.itemCode,
                orElse: () => Product(quantity: 0))
            .quantity +
        salesItem.quantity;
  }

  void updateMemento(SaleItem saleItem, String val, index) {
    _memento[index].quantity = num.parse(val);
    notifyListeners();
  }

  resetMementoOnIndex(int index) {
    _memento[index] =
        _adhocDetail.saleItems.map((e) => SaleItem.fromMap(e)).toList()[index];
    notifyListeners();
  }

  clearChanges() {
    _memento = _adhocDetail.saleItems.map((e) => SaleItem.fromMap(e)).toList();
    notifyListeners();
  }

  bool get isChanged {
    return memento !=
        adhocDetail.saleItems.map((e) => SaleItem.fromMap(e)).toList();
  }

  void navigateToPrint() {
    CustomerDetail customerDetail = CustomerDetail.fromCustomer(
      Customer(
        id: customerId,
        name: adhocDetail.customerName,
        taxId: "",
      ),
    );
    Invoice _invoice = Invoice.fromAdhocDetail(adhocDetail, currency,
        customerDetail: customerDetail);
    _navigationService.navigateToView(PrintView(
      invoice: _invoice,
      deliveryNote: adhocDetail,
      title: 'e-Invoice',
      user: _userService.user,
      orderId: referenceNo,
      customerTIN: adhocDetail.customerTIN,
    ));
  }
}
