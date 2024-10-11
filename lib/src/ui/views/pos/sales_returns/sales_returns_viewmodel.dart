import 'package:distributor/app/locator.dart';
import 'package:distributor/services/stock_controller_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SalesReturnsViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _stockControllerService = locator<StockControllerService>();

  final invoice;
  SalesReturnsViewModel(this.invoice);

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

  init() async {
    await fetchReasons();
  }

  fetchReasons() async {
    var result = await _stockControllerService.fetchReasons();
    if (result is List) {
      _reasons = result;
      _reason = _reasons.first;
      notifyListeners();
    }
    print(result);
  }

  String _reason;
  String get reason => _reason;
  updateReason(String val) {
    _reason = val;
    notifyListeners();
  }

  List _reasons = [];
  List get reasons => _reasons;
  makeSalesReturns() async {
    setBusy(true);

    Map<String, dynamic> data = {
      "deliveryNoteId": invoice['deliveryNoteId'],
      // "atStopId": "stopId",
      // "deliveryDateTime": DateTime.now().toUtc().toIso8601String(),
      // "deliveryLocation": "",
      "deliveryWarehouse": "",
      "items": salesOrderReturns.map((e) {
        return {
          "item": {
            // "id": e['item']['itemCode'],
            "itemCode": e['item']['itemCode'],
            "itemName": e['item']['itemName'],
            "itemPrice": e['item']['itemPrice'],
          },
          "quantity": e['quantity'],
          "reason": e['reason']
        };
      }).toList(),
      // "onJourneyId": "",
      "remarks": "",
      // "salesOrderId": invoice['deliveryNoteId']
    };
    // print(salesOrderReturns.first.toString());
    var result = await _stockControllerService.makeOutletSalesReturns(data);
    setBusy(false);
    if (result) {
      await _dialogService.showDialog(
          title: 'Success', description: 'Sales Return was successful.');
      _navigationService.back();
    } else {
      await _dialogService.showDialog(
          title: 'Sales Return error',
          description: 'The sales return was not successful.');
    }
  }

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
}
