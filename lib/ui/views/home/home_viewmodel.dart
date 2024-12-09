import 'dart:async';

import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/core/enums.dart';
import 'package:distributor/core/models/app_models.dart';
import 'package:distributor/services/access_controller_service.dart';
import 'package:distributor/services/activity_service.dart';
import 'package:distributor/services/adhoc_cart_service.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/init_service.dart';
import 'package:distributor/services/journey_service.dart';
import 'package:distributor/services/logistics_service.dart';
import 'package:distributor/services/permission_service.dart';
import 'package:distributor/services/timeout_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/traits/contextual_viewmodel.dart';
import 'package:distributor/ui/views/adhoc_sales/adhoc_sales_view.dart';
import 'package:distributor/ui/views/customers/customer_view.dart';
import 'package:distributor/ui/views/dashboard/dashboard_view.dart';
import 'package:distributor/ui/views/routes/route_listing_view.dart';
import 'package:distributor/ui/views/stock/stock_view.dart';
import 'package:distributor/ui/views/stock_transfer_request/stock_transfer_request_view.dart';
import 'package:distributor/ui/views/stock_transfer_request_view/stock_transfer_request_listing.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class HomeViewModel extends ReactiveViewModel with ContextualViewmodel {
  final _apiService = locator<ApiService>();
  PermissionService _permissionService = locator<PermissionService>();
  LogisticsService _logisticsService = locator<LogisticsService>();
  ActivityService _activityService = locator<ActivityService>();
  JourneyService _journeyService = locator<JourneyService>();
  AdhocCartService _adhocCartService = locator<AdhocCartService>();
  final _timeoutService = locator<TimeoutService>();
  final _snackbarService = locator<SnackbarService>();
  Timer get timer => _timeoutService.timer;
  // final geoFenceService = locator<GeoFenceService>();

  ConnectivityStatus _connectivityStatus;
  ConnectivityStatus get connectivityStatus => _connectivityStatus;

  String get currency =>
      _initService.appEnv.flavorValues.applicationParameter.currency;

  updateConnectivityStatus(ConnectivityStatus connectivityStatus) {
    _connectivityStatus = connectivityStatus;
    notifyListeners();
  }

  Api get api => _apiService.api;

  UserService _userService = locator<UserService>();
  NavigationService _navigationService = locator<NavigationService>();
  InitService _initService = locator<InitService>();
  AccessControlService _accessControlService = locator<AccessControlService>();

  bool get enableOffline => _initService
      .appEnv.flavorValues.applicationParameter.enableOfflineService;

  final _dialogService = locator<DialogService>();

  fetchAllCustomers() async {
    setBusy(true);
    _customerList = await api.fetchAllCustomers(_userService.user.token);
    setBusy(false);
    notifyListeners();
    return _customerList;
  }

  List<Customer> _customerList = [];
  List<Customer> get customerList => _customerList;

  syncData() async {
    setBusy(true);
    _snackbarService.showSnackbar(
        message: 'Synchronization in progress', title: 'Offline Data sync');
    List customerList = await fetchAllCustomers();
    var result = await _apiService.api
        .synchronizeData(_userService.user.token, user,
            _logisticsService.userJourneyList, customerList)
        .then((value) {
      _snackbarService.showSnackbar(
          message: 'Synchronization Complete', title: 'Offline Data sync');
    });
    //Fetch the data
    setBusy(false);
  }

  HomeViewModel(int index, ConnectivityStatus connectivityStatus)
      : _currentIndex = index,
        _connectivityStatus = connectivityStatus;

  String get noOfUpdates => _activityService.noOfUpdates.toString();

  bool get showPendingStockTransactionsIconButton =>
      renderPendingStockTransactionsButton && currentIndex == 3;

  get enableJourneyTab => _accessControlService.enableJourneyTab;
  get enableHomeTab => _accessControlService.enableHomeTab;

  get enableAdhocTab => _accessControlService.enableAdhocView;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  DateTime get endDate => _endDate;
  DateTime get startDate => _startDate;

  bool _hasPendingTransactions = false;
  bool get hasPendingTransactions => _hasPendingTransactions;

  setStartDate(DateTime dt) {
    _startDate = dt;
    notifyListeners();
  }

  setEndDate(DateTime dt) {
    _endDate = dt;
    notifyListeners();
  }

  refresh() async {
    setBusy(true);
    await _logisticsService.fetchJourneys();
    setBusy(false);
  }

  navigateToPasswordReset() async {
    await _navigationService.navigateTo(Routes.resetPasswordView);
  }

  navigateToChangePassword() async {
    await _navigationService.navigateTo(Routes.changePasswordView,
        arguments: ChangePasswordViewArguments(
            passwordChangeType: PasswordChangeType.user));
  }

  navigateToTerritoryView() async {
    await _navigationService.navigateTo(Routes.territoryView);
  }

  bool get hasActivityUpdate => _activityService.hasUpdate;

  DeliveryJourney get currentJourney => _logisticsService.currentJourney;

  bool get onTrip {
    if (hasJourney) {
      if (_logisticsService.currentJourney.journeyId != null) {
        return true;
      } else
        return false;
    } else {
      return false;
    }
  }

  AppEnv get appEnv => _initService.appEnv;

  User get user => _userService.user;

  logout() async {
    // Stop the timer
    timer.cancel();
    //Sync the data
    // await syncData();
    // Clear the cache
    await _userService.clearAPPCache();

    //Sync the data
    // _dialogService.showDialog(title: 'Sync In Progress', description: 'Offline data synchronization in progress');

    // Clear the unnecessary services
    await _navigationService.pushNamedAndRemoveUntil(Routes.loginView);
  }

  bool get hasJourney => _logisticsService.hasJourney;

  String _title = "Home";
  String get title => _title;

  Pages _pageToDisplay;
  Pages get pageToDisplay => _pageToDisplay;

  Widget _pageContent = DashboardView();
  Widget get pageContent => _pageContent;

  updatePageToDisplay(Pages page, String title) {
    _pageToDisplay = page;
    _title = title;
    _pageContent = buildPage();
    notifyListeners();
  }

  updateCurrentPage(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  buildPage() {
    switch (_pageToDisplay) {
      case Pages.home:
        _pageContent = DashboardView();
        break;
      case Pages.adhoc:
        _pageContent = AdhocSalesView();
        break;
      case Pages.customers:
        _pageContent = CustomerView();
        break;
      case Pages.routes:
        _pageContent = RoutesListingView();
        break;
      case Pages.products:
        _pageContent = StockView();
        break;
      default:
        _pageContent = DashboardView();
        break;
    }
    return _pageContent;
  }

  bool get enableRouteTab => _accessControlService.enableJourneyTab;
  bool get enableProductTab => _accessControlService.enableStockTab;
  bool get enableCustomerTab => _accessControlService.enableCustomerTab;
  bool get enableAdhocSales =>
      _initService.appEnv.flavorValues.applicationParameter.enableAdhocSales;

  init() async {
    // await fetchAllCustomers();
    // geoFenceService.listenToGeofenceStatusStream();
    //Check if the user has permissions before enabling this
    if (user.hasSalesChannel || enableAdhocSales) {
      await fetchAdhocSales();
    } else {
      // await _logisticsService.fetchJourneys();
      await _permissionService.init();
    }
    return;
  }

  void navigateToJourneyMapView() async {
    _navigationService.navigateTo(Routes.deliveryJourneyMapView,
        arguments:
            DeliveryJourneyMapViewArguments(deliveryJourney: currentJourney));
  }

  navigateToNotificationsView() async {
    _navigationService.navigateTo(Routes.notificationView);
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices =>
      [_logisticsService, _journeyService, _activityService];

  navigateToHome(int index) {
    _navigationService.clearStackAndShow(Routes.homeView,
        arguments: HomeViewArguments(index: index));
  }

  int _currentIndex;
  int get currentIndex => _currentIndex;
  updateCurrentIndex(int val) {
    switch (val) {
      case 0: //Home
        // if(_accessControlService.enableJourneyTab){
        //   _currentIndex = val;
        //   notifyListeners();
        // }
        _currentIndex = val;
        notifyListeners();
        break;
      case 1: //Journey
        if (_accessControlService.enableJourneyTab) {
          _currentIndex = val;
          notifyListeners();
        }
        break;
      case 2: //Adhoc
        if (_accessControlService.enableAdhocView) {
          _currentIndex = val;
          notifyListeners();
        }
        break;
      case 3: // Stock Balance
        if (_accessControlService.enableStockTab) {
          _currentIndex = val;
          notifyListeners();
        }
        break;
      case 4: // Customers
        if (_accessControlService.enableCustomerTab) {
          _currentIndex = val;
          notifyListeners();
        }
        break;
    }
  }

  void navigateToAddAdhocSale() async {
    var result = await _navigationService.navigateTo(Routes.adhocSalesView);
    if (result is bool) {
      setBusy(true);
      _startDate = DateTime.now();
      await fetchAdhocSales();
      setBusy(false);
    }
  }

  fetchAdhocSales({DateTime postingDate}) async {
    setBusy(true);
    _adhocSalesList =
        await _adhocCartService.fetchAdhocSalesList(postingDate: postingDate);
    _adhocSalesList
        .where(
            (adhocSale) => adhocSale.referenceNo.toLowerCase().contains("pk-"))
        .toList();
    setBusy(false);
    notifyListeners();
  }

  bool _sortAsc = true;
  bool get sortAsc => _sortAsc;
  toggleSortAsc() {
    _sortAsc = !_sortAsc;
    notifyListeners();
  }

  bool _hasFilter = false;
  bool get hasFilter => _hasFilter;
  toggleHasFilter() {
    _hasFilter = !_hasFilter;
    notifyListeners();
  }

  List<AdhocSale> _adhocSalesList = <AdhocSale>[];

  List<AdhocSale> _memento;
  List<AdhocSale> get memento => _memento;

  List<AdhocSale> get adhocSalesList {
    if (_adhocSalesList.isNotEmpty) {
      if (sortAsc) {
        _adhocSalesList.sort((a, b) {
          return b.transactionDate.compareTo(a.transactionDate);
        });
      } else {
        _adhocSalesList.sort((a, b) {
          return a.transactionDate.compareTo(b.transactionDate);
        });
      }
      _memento = _adhocSalesList
          .where((element) => element.referenceNo.toLowerCase().contains('pk'))
          .toList();
      return _adhocSalesList
          .where((element) => element.referenceNo.toLowerCase().contains('pk'))
          .toList();
    }
    return _adhocSalesList;
  }

  navigateToAdhocDetail(
      String referenceNo, String customerId, String baseType) async {
    var result = await _navigationService.navigateTo(
      Routes.adhocDetailView,
      arguments: AdhocDetailViewArguments(
          referenceNo: referenceNo, customerId: customerId, baseType: baseType),
    );
    _startDate = DateTime.now();
    await fetchAdhocSales();
  }

  commitDateSelection() async {
    await fetchAdhocSales(postingDate: startDate);
    _navigationService.popRepeated(1);
  }

  final formatter = DateFormat('yyyy-MM-dd');

  onStockBalancePopupSelected(value) {
    switch (value) {
      case 0:
        navigateToPendingTransactionsView();
        notifyListeners();
        break;
      case 1:
        navigateToReturnStockView();
        break;
      case 2:
        navigateToReturnCrateView();
        break;
    }
  }

  navigateToBugView() async {
    _navigationService.back();
    await _navigationService.navigateTo(Routes.bugReportView);
  }

  navigateToInfoView() async {
    _navigationService.back();
    await _navigationService.navigateTo(Routes.appInfoView);
  }

  navigateToHelpView() async {
    _navigationService.back();
    await _navigationService.navigateTo(Routes.helpView);
  }

  void navigateToJourneyInfoView() async {
    await _navigationService.navigateTo(Routes.journeyInfoView);
  }

  void takeAction(String val) {
    switch (val.toLowerCase()) {
      case 'stock_transfer_request':
        _navigationService.navigateToView(StockTransferRequestView());
        break;
      case 'view_stock_transfers':
        _navigationService.navigateToView(StockTransferRequestListing());
        break;
      case 'print':
        break;
      case 'make_adhoc_sale':
        navigateToAddAdhocSale();
        break;
    }
  }
}
