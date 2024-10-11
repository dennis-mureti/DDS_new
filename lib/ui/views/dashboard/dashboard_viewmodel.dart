import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/core/enums.dart';
import 'package:distributor/services/access_controller_service.dart';
import 'package:distributor/services/logistics_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/src/ui/views/pos/invoicing/invoicing_view.dart';
import 'package:distributor/src/ui/views/pos/item_selection/pos_view.dart';
import 'package:distributor/src/ui/views/pos/sales_returns/sales_returns_view.dart';
import 'package:distributor/src/ui/views/quotation_view/quotation_view.dart';
import 'package:distributor/src/ui/views/stock_transaction/stock_transaction_list_view.dart';
import 'package:distributor/traits/contextual_viewmodel.dart';
import 'package:distributor/ui/views/stock_transfer_request/stock_transfer_request_view.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class DashboardViewModel extends FutureViewModel<List<DeliveryJourney>>
    with ContextualViewmodel {
  LogisticsService _logisticsService = locator<LogisticsService>();
  UserService _userService = locator<UserService>();
  DialogService _dialogService = locator<DialogService>();
  AccessControlService _accessControlService = locator<AccessControlService>();
  NavigationService _navigationService = locator<NavigationService>();

  navigateToPendingStockTransactions() async {
    _navigationService.navigateTo(Routes.stockTransactionListView);
  }

  navigateToReturnStock() async {
    _navigationService.navigateTo(Routes.stockTransferView);
  }

  navigateToNewContractSale() async {
    await _navigationService.navigateTo(Routes.adhocSalesView,
        arguments: AdhocSalesViewArguments(saleType: CustomerType.Contract));
  }

  navigateToWalkInSale() async {
    await _navigationService.navigateTo(Routes.adhocSalesView,
        arguments: AdhocSalesViewArguments(saleType: CustomerType.Walk_In));
  }

  User get user => _userService.user;
  bool get hasJourney => _logisticsService.hasJourney;
  final String formattedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());

  //Check if user can list journeys
  bool get canListJourneys => _accessControlService.enableJourneyTab;

  // bool get isMiniShop {
  //   if (user.hasSalesChannel) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  bool get isMiniShop => _accessControlService.isOutlet;

  Future fetchUserJourneys() async {
    //Check if this is a minishop
    if (!user.hasSalesChannel) {
      var result = await _logisticsService.fetchJourneys();
      return result;
    }
  }

  @override
  Future<List<DeliveryJourney>> futureToRun() async {
    List<DeliveryJourney> result = await fetchUserJourneys();

    return result;
  }

  @override
  void onData(List<DeliveryJourney> data) {
    // SystemNavigator.pop();
    super.onData(data);
  }

  @override
  void onError(error) async {
    await _dialogService.showDialog(
        title: 'Error', description: error.toString());
    super.onError(error);
  }

  init() async {
    // This is not a minishop
    // Dont fetch user journeys
    if (!user.hasSalesChannel) {
      await _logisticsService.fetchJourneys();
    }
  }

  UserSummary _userSummary;
  UserSummary get userSummary => _userSummary;

  navigateToPostSale() async {
    _navigationService.navigateToView(POSView());
  }

  navigateToSalesTab() async {
    _navigationService.navigateTo(
      Routes.homeView,
      arguments: HomeViewArguments(index: 1),
    );
  }

  navigateToSalesReturns() async {
    await _navigationService.navigateToView(SalesReturnsView());
  }

  navigateToPendingTransactions() async {
    _navigationService.navigateToView(
      StockTransactionListView(),
    );
  }

  navigateToStockTransferRequest() async {
    _navigationService.navigateToView(
      StockTransferRequestView(),
    );
  }

  navigateToCreateQuotationView() async {
    _navigationService.navigateToView(
      QuotationView(),
    );
  }

  navigateToInvoicingView() async {
    _navigationService.navigateTo(
      Routes.homeView,
      arguments: HomeViewArguments(index: 4),
    );
  }

  navigateToAddAdhocSale() async {
    var result = await _navigationService.navigateTo(Routes.adhocSalesView);
    if (result is bool) {
      setBusy(true);
      // _startDate = DateTime.now();
      // await fetchAdhocSales();
      setBusy(false);
    }
  }
}
