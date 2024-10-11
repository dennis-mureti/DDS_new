import 'package:distributor/app/locator.dart';
import 'package:distributor/src/ui/views/pos/base_pos_viewmodel.dart';
import 'package:distributor/src/ui/views/pos/scanner/scanner_view.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class POSViewmodel extends BasePOSViewModel {
  final _navigationService = locator<NavigationService>();

  List _itemsInCart = [];
  List get itemsInCart =>
      _itemsInCart.where((element) => element.quantity > 0).toList();

  List _items = [];
  List get items => _items;

  List views = ['Grid', 'List'];

  bool isToggled = false;

  init() async {
    setBusy(true);
    _items = await fetchStockBalance();
    _itemsInCart = items;
    setBusy(false);
    notifyListeners();
  }

  _getItems() async {
    setBusy(true);
    _items = await fetchStockBalance();
    setBusy(false);
    notifyListeners();
  }

  String _view;
  String get view => _view ?? views.first;
  toggleView() {
    if (view.toLowerCase() == 'grid') {
      _view = views.last;
      isToggled = true;
    } else {
      _view = views.first;
      isToggled = false;
    }
    notifyListeners();
  }

  addItemToCart(var item) async {}
  removeItemFromCart(var item) async {}
  updateItemInCart(var item) async {}

  // Get the quantity of each element
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

  void search() async {}
  void sort() async {}
  void vert() async {}

  ///
  /// Update the quantity from the input
  ///
  updateQuantity({Product product, var newVal}) {
    var item = _itemsInCart.firstWhere(
        (element) =>
            element.itemName.toLowerCase() == product.itemName.toLowerCase(),
        orElse: () => product);
    item.updateQuantity(newVal);
    notifyListeners();
  }

  void navigateToScannerView() async {
    var result = await _navigationService.navigateToView(ScannerView());
  }
}
