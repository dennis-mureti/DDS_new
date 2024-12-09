import 'package:distributor/app/locator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class QuantityInputViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final int _initialQuantity;

  int get initialQuantity => _initialQuantity;

  int _quantity;
  int get quantity => _quantity ?? 0;

  bool _displayError = false;
  bool get displayError => _displayError;
  String errorMsg = "";

  updateDisplayError(bool displayError, String msg) {
    _displayError = displayError;
    if (displayError) {
      errorMsg = msg;
    } else {
      errorMsg = "";
    }
    notifyListeners();
  }

  updateQuantity(String val) {
    var input = validateInput(val);
    if (input == null) return;
    _setMaxQuantityStatus(quantity);
    _setMinQuantityStatus(quantity);
    _reset(quantity);
    notifyListeners();
  }

  validateInput(String val) {
    var result = int.tryParse(val);
    if (result == null) {
      _displayError = true;
      errorMsg = "Invalid input. Allowed range is $minQuantity to $maxQuantity";
      notifyListeners();
    } else {
      _quantity = result;
      _displayError = false;
      errorMsg = "";
    }
    return result;
  }

  QuantityInputViewModel(
      {int initialQuantity = 0, int maxQuantity, int minQuantity})
      : _initialQuantity = initialQuantity,
        _quantity = initialQuantity,
        maxQuantity = maxQuantity,
        minQuantity = minQuantity;

  final int maxQuantity;
  final int minQuantity;

  submit() async {
    _setMaxQuantityStatus(quantity);
    _setMinQuantityStatus(quantity);
    if (quantity <= maxQuantity && quantity >= minQuantity) {
      _navigationService.back(result: quantity);
    }
  }

  _setMaxQuantityStatus(var val) {
    if (val > maxQuantity) {
      updateDisplayError(true,
          "Quantity entered is greater than maximum quantity allowed : $maxQuantity.");
    }
  }

  _setMinQuantityStatus(var val) {
    if (val < minQuantity) {
      updateDisplayError(true,
          "Quantity entered is less than minimum quantity allowed : $minQuantity.");
    }
  }

  _reset(var val) {
    if (val <= maxQuantity && val >= minQuantity) {
      errorMsg = "";
      updateDisplayError(false, "");
    }
  }

  cancel() async {
    _navigationService.back(result: initialQuantity);
  }

  void resetQuantity() {
    _quantity = initialQuantity;
    _displayError = false;
    errorMsg = "";
    notifyListeners();
  }
}
