import 'package:distributor/app/locator.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/stock_controller_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

@lazySingleton
class ReturnStockService {
  UserService _userService = locator<UserService>();
  ApiService _apiService = locator<ApiService>();
  final _dialogService = locator<DialogService>();
  final _stockControllerService = locator<StockControllerService>();
  Api get api => _apiService.api;

  User get user => _userService.user;
  String get userChannel => user.salesChannel;

  List<Product> _itemsToReturn = <Product>[];
  List<Product> get itemsToReturn => _itemsToReturn;

  bool get canReturn => itemsToReturn != null && itemsToReturn.isNotEmpty;

  reset() {
    _itemsToReturn = [];
  }

  List<Product> _productList = <Product>[];
  List<Product> get productList => _productList;

  fetchStockBalance() async {
    var result = await _stockControllerService.getStockBalance();
    if (result is List<Product>) {
      _productList = result;
      return productList
          .where((product) =>
              !product.itemName.trim().toLowerCase().contains('crate'))
          .toList();
    } else if (result is CustomException) {
      _productList = <Product>[];
      await _dialogService.showDialog(
          title: result.title, description: result.description);
      return <Product>[];
    }
  }

  var _payload;

  // Return an empty list of items
  returnEmpty() async {
    // Data for shop return
    var data = {
      "fromWarehouse": userChannel,
      "items": [],
      "toWarehouse": user.branch
    };
    var result = await api.shopReturn(user.token, stockTransferData: data);
    return result;
  }

  returnItems() async {
    DialogResponse dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Stock Return Confirmation',
        description: 'Are you sure you want to process stock to the branch ?',
        confirmationTitle: 'Yes',
        cancelTitle: 'NO');
    if (dialogResponse.confirmed) {
      if (itemsToReturn.isEmpty) {
        List<Product> result = await fetchStockBalance();
        _payload = result.map((product) {
          return {"item": product.toJson(), "quantity": 0};
        });
      } else {
        _payload = itemsToReturn.map((product) {
          return {"item": product.toJson(), "quantity": product.quantity};
        });
      }
      // Data for shop return
      var data = {
        "fromWarehouse": userChannel,
        "items": _payload.toList(),
        "toWarehouse": user.branch
      };
      var result = await api.shopReturn(user.token, stockTransferData: data);
      if (result is String) {
        await _dialogService.showDialog(title: 'Error', description: result);
        return false;
      } else {
        await _dialogService.showDialog(
            title: 'Success',
            description:
                'The stock was returned successfully.Use the Pending Stock Transactions Button to commit this transaction.');
        return true;
      }
    }
  }

  void updateItemsToReturn(Product product) {
    if (itemsToReturn.isNotEmpty) {
      int index =
          itemsToReturn.indexWhere((p) => p.itemCode == product.itemCode);
      if (index.isNegative && product.quantity > 0) {
        _itemsToReturn.add(product);
      } else {
        //The index is positive
        //The element exists
        if (product.quantity <= 0) {
          //Remove this item
          _itemsToReturn.removeAt(index);
        } else {
          //Replace the value at this index since it is not zero
          _itemsToReturn[index] = product;
        }
      }
    } else {
      if (product.quantity > 0) {
        _itemsToReturn.add(product);
      }
    }
    return;
  }
}
