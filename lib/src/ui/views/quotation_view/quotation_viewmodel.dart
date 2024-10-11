import 'package:distributor/app/router.gr.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:distributor/src/ui/views/quotation_view/confirm_quotation_view.dart';
import 'package:distributor/ui/views/home/home_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

import '../../../../app/locator.dart';
import '../../../../core/models/product_service.dart';

enum CustomerTypesDisplay { none, walkin, contract }

class QuotationViewModel extends BaseViewModel {
  final _productService = locator<ProductService>();
  final _customerService = locator<CustomerService>();
  final _navigationService = locator<NavigationService>();

  bool get isValid => contractCustomer != null && itemsInCart.isNotEmpty;

  List<Product> _productList = <Product>[];
  List<Product> get productList {
    return _productList.where((product) => product.itemPrice > 0).toList();
  }

  List<Customer> _customerList = <Customer>[];
  List<Customer> get customersList => _customerList;

  String _skuSearchString = "";
  String get skuSearchString => _skuSearchString;

  fetchCustomers() async {
    setBusy(true);
    _customerList = await _customerService.fetchCustomers();
    setBusy(false);
  }

  CustomerTypesDisplay get customerTypesDisplay => _customerTypesDisplay;

  Customer _contractCustomer;
  Customer get contractCustomer => _contractCustomer;
  updateContractCustomer(Customer c) {
    _contractCustomer = c;
    notifyListeners();
  }

  String get customerType => _customerType;

  String _customerType;
  CustomerTypesDisplay _customerTypesDisplay = CustomerTypesDisplay.contract;

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

  generateQuotation() async {
    setBusy(true);
    Map<String, dynamic> data = {
      "bill": "",
      "customer": contractCustomer != null
          ? contractCustomer.customerCode
          : customerName,
      "dueDate": DateTime.now().toUtc().toIso8601String(),
      "items": itemsInCart
          .map((e) => {
                "amount": "${e.itemPrice * e.quantity}",
                "item": {
                  "id": "${e.id}",
                  "itemCode": "${e.itemCode}",
                  "itemName": "${e.itemName}",
                  "itemPrice": "${e.itemPrice}",
                  "itemType": "product",
                  "priceList": "4SumPriceList"
                },
                "quantity": e.quantity,
                "rate": e.itemPrice,
                "tax": "16%",
              })
          .toList(),
      "orderType": "Sales Quotation",
      "warehouse": ""
    };
    await _productService.createNewQuotation(data);
    setBusy(false);
    _navigationService.navigateTo(Routes.homeView, id: 2);
  }

  navigateToConfirmQuotationView() async {
    await _navigationService.navigateToView(ConfirmQuotationView(
      orderedItems: itemsInCart,
      customer: contractCustomer,
    ));
  }

  init() async {
    _items = await fetchItems();
    await fetchCustomers();
    _itemsInCart = items;
    await fetchItems();
  }

  List<Product> _items = [];
  List<Product> get items {
    if (skuSearchString.isNotEmpty) {
      return _items
          .where((element) =>
              element.itemName.toLowerCase().contains(skuSearchString))
          .toList();
    } else {
      return _items;
    }
  }

  List _itemsInCart = [];
  List get itemsInCart =>
      _itemsInCart.where((element) => element.quantity > 0).toList();

  updateQuantity({Product product, var newVal}) {
    var item = _itemsInCart.firstWhere(
        (element) =>
            element.itemName.toLowerCase() == product.itemName.toLowerCase(),
        orElse: () => product);
    item.updateQuantity(newVal);
    notifyListeners();
  }

  getQuantity(Product product) {
    var result = _itemsInCart.firstWhere(
        (element) =>
            element.itemName.toLowerCase() == product.itemName.toLowerCase(),
        orElse: () => null);
    return result?.quantity ?? 0;
  }

  getTotal(Product product) {
    var result = _itemsInCart.firstWhere(
        (element) =>
            element.itemName.toLowerCase() == product.itemName.toLowerCase(),
        orElse: () => null);
    return result?.quantity == null ? 0 : result.quantity * product.itemPrice;
  }

  fetchItems() async {
    setBusy(true);
    _productList = await _productService.listAllItems();
    //Initialize the stock transfer items with the value of product list
    _orderedItems = _productList;
    _items = _productList;
    _itemsInCart = _items;
    setBusy(false);
  }

  List<Product> _orderedItems = <Product>[];
  List<Product> get orderedItems =>
      _orderedItems.where((element) => element.quantity > 0).toList();

  List _quotations = [];
  List get quotations => _quotations;

  fetchQuotationList() async {
    setBusy(true);
    _quotations = await _productService.fetchQuotationList();
    setBusy(false);
    notifyListeners();
  }

  convertToOrder() async {}
  share() async {}

  String _customerName = "";
  String get customerName => _customerName;
  void updateCustomerName(String value) {
    _customerName = value;
    notifyListeners();
  }

  void updateSearchString(String value) {
    _skuSearchString = value;
    notifyListeners();
  }

  resetSearch() {
    _skuSearchString = "";
    notifyListeners();
  }
}
