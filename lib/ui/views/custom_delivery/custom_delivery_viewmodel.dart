import 'package:distributor/app/locator.dart';
import 'package:distributor/services/journey_service.dart';
import 'package:distributor/services/location_repository.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/src/ui/views/print_view/print_view.dart';
import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class CustomDeliveryViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _journeyService = locator<JourneyService>();
  final _locationService = locator<LocationRepository>();
  final _userService = locator<UserService>();

  final DeliveryNote deliveryNote;
  final DeliveryStop deliveryStop;
  final Customer customer;

  List<Product> _items;
  List<Product> get items => _items;

  List _orderedItems;
  List get orderedItems => _orderedItems;

  CustomDeliveryViewModel({
    @required this.deliveryNote,
    @required this.deliveryStop,
    @required this.customer,
  })  : _items = deliveryNote.deliveryItems
            .map((e) => Product(
                  id: e['id'],
                  itemFactor: e['itemFactor'],
                  itemName: e['itemName'],
                  itemCode: e['itemCode'],
                  quantity: e['quantity'],
                ))
            .toList(),
        _orderedItems = deliveryNote.deliveryItems;

  commit() async {
    setBusy(true);
    var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Confirm Delivery',
        description: 'Are you sure you want to deliver the items ? ');
    if (dialogResponse.confirmed) {
      var payload = {
        "atStopId": "${deliveryStop.stopId}",
        "deliveryDateTime":
            "${DateTime.now().add(Duration(hours: 3)).toUtc().toIso8601String()}",
        "deliveryLocation": "${deliveryLocation}",
        "deliveryWarehouse": "",
        "items": items
            .map((e) => {
                  "item": {
                    "id": "${e.id}",
                    "itemCode": "${e.itemCode}",
                    "itemFactor": "${e.itemFactor}",
                    "itemName": "${e.itemName}",
                    "itemPrice": e.itemPrice ?? 0,
                    "itemType": "",
                    "priceList": ""
                  },
                  "quantity": e.quantity
                })
            .toList(),
        "onJourneyId": "${deliveryStop.journeyId}",
        "remarks": "",
        "salesOrderId": "${deliveryStop.orderId}"
      };
      var result = await _journeyService.makeCustomDelivery(data: payload);
      setBusy(false);
      if (result is String) {
        await _dialogService.showDialog(
            title: 'Make Delivery Error', description: result.toString());
        _navigationService.back(result: false);
      } else {
        await _dialogService.showDialog(
            title: '', description: 'Delivery updated successfully.');

        _navigationService.back(result: true);
      }
    }
  }

  // Get the quantity of each element
  getQuantity(String productName) {
    var result = _items.firstWhere(
      (element) => element.itemName.toLowerCase() == productName.toLowerCase(),
    );
    return result.quantity;
  }

  void reduce(var deliveryItem, {var value = 1}) {
    var item = _items.firstWhere(
        (element) =>
            element.itemName.toLowerCase() ==
            deliveryItem['itemName'].toString().toLowerCase(),
        orElse: () => deliveryItem);
    if (item.quantity != 0) {
      item.updateQuantity(item.quantity - value);
      notifyListeners();
    }
  }

  getMaxQuantity(var deliveryItem) {
    return deliveryItem['orderedQty'];
  }

  getMinQuantity(var deliveryItem) {
    return 0;
  }

  void add(var deliveryItem, {var value = 1}) {
    var item = _items.firstWhere(
        (element) =>
            element.itemName.toString().toLowerCase() ==
            deliveryItem['itemName'].toString().toLowerCase(),
        orElse: () => deliveryItem);
    // Check if the quantity is not higher then the value ordered
    var newVal = item.quantity + value;
    if (item.quantity <= deliveryItem['orderedQty'] &&
        newVal <= deliveryItem['orderedQty']) {
      item.updateQuantity(newVal);
      notifyListeners();
    }
    notifyListeners();
  }

  updateQuantity({@required var deliveryItem, @required int newVal}) {
    var item = _items.firstWhere(
        (element) =>
            element.itemName.toString().toLowerCase() ==
            deliveryItem['itemName'].toString().toLowerCase(),
        orElse: () => deliveryItem);
    item.updateQuantity(newVal);
    notifyListeners();
  }

  String _deliveryLocation;
  String get deliveryLocation => _deliveryLocation;

  getCurrentLocation() async {
    setBusy(true);
    var result = await _locationService.getLocation();
    setBusy(false);
    if (result != null) {
      _deliveryLocation = "${result.latitude},${result.longitude}";
      notifyListeners();
      return;
    } else {
      _deliveryLocation = "";
      notifyListeners();
      return;
    }
  }

  init() async {
    // await getCurrentLocation();
  }
}
