import 'package:distributor/app/locator.dart';
import 'package:distributor/core/models/product_service.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/ui/views/confirm_stock_transfer/confirm_stock_transfer_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class StockTransferRequestViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _customerService = locator<CustomerService>();
  final _dialogService = locator<DialogService>();
  final _productService = locator<ProductService>();
  final _userService = locator<UserService>();

  String _skuSearchString = "";
  String get skuSearchString => _skuSearchString;
  void updateSearchString(String value) {
    _skuSearchString = value;
    notifyListeners();
  }

  resetSearch() {
    _skuSearchString = "";
    notifyListeners();
  }

  String get mainOutlet => _userService.user.branch;

  List<Product> _productList = <Product>[];
  List<Product> get productList {
    if (skuSearchString.isNotEmpty) {
      return _productList
          .where((element) =>
              element.itemName.toLowerCase().contains(skuSearchString))
          .toList();
    } else {
      return _productList.where((product) => product.itemPrice > 0).toList();
    }
  }

  List<Warehouse> _outletList = <Warehouse>[];
  List<Warehouse> get outletList => _outletList;

  Warehouse _selectedOutlet;
  Warehouse get selectedOutlet => _selectedOutlet;
  updateSelectedOutlet(var data) {
    _selectedOutlet = data;
    _sourceOutlet = data.name;
    notifyListeners();
  }

  String _stockTransferType;
  String get stockTransferType => _stockTransferType;

  updateStockTransferType(String val) async {
    _stockTransferType = val;
    if (val == "main") {
      _sourceOutlet = mainOutlet;
      await fetchItems();
      notifyListeners();
    }
    if (val == "interoutlet") {
      await fetchItems();
      notifyListeners();
    }
  }

  init() async {
    // await fetchItems()
    await fetchVirtualWarehouses();
  }

  //Fetch all the outlets
  fetchVirtualWarehouses() async {
    setBusy(true);
    var result = await _customerService.listVirtualWarehouses();
    _outletList = result;
    setBusy(false);
  }

  fetchItems() async {
    setBusy(true);
    _productList = await _productService.listAllItems();
    //Initialize the stock transfer items with the value of product list
    _stockTransferItems = _productList;
    setBusy(false);
  }

  List<Product> _stockTransferItems = <Product>[];
  List<Product> get stockTransferItems =>
      _stockTransferItems.where((element) => element.quantity > 0).toList();

  ///
  /// Add to the existing quantity
  ///
  addQuantity(Product product, {int value = 1}) {
    var item = _stockTransferItems.firstWhere(
        (element) =>
            element.itemName.toLowerCase() == product.itemName.toLowerCase(),
        orElse: () => product);
    // Update the item quantity
    item.updateQuantity(item.quantity + value);
    notifyListeners();
  }

  ///
  /// Remove from the current quantity
  ///
  removeQuantity(Product product, {var value = 1}) {
    var item = _stockTransferItems.firstWhere(
        (element) =>
            element.itemName.toLowerCase() == product.itemName.toLowerCase(),
        orElse: () => product);
    // Update the item quantity
    if (item.quantity > 0) {
      item.updateQuantity(item.quantity - value);
      notifyListeners();
    }
  }

  // Get the quantity of each element
  getQuantity(Product product) {
    var result = _stockTransferItems.firstWhere(
        (element) =>
            element.itemName.toLowerCase() == product.itemName.toLowerCase(),
        orElse: () => null);
    return result?.quantity ?? 0;
  }

  ///
  /// Update the quantity from the input
  ///
  updateQuantity({Product product, var newVal}) {
    var item = _stockTransferItems.firstWhere(
        (element) =>
            element.itemName.toLowerCase() == product.itemName.toLowerCase(),
        orElse: () => product);
    item.updateQuantity(newVal);
    notifyListeners();
  }

  String _sourceOutlet = "";
  String get sourceOutlet => _sourceOutlet;

  commit() async {
    var result =
        await _navigationService.navigateToView(ConfirmStockTransferView(
      stockTransferItems: stockTransferItems,
      sourceOutlet: sourceOutlet,
    ));
  }
}
