// This service will manage information related to the current journey a user is involved in
// It will check the permissions that a user has and based on the per
import 'package:distributor/app/locator.dart';
import 'package:distributor/services/access_controller_service.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/logistics_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/ui/widgets/smart_widgets/info_bar/info_bar_widget_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:observable_ish/observable_ish.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

/// An enumeration of the states that a journey can be in
enum ActiveDeliveryJourneyState { selected, started, switched, completed }

class JourneyService with ReactiveServiceMixin {
  AccessControlService _accessControlService = locator<AccessControlService>();
  LogisticsService _logisticsService = locator<LogisticsService>();
  ApiService _apiService = locator<ApiService>();
  UserService _userService = locator<UserService>();
  DialogService _dialogService = locator<DialogService>();

  Api get _api => _apiService.api;
  User get _user => _userService.user;

  RxValue<String> _journeyStatus = RxValue<String>();
  String get journeyStatus {
    return _currentJourney.value.status;
  }

  updateJourneyStatus(String status) {
    _currentJourney.value.status = status;
  }

  JourneyService() {
    listenToReactiveValues([
      _deliveryStops,
      _currentJourney,
      _customers,
      _distanceTravelled,
      _salesOrder,
      _journeyStatus,
      _noOfCompletedStops,
      _journeyState
    ]);
  }

  DateTime _startTime;
  DateTime get startTime => _startTime;

  RxValue<double> _distanceTravelled = RxValue(initial: 0);
  RxValue<double> get distanceTravelled => _distanceTravelled;

  /// The state of the active delivery journey
  RxValue<ActiveDeliveryJourneyState> _activeDeliveryState = RxValue();
  ActiveDeliveryJourneyState get activeDeliveryState =>
      _activeDeliveryState.value;

  /// The [DeliveryStop] of the active [DeliveryJourney]
  RxValue<List<DeliveryStop>> _deliveryStops =
      RxValue<List<DeliveryStop>>(initial: <DeliveryStop>[]);
  List<DeliveryStop> get deliveryStops => _currentJourney.value.stops != null
      ? _currentJourney.value.stops
          .where((stop) => stop.orderId.isNotEmpty)
          .toList()
      : List<DeliveryStop>();

  /// The List of [SalesOrder] for this delivery
  RxValue<List<SalesOrder>> _salesOrder =
      RxValue<List<SalesOrder>>(initial: <SalesOrder>[]);
  List<SalesOrder> get salesOrder => _salesOrder.value;

  /// The [Customer] list in the  [DeliveryJourney]
  RxValue<List<Customer>> _customers =
      RxValue<List<Customer>>(initial: <Customer>[]);
  List<Customer> get customers => _customers.value;

  List<DeliveryStop> _completedStops = <DeliveryStop>[];
  List<DeliveryStop> get completedStops {
    return _completedStops;
  }

  RxValue<int> _noOfCompletedStops = RxValue<int>(initial: 0);
  int get noOfCompletedStops {
    if (_currentJourney.value.status.toLowerCase() == 'completed') {
      _noOfCompletedStops.value = deliveryStops.length;
    }
    return _noOfCompletedStops.value;
  }

  startTrip() async {
    ActionResultService result = await _api.postDeliveryJourneyUpdateStatus(
        deliveryStatusTriggers: DeliveryStatusTriggers.start,
        journeyId: currentJourney.journeyId,
        token: _user.token);

    /// Update the status of [journeyState] to [JourneyState.onGoing]
    /// Update the [journeyState]
    if (result.actionStatus == ActionStatus.success) {
      _journeyState.value = JourneyState.onTrip;
      init(currentJourney.journeyId)
          .then((value) => value)
          .catchError((e) => print(e.toString()));

      /// Fetch and populate all info
      return true;
    } else {
      /// The update failed. Return the error string to caller
      await _dialogService.showDialog(
          title: 'Error', description: result.message);
      return false;
    }
  }

  stopTrip() async {
    var result = await _api.postDeliveryJourneyUpdateStatus(
        deliveryStatusTriggers: DeliveryStatusTriggers.complete,
        journeyId: currentJourney.journeyId,
        token: _user.token);
    if (result.actionStatus == ActionStatus.success) {
      //The logistics service should be updated
      await _logisticsService.fetchJourneys();
      init(currentJourney.journeyId)
          .then((value) => value)
          .catchError((e) => e.toString());
      return true;
    } else {
      /// The update failed. Return the error string to caller
      return result.message;
    }
  }

  get completionStatus {
    return noOfCompletedStops / deliveryStops.length * 100;
  }

  Future makeCustomDelivery({@required var data}) async {
    var result =
        await _api.createCustomDelivery(token: _user.token, data: data);
    return result;
  }

  Future makeFullSODelivery(
    String orderId,
    String stopId,
    String deliveryLocation, {
    DeliveryNote deliveryNote,
  }) async {
    var result = await _api.makeFullDelivery(currentJourney.journeyId,
        salesOrderId: orderId,
        token: _user.token,
        stopId: stopId,
        deliveryLocation: deliveryLocation,
        deliveryNoteId: deliveryNote.deliveryNoteId,
        deliveryNote: deliveryNote,
        branchId: currentJourney.route);

    if (result is! CustomException) {
      _noOfCompletedStops.value++;
    }
    return result;
  }

  Future makeSalesReturns(
      {@required String journeyId, @required Map<String, dynamic> data}) async {
    print(_user.token);
    var result = await _api.makeSalesReturns(journeyId, _user.token, data);
    if (result is bool) {
      _noOfCompletedStops.value++;
    }
    return result;
  }

  /// The list of [LatLng] coordinates for the [DeliveryJourney]

  RxValue<DeliveryJourney> _currentJourney =
      RxValue(initial: DeliveryJourney());
  DeliveryJourney get currentJourney => _currentJourney.value;

  bool get hasJourney => _logisticsService.hasJourney;

  int get numberOfJourneys => _logisticsService.userJourneyList.length;

  //
  Future fetchUserJourney() async {
    var result = _logisticsService.fetchJourneys();
    return result;
  }

  // Enable the controls to Start/Stop a trip
  bool get enableJourneyControls => _accessControlService.enableJourneyControls;

  // Hide/Shop delivery summary
  bool get enableDeliveryDashboard =>
      _accessControlService.enableDeliveryDashboard;

  bool get enableJourneyTab => _accessControlService.enableJourneyTab;

  fetchJourneyInfo() {
    if (_accessControlService.enableJourneyTab) {
      return true;
    } else {
      return false;
    }
  }

  selectJourney(DeliveryJourney deliveryJourney) {
    _currentJourney.value = deliveryJourney;
  }

  initializeValues(String val) {
    switch (val.toLowerCase()) {
      case 'scheduled':
        _journeyState.value = JourneyState.scheduled;
        _journeyStatus.value = "Not Started";
        _noOfCompletedStops.value = 0;
        break;
      case 'in transit':
        _journeyState.value = JourneyState.onTrip;
        _journeyStatus.value = "In Transit";
        _noOfCompletedStops.value = 0;
        break;
      case 'completed':
        _journeyState.value = JourneyState.completed;
        _noOfCompletedStops.value = deliveryStops.length;
        _journeyStatus.value = "Completed";
        break;
      default:
        _journeyState.value = JourneyState.idle;
        break;
    }
  }

  Future init(String journeyId) async {
    _journeyId.value = journeyId;
    var result =
        await _api.getJourneyDetails(token: _user.token, journeyId: journeyId);
    if (result is DeliveryJourney) {
      _currentJourney.value = result;
      initializeValues(result.status);
      return true;
      // Fetch the stops for this delivery
    } else {
      return result;
    }
  }

  RxValue<String> _journeyId = RxValue<String>(initial: '');
  String get journeyId => _journeyId.value;

  updateSelectedJourney(
      {DeliveryJourney deliveryJourney, JourneyState journeyState}) async {
    if (_journeyState == JourneyState.idle) {
      _currentJourney.value = DeliveryJourney();
      return true;
    } else {
      var result = await init(deliveryJourney.journeyId);
      return result;
    }
  }

  RxValue<JourneyState> _journeyState =
      RxValue<JourneyState>(initial: JourneyState.idle);
  JourneyState get journeyState => _journeyState.value;

  bool cancelSelection() {
    _currentJourney.value = DeliveryJourney();
    _journeyState.value = JourneyState.idle;
    return true;
  }

  fetchLocationStats() async {
    var result = await _api.fetchLocationDataByJourneyId(
        token: _user.token, journeyId: 'JN-22-000062');
    // print(result);
    // print(result.toString());
    return;
  }

  receivedReturns(String orderId, String stopId, String deliveryLocation,
      {DeliveryNote deliveryNote}) async {
    return await _api.receivedReturns(
        token: _user.token, deliveryNoteID: deliveryNote.deliveryNoteId);
  }
}
