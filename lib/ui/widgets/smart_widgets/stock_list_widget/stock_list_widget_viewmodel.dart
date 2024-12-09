import 'package:distributor/app/locator.dart';
import 'package:distributor/services/access_controller_service.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/init_service.dart';
import 'package:distributor/services/stock_controller_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class StockListWidgetViewModel extends BaseViewModel {
  DialogService _dialogService = locator<DialogService>();
  StockControllerService _stockControllerService =
      locator<StockControllerService>();
  final InitService _initService = locator<InitService>();
  final _apiService = locator<ApiService>();

  Api get _api => _apiService.api;

  List<Product> _productList;
  bool get enableOffline => _initService
      .appEnv.flavorValues.applicationParameter.enableOfflineService;

  StockListWidgetViewModel(bool rebuildTree) : _rebuildTree = rebuildTree {
    if (rebuildTree) {
      fetchStockBalance();
    }
  }

  final _accessControlService = locator<AccessControlService>();
  User get user => _accessControlService.user;

  bool get isMiniShop {
    if (user.hasSalesChannel) {
      return true;
    } else {
      return false;
    }
  }

  List<Product> get productList => _productList;

  final bool _rebuildTree;
  get rebuildTree => _rebuildTree ?? false;

  init() async {
    //Enable offline services
    if (enableOffline) {
      await _api.pushOfflineTransactionsOnViewRefresh(user.token);
    }
    await fetchStockBalance();
  }

  fetchStockBalance() async {
    setBusy(true);
    var result = await _stockControllerService.getStockBalance();
    setBusy(false);
    if (result is List<Product>) {
      if (user.hasSalesChannel) {
        _productList = result;
      } else {
        _productList = result
            .where((element) =>
                element.itemName.toLowerCase().contains('crates') != true)
            .toList();
      }
      notifyListeners();
    } else if (result is CustomException) {
      _productList = <Product>[];
      notifyListeners();
      await _dialogService.showDialog(
          title: result.title, description: result.description);
    }
  }
}
