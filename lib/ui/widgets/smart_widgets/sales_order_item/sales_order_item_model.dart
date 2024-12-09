import 'package:distributor/app/locator.dart';
import 'package:distributor/services/init_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class SalesOrderItemModel extends BaseViewModel {
  NavigationService _navigationService = locator<NavigationService>();
  final _initService = locator<InitService>();
  final Product product;
//  SalesOrderItem salesOrderItem;
  double _total = 0.00;
  double get total => _total;

  num _quantity = 0;
  num get quantity => _quantity;

  num _maxQuantity;
  num get maxQuantity => _maxQuantity;
  SalesOrderItemModel({@required this.product, num maxQuantity})
      : assert(product != null),
        _maxQuantity = maxQuantity;

  bool get isEnabled => product.itemPrice > 0;

  String get currency =>
      _initService.appEnv.flavorValues.applicationParameter.currency;

  /// If the item has a price enable the add item quantity
  addItemQuantity({int val}) {
    if (isEnabled) {
      if (maxQuantity == null) {
        if (val != null) {
          _quantity = val;
        } else {
          _quantity++;
        }
        setItemTotal();
        notifyListeners();
      } else if (quantity < maxQuantity) {
        if (val != null) {
          if (quantity + 1 < maxQuantity) {
            _quantity = quantity + val;
          } else {
            _quantity = maxQuantity.toInt();
          }
        } else {
          _quantity++;
        }
        setItemTotal();
        notifyListeners();
      }
    } else {
      null;
    }
  }

  /// If [isEnabled] set the total price for this item
  setItemTotal() {
    if (isEnabled) {
      var result = product.itemPrice * quantity;
      _total = result.roundToDouble();
      notifyListeners();
    }
  }

  /// If [isEnabled] remove [quantity] of 1 unit from the total quantity
  /// If the [quantity] is equal to zero. Disable
  removeItemQuantity({int val}) {
    if (_quantity > 0 && isEnabled) {
      if (val != null) {
        _quantity = val;
      } else {
        _quantity--;
      }
      setItemTotal();
      notifyListeners();
    }
  }

  /// For large quantities, the bottom modal sheet is used for data input
  /// If [isEnabled] allow the user to add the number of units required
  void updateQuantity(String value, Product product) {
    if (isEnabled) {
      int quantity = int.tryParse(value);
      _quantity = quantity;
      var result = product.itemPrice * _quantity;
      _total = result.roundToDouble();
      setItemTotal();
      notifyListeners();
    }
  }

  getDifference(double initial, double newVal) {
    return initial - newVal;
  }

  setQuantity(String val) {
    if (val.isNotEmpty) {
      var newVal = int.parse(val);
      _navigationService.back(result: newVal);
    }
  }

  processManualInput(int val) {
    //Set the quantity
    _quantity = val;
    setItemTotal();
    notifyListeners();
  }
}
