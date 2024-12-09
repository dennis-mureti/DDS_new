import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/journey_service.dart';
import 'package:distributor/services/location_repository.dart';
import 'package:distributor/services/user_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

/// This class extends the [FutureViewModel] to enable it to fetch the [SalesOrder] corresponding to the sa
class StopListTileViewModel extends BaseViewModel {
  ApiService _apiService = locator<ApiService>();
  NavigationService _navigationService = locator<NavigationService>();
  DialogService _dialogService = locator<DialogService>();
  final _locationService = locator<LocationRepository>();
  JourneyService _journeyService = locator<JourneyService>();
  Api get _api => _apiService.api;
  UserService _userService = locator<UserService>();
  User get _user => _userService.user;
  final String _salesOrderId;
  final DeliveryStop deliveryStop;

  List<DeliveryStop> _deliveryStopList;
  // List<DeliveryStop> get deliveryStop => _deliveryStopList;

  SalesOrder _salesOrder;
  SalesOrder get salesOrder => _salesOrder;

  StopListTileViewModel(this._journeyId,
      {String salesOrderId, DeliveryStop deliveryStop})
      : _salesOrderId = salesOrderId,
        deliveryStop = deliveryStop,
        assert(salesOrderId != null, deliveryStop != null);

  final String _journeyId;

  bool _enableStopControl = false;
  bool get enableStopControl {
    if (_journeyService.currentJourney != null &&
        _journeyService.currentJourney.journeyId == _journeyId) {
      _enableStopControl = true;
    }
    return _enableStopControl;
  }

  Future fetchSalesOrder() async {
    setBusy(true);
    var result = await _api.getSalesOrderDetail(
        token: _user.token, salesOrderId: _salesOrderId);
    setBusy(false);
    if (result is SalesOrder) {
      _salesOrder = result;
      notifyListeners();
      return result;
    } else {
      _dialogService.showDialog(
          title: 'Could not get Sales Order', description: result);
    }
  }

  bool isComplete(SalesOrder salesOrder) {
    if (salesOrder.orderStatus.toLowerCase() == 'complete') {
      return true;
    } else {
      return false;
    }
  }

  List<Placemark> _placemarkList;
  List<Placemark> get placemarkList => _placemarkList;

  getAddress(double latitude, double longitude) async {
    List<Placemark> p =
        await _locationService.placemarkFromCoordinates(latitude, longitude);
    return p;
  }

  /// When a user taps the corresponding listitem they will be redirected to the order detail view
  Future navigateToDeliveryDetailView(
      DeliveryJourney deliveryJourney, DeliveryStop deliveryStop) async {
    await _navigationService.navigateTo(Routes.deliveryNoteView,
        arguments: DeliveryNoteViewArguments(
            deliveryJourney: deliveryJourney, deliveryStop: deliveryStop));

    await getDeliveryNote();
    notifyListeners();
    return;
  }

  DeliveryNote _deliveryNote;
  DeliveryNote get deliveryNote => _deliveryNote;

  Future getDeliveryNote() async {
    setBusy(true);
    var result = await _apiService.api.getDeliveryNoteDetails(
        deliveryNoteId: deliveryStop.deliveryNoteId, token: _user.token);
    setBusy(false);
    if (result is DeliveryNote) {
      _deliveryNote = result;
      notifyListeners();
      return result;
    }
  }

  init() async {
    await getDeliveryNote();
  }
}
