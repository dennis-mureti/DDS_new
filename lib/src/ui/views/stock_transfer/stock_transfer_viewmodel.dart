import 'package:distributor/app/locator.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:distributor/services/init_service.dart';
import 'package:distributor/services/return_stock_service.dart';
import 'package:distributor/services/stock_controller_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/traits/contextual_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class StockTransferViewmodel extends BaseViewModel with ContextualViewmodel {
  final _dialogService = locator<DialogService>();
  final _customerService = locator<CustomerService>();
  StockControllerService _stockControllerService =
      locator<StockControllerService>();
  final _returnStockService = locator<ReturnStockService>();
  final _navigationService = locator<NavigationService>();
  final _initService = locator<InitService>();
  final _userService = locator<UserService>();

  List<Warehouse> _outletList = <Warehouse>[];
  List<Warehouse> get outletList => _outletList;

  Warehouse _selectedOutlet;
  Warehouse get selectedOutlet => _selectedOutlet;

  String _sourceOutlet = "";
  String get sourceOutlet => _sourceOutlet;

  updateSelectedOutlet(var data) {
    _selectedOutlet = data;
    _sourceOutlet = data.name;
    toWarehouse = data.name;
    notifyListeners();
  }

  bool get canReturnEmptyStock =>
      _initService.appEnv.flavorValues.applicationParameter.returnEmptyStock;

  List<Product> _returnableItems = [];
  List<Product> get returnableItems => _returnableItems;

  List<Product> _productList = [];
  List<Product> get productList {
    if (_productList.isNotEmpty) {
      // switch (_productOrdering) {
      //   case ProductOrdering.alphaAsc:
      //     _productList.sort((a, b) => a.itemCode.compareTo(b.itemCode));
      //     break;
      //   case ProductOrdering.alphaDesc:
      //     _productList.sort((b, a) => a.itemCode.compareTo(b.itemCode));
      //     break;
      // }
      if (skuSearchString.isNotEmpty) {
        return _productList
            .where((product) =>
                product.itemPrice > 0 &&
                product.itemName
                    .toLowerCase()
                    .contains(skuSearchString.toLowerCase()))
            .toList();
      } else {
        return _productList;
      }
      // return _productList.where((product) => product.itemPrice > 0).toList();
    }
    // return _productList;
  }

  String _skuSearchString = "";
  String get skuSearchString => _skuSearchString;

  //Fetch all the outlets
  fetchVirtualWarehouses() async {
    setBusy(true);
    var result = await _customerService.listVirtualWarehouses();
    _outletList = result;
    setBusy(false);
  }

  init() async {
    _returnStockService.reset();
    await fetchStockBalance();
    await fetchVirtualWarehouses();
  }

  _returnEmptyStock() async {
    if (canReturnEmptyStock && productList.isEmpty) {
      var dialogResponse = await _dialogService.showConfirmationDialog(
          title: 'Return Stock Confirmation',
          description:
              'You do not have any stock to return to the branch. Would you like to complete this transaction?',
          confirmationTitle: 'Yes',
          cancelTitle: 'No');

      if (dialogResponse.confirmed) {
        setBusy(true);
        var result = await _returnStockService.returnEmpty();
        setBusy(false);
        if (result is String) {
          await _dialogService.showDialog(
              title: 'Return Stock Error', description: result.toString());
          _navigationService.back();
        } else {
          await _dialogService.showDialog(
              title: 'Stock',
              description:
                  'You have successfully returned stock to the branch.');
          _navigationService.back();
        }
      }
    }
  }

  fetchStockBalance() async {
    var result = await _stockControllerService.getStockBalance();
    if (result is List<Product>) {
      _productList = result
          .where((product) =>
              !product.itemName.trim().toLowerCase().contains("crates"))
          .toList();
      notifyListeners();
      //Check if the list is empty and the user can return empty stock
      await _returnEmptyStock();
    } else if (result is CustomException) {
      _productList = <Product>[];
      notifyListeners();
      await _dialogService.showDialog(
          title: result.title, description: result.description);
    }
  }

  // bool get enableReturnToBranch => _returnStockService.canReturn;

  transferStock() async {
    setBusy(true);
    var result = await _returnStockService.returnItems(returnableItems,
        destinationOutlet: toWarehouse);
    setBusy(false);
    _navigationService.back(result: result);
  }

  String get mainOutlet => _userService.user.branch;

  updateStockTransferType(String val) async {
    _stockTransferType = val;
    if (val == "main") {
      _sourceOutlet = mainOutlet;
      toWarehouse = mainOutlet;
      // await fetchItems();
      notifyListeners();
    }
    if (val == "interoutlet") {
      // await fetchItems();
      notifyListeners();
    }
  }

  String toWarehouse;

  String _stockTransferType;
  String get stockTransferType => _stockTransferType;

  void reset() async {
    _returnStockService.reset();
    notifyListeners();
  }

  onChange(Product product) {
    // print('I have changed ${product.quantity} pcs to ${product.itemName}');
    _returnStockService.updateItemsToReturn(product);
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

  getQuantity(Product item) {
    var result = returnableItems.firstWhere((element) {
      return element.itemCode.toString().toLowerCase() ==
          item.itemCode.toString().toLowerCase();
    }, orElse: () => null);
    return result?.quantity ?? 0;
  }

  updateQuantity(Product item, var quantity) {
    //If the list is empty add the item
    if (returnableItems.isEmpty) {
      item.updateQuantity(quantity);
      returnableItems.add(item);
      notifyListeners();
      return;
    } else {
      //Check if it contains this item
      var result = returnableItems.indexOf(item);
      print(result);
      if (result == -1) {
        if (quantity > 0) {
          item.updateQuantity(quantity);
          returnableItems.add(item);
          notifyListeners();
        }
      } else {
        item.updateQuantity(quantity);
        if (quantity == 0) {
          returnableItems.removeAt(result);
        } else {
          returnableItems[result] = item;
        }
        notifyListeners();
      }
      // _returnStockService.updateItemsToReturn(item);
    }
  }
}
