import 'package:auto_route/auto_route.dart';
import 'package:distributor/app/locator.dart';
import 'package:distributor/core/models/app_models.dart';
import 'package:distributor/services/access_controller_service.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/journey_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class StockControllerService {
  AccessControlService _accessControlService = locator<AccessControlService>();
  JourneyService _journeyService = locator<JourneyService>();
  DeliveryJourney get currentJourney => _journeyService.currentJourney;
  final dialogService = locator<DialogService>();

  ApiService _apiService = locator<ApiService>();
  Api get _api => _apiService.api;
  UserService _userService = locator<UserService>();
  User get _user => _userService.user;

  bool _hasJourney = false;
  bool get hasJourney => _hasJourney;

  String get branchId => !_journeyService.hasJourney
      ? _userService.user.salesChannel
      : _journeyService.currentJourney.route;

  get journeyId => _journeyService.journeyId;

  getStockTransaction(String stockTransactionId, String voucherType) async {
    var result = await _api.getStockTransaction(_user.token,
        voucherType: voucherType, stockTransactionId: stockTransactionId);
    if (result != null) {
      return Transaction.fromMap(result);
    }
  }

//	Stock balance tab on L1 app is enabled if the user has
//	"virtual_stock_balance.view".
//	When the balances are displayed, the specific column "value of stock"
//	should only be displayed if the user has "virtual_stock_balance.view_cog" permission;
//	otherwise, hide this column

  getTransactionsPendingAuth() async {
    var result = await _api.getPendingAuthStockTransactions(_user.token,
        branchId: branchId, journeyId: journeyId);
    if (result is List) {
      return result.map((e) => Transaction.fromMap(e)).toList();
    } else {
      return <Transaction>[];
    }
  }

  getMiniShopStockRequests() async {
    var result = await _api.getMinishopTransactions(_user.token);
    if (result is List) {
      return result.map((e) => Transaction.fromMap(e)).toList();
    } else {
      return <Transaction>[];
    }
  }

  List<Product> _productList;
  List<Product> get productList => _productList;

  bool get enableProductTab => _accessControlService.enableStockTab;

  Future fetchProducts() async {
    return await _api.fetchAllProducts(_user.token);
  }

  fetchStockBalance() {
    bool result = false;
    if (_accessControlService.enableStockTab) {
      // Fetch the stock balance
      result = true;
    }
    return result;
  }

  bool showValueOfStock() {
    bool result = false;
    if (_accessControlService.displayValueOfStockColumn) {
      result = true;
    }
    return result;
  }

  getStockBalance() async {
    String branchId;
    if (_user.hasSalesChannel) {
      branchId = _user.salesChannel;
    } else {
      branchId = currentJourney.route;
    }
    var result =
        await _api.getStockBalance(token: _user.token, branchId: branchId);
    return result;
  }

  getUserPOSProfile() async {
    var result =
        await _api.getUserPOSProfile(token: _user.token, userId: _user.id);
    return result;
  }

  updateStatus(Transaction t, String status) async {
    var response = await _api.updateTransactionStatus(
        token: _user.token,
        voucherNo: t.stockTransactionId,
        voucherType: t.voucherType,
        status: status);
    return response;
  }

  confirmStockCollection(
      {@required String journeyId,
      @required String stopId,
      String deliveryLocation}) async {
    Map<String, dynamic> data = {
      "deliveryLocation": "string",
      "orderId": "string",
      "stopId": stopId
    };
    var result = await _apiService.api
        .completeTechStop(token: _user.token, journeyId: journeyId, data: data);
    return result;
  }

  /**
   * Return the stocks the branch
   * [fromWarehouse] is the route
   * [toWarehouse] is the branch
   */
  routeReturn({
    @required List<SalesOrderItem> stockReturnItems,
    @required String fromWarehouse,
    @required String toWarehouse,
    String reason = "",
  }) async {
    Map<String, dynamic> data = {
      "details": reason,
      "fromWarehouse": fromWarehouse,
      "toWarehouse": toWarehouse,
      "items": stockReturnItems
          .map((e) => {
                "item": {
                  "id": e.item.id,
                  "itemCode": e.item.itemCode,
                  "itemName": e.item.itemName,
                  "itemPrice": e.item.itemPrice
                },
                "quantity": e.quantity
              })
          .toList()
    };

    return await _apiService.api.routeReturn(token: _user.token, data: data);
  }

  fetchReasons() async {
    return await _apiService.api.getReturnReasonsList(_user.token);
  }
}
