import 'dart:convert';

import 'package:distributor/app/locator.dart';
import 'package:distributor/services/journey_service.dart';
import 'package:distributor/services/location_repository.dart';
import 'package:distributor/services/stock_controller_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class PartialDeliveryViewModel extends BaseViewModel {
  NavigationService _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _snackbarService = locator<SnackbarService>();
  JourneyService _journeyService = locator<JourneyService>();
  UserService _userService = locator<UserService>();
  final _stockControllerService = locator<StockControllerService>();
  String get token => _userService.user.token;

  final _locationService = locator<LocationRepository>();

  SalesOrder _salesOrder;
  final DeliveryJourney deliveryJourney;
  String get stopId => deliveryStop.stopId;
  final DeliveryNote deliveryNote;
  SalesOrder get salesOrder => _salesOrder;

  PartialDeliveryViewModel(SalesOrder salesOrder, this.deliveryJourney,
      this.deliveryNote, this._deliveryStop) {
    _salesOrder = salesOrder;
    _newRequest = deliveryNote.deliveryItems
        .map((e) => SalesOrderRequestItem.fromMap(e))
        .toList();
  }

  UserLocation _userLocation;
  UserLocation get userLocation => _userLocation;

  getUserLocation() async {
    var result = await _locationService.getLocation();
    if (result is UserLocation) {
      _userLocation = result;
      notifyListeners();
    }
  }

  init() async {
    await fetchReasons();
    await getUserLocation();
  }

  List _reasons = [];
  List get reasons => _reasons;

  fetchReasons() async {
    var result = await _stockControllerService.fetchReasons();
    if (result is List) {
      _reasons = result;
      _reason = _reasons.first;
      notifyListeners();
    }
    // print(result);
  }

  String _reason;
  String get reason => _reason;
  updateReason(String val) {
    _reason = val;
    notifyListeners();
  }

  final DeliveryStop _deliveryStop;
  DeliveryStop get deliveryStop => _deliveryStop;

  updateSalesOrderRequestItem(int index, String val) {
    _newRequest[index].quantity = int.parse(val);
    notifyListeners();
  }

  toggleReason(int index, bool value) {}

  fetchReasonState(int index) {}

  getReasonForItem(int index) {
    if (_newRequest[index].reason.isEmpty) {
      return "Select Reason for Return";
    } else {
      return _newRequest[index].reason;
    }
  }

  validateReasons() {
    //Loop through all items

    //Return true

    return false;
  }

  getCurrentValue(int index, String val) {
    if (newRequest[index].reason.toLowerCase() == val.toLowerCase()) {
      return true;
    }
    return false;
  }

  List<SalesOrderRequestItem> _newRequest;
  List<SalesOrderRequestItem> get newRequest => _newRequest;

  int _quantityToDeliver;
  int get quantityToDeliver => _quantityToDeliver;

  String _remarks = "";
  String get remarks => _remarks;

  fetchReasonsBySKU(itemCode) {
    List _salesOrderReturnItem = [];
    List _initialList = [];
    if (salesOrderReturns.isNotEmpty) {
      // Loop through the list
      for (var salesOrderReturn in salesOrderReturns) {
        var result = salesOrderReturn;
        var _code = result['item']['itemCode'];
        if (_code == itemCode) {
          Map<String, dynamic> soi = {
            "quantity": result['quantity'],
            "reason": result['reason'],
          };
          _salesOrderReturnItem.add(soi);
        }
        // print(_code);
      }

      return _salesOrderReturnItem;
    }
    return _salesOrderReturnItem;
  }

  makeSalesReturns() async {
    setBusy(true);

    Map<String, dynamic> data = {
      "deliveryNoteId": deliveryStop.deliveryNoteId,
      "atStopId": stopId,
      "deliveryDateTime": DateTime.now().toUtc().toIso8601String(),
      "deliveryLocation":
          "lat:${userLocation.latitude.toString()},lng:${userLocation.longitude.toString()}",
      "deliveryWarehouse": deliveryJourney.route,
      "items": salesOrderReturns.map((e) {
        return {
          "item": {
            "id": e['item']['itemCode'],
            "itemCode": e['item']['itemCode'],
            "itemName": e['item']['itemName'],
            "itemPrice": e['item']['itemRate'],
          },
          "quantity": e['quantity'],
          "reason": e['reason']
        };
      }).toList(),
      "onJourneyId": deliveryJourney.journeyId,
      "remarks": remarks,
      "salesOrderId": deliveryStop.orderId
    };
    // print(salesOrderReturns.first.toString());
    print(json.encode(data));
    var result = await _journeyService.makeSalesReturns(
        journeyId: deliveryJourney.journeyId, data: data);
    setBusy(false);

    _navigationService.back(result: result);
    if (result is CustomException) {
      print(result.title);
      await _dialogService.showDialog(
          title: result.title, description: result.description);
    } else {
      _snackbarService.showSnackbar(
          message: 'The delivery was completed successfully');
      _navigationService.back(result: true);
    }
  }

  // Update the reason for item
  setReason(String itemId, String reason) {
    notifyListeners();
  }

  // List of reasons by salesorderitem
  /// SalesOrderItem
  ///
  List _salesOrderReturns = [];
  List get salesOrderReturns => _salesOrderReturns;

  void updateSalesReturnUnits(List result, var itemCode) {
    //Check if list is empty
    if (_salesOrderReturns.isEmpty) {
      _salesOrderReturns.addAll(result);
    } else {
      // Loop through the items
      _salesOrderReturns.removeWhere((element) {
        return element['item']['itemCode'].toString() == itemCode.toString();
      });

      _salesOrderReturns.addAll(result);
    }
    // print(result);

    // if (salesOrderReturns.isEmpty) {
    //   _salesOrderReturns.add(result);
    // } else {
    //   //Check if the index exists
    //   if (salesOrderReturns.asMap().containsKey(index)) {
    //     _salesOrderReturns[index] = result;
    //     print('$index exists');
    //     _salesOrderReturns.add(result);
    //   } else {
    //     //Add the value to the index
    //     _salesOrderReturns.add(result);
    //   }
    // }
    // fetchReasonsBySKU(result);
    notifyListeners();
  }
}

class SalesReturn {
  final String reason;
  final int quantity;
  SalesOrderRequestItem saleRequestItem;

  SalesReturn(this.reason, this.quantity, {this.saleRequestItem});

  @override
  String toString() {
    print(
        "reason is $reason  quantity is $quantity and index is $saleRequestItem");
  }
}
