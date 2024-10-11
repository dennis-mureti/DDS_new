import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class ConfirmStockTransferViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _userService = locator<UserService>();
  final _apiService = locator<ApiService>();

  Api get api => _apiService.api;
  User get user => _userService.user;
  get salesChannel => user.salesChannel;
  get branch => user.branch;

  final List<Product> stockTransferItems;

  List<Product> _modifiedItems;
  List<Product> get modifiedItems => _modifiedItems;

  ConfirmStockTransferViewModel(this.stockTransferItems, this.sourceOutlet)
      : _modifiedItems = stockTransferItems;

  deleteItem(Product p) {
    _modifiedItems.remove((element) =>
        element.itemName.toString().toLowerCase() == p.itemName.toLowerCase());
    notifyListeners();
  }

  commit() async {
    List items = [];
    stockTransferItems.forEach((element) {
      Map e = {
        "item": {
          "id": "${element.id}",
          "itemCode": "${element.itemCode}",
          "itemName": "${element.itemName}",
          "itemPrice": element.itemPrice,
          "itemFactor": element.itemFactor,
        },
        "quantity": element.quantity
      };
      items.add(e);
    });
    var payload = {
      "fromWarehouse": sourceOutlet, // Source Branch
      "toWarehouse": salesChannel, // Destination shop
      "items": items.toList(),
    };
    setBusy(true);
    var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Confirm Stock Transfer Request',
        description:
            'Are you sure you want to place a stock transfer request for the SKU(s) you have listed.',
        cancelTitle: 'NO',
        confirmationTitle: 'Yes');
    if (dialogResponse.confirmed) {
      var response = await api.makeStockTransferRequest(
          token: user.token, payload: payload);
      if (response is bool) {
        await _dialogService.showDialog(
            title: 'Success',
            description: 'Your stock transfer request was successful.');
      } else {
        await _dialogService.showDialog(
            title: 'Stock Transfer failed',
            description:
                'Your stock transfer request was not successful.\n${response.toString()}');
      }
      _navigationService.pushNamedAndRemoveUntil(Routes.homeView,
          arguments: HomeViewArguments(index: 2));
    }
    setBusy(false);
  }

  final String sourceOutlet;
}
