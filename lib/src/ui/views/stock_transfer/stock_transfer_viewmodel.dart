import 'package:distributor/app/locator.dart';
import 'package:distributor/services/init_service.dart';
import 'package:distributor/services/return_stock_service.dart';
import 'package:distributor/services/stock_controller_service.dart';
import 'package:distributor/traits/contextual_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class StockTransferViewmodel extends BaseViewModel with ContextualViewmodel {
  final _dialogService = locator<DialogService>();
  StockControllerService _stockControllerService =
      locator<StockControllerService>();
  final _returnStockService = locator<ReturnStockService>();
  final _navigationService = locator<NavigationService>();
  final _initService = locator<InitService>();

  bool get canReturnEmptyStock =>
      _initService.appEnv.flavorValues.applicationParameter.returnEmptyStock;

  List<Product> _productList;
  List<Product> get productList => _productList;

  init() async {
    _returnStockService.reset();
    await fetchStockBalance();
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
    var result = await _returnStockService.returnItems();
    setBusy(false);
    _navigationService.back(result: result);
  }

  void reset() async {
    _returnStockService.reset();
    notifyListeners();
  }

  onChange(Product product) {
    // print('I have changed ${product.quantity} pcs to ${product.itemName}');
    _returnStockService.updateItemsToReturn(product);
    notifyListeners();
  }
}
