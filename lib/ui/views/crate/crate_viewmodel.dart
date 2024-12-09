import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/core/enums.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/crate_,management_service.dart';
import 'package:distributor/services/logistics_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class CrateViewModel extends BaseViewModel {
  final _crateService = locator<CrateManagementService>();
  final _navigationService = locator<NavigationService>();
  final _logisticsService = locator<LogisticsService>();
  final _userService = locator<UserService>();
  final _apiService = locator<ApiService>();

  Api get _api => _apiService.api;

  User get user => _userService.user;

  bool get hasJourneys {
    if (_logisticsService.userJourneyList.length > 0 || user.hasSalesChannel) {
      return true;
    } else {
      return false;
    }
  }

  List<Product> _crates;
  List<Product> get crates => _crates;

  bool get hasSelectedJourney {
    if (_logisticsService.userJourneyList.length > 0 &&
            _logisticsService.currentJourney.journeyId != null ||
        user.hasSalesChannel) {
      return true;
    } else {
      return false;
    }
  }

  init() async {
    if (hasSelectedJourney) {
      await _api.pushOfflineTransactionsOnViewRefresh(user.token);
      await _getCrates();
      await _getCrateListing();
    }
  }

  _getCrates() async {
    setBusy(true);
    _crates = await _crateService.fetchCrates();
    setBusy(false);
    notifyListeners();
  }

  List<Product> _crateList = <Product>[];
  List<Product> get crateList => _crateList;

  _getCrateListing() async {
    setBusy(true);
    _crateList = await _crateService.fetchCrates();
    // _crateList = _result.map((item) {
    //   if (crates.isNotEmpty || crates != null) {
    //     return crates.firstWhere((product) => product.itemCode == item.itemCode,
    //         orElse: () => Product(
    //             id: item.id,
    //             itemName: item.name,
    //             itemCode: item.itemCode,
    //             itemPrice: item.itemPrice,
    //             quantity: 0));
    //   }
    // }).toList();
    setBusy(false);
    notifyListeners();
  }

  void navigateToManageCrateView(
      {String crateTxnType, String crateType}) async {
    await _navigationService.navigateTo(Routes.manageCrateView,
        arguments: ManageCrateViewArguments(
            crateType: crateType, crateTxnType: crateTxnType));
  }

  void handleOrderAction(x) async {
    switch (x) {
      case 'drop_crates': //Drop the crates at a customer
        var result =
            await _navigationService.navigateTo(Routes.crateMovementView,
                arguments: CrateMovementViewArguments(
                  crateTxnType: CrateTxnType.Drop,
                ));
        if (result is bool) {
          await _getCrates();
          await _getCrateListing();
          return;
        }
        break;
      case 'receive_crates': // Receive crates from a customer
        var result = await _navigationService.navigateTo(
          Routes.crateMovementView,
          arguments: CrateMovementViewArguments(
            crateTxnType: CrateTxnType.Pickup,
          ),
        );
        if (result is bool) {
          await _getCrates();
          await _getCrateListing();
          return;
        }
        break;
    }
  }
}
