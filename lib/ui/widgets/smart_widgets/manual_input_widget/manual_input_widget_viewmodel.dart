import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class ManualInputWidgetViewModel extends BaseViewModel {
  final int _initialQuantity;
  int _finalQuantity;
  final int _maxQuantity;
  final bool _isAdhocSale;
  final Product product;
  bool _inputWithinRange = true;
  bool _isValidInput = true;
  TextEditingController _textEditingController;

  TextEditingController get textEditingController => _textEditingController;
  int get initialQuantity => _initialQuantity;
  int get maxQuantity => _maxQuantity;
  int get finalQuantity => _finalQuantity ?? initialQuantity;
  bool get isAdhocSale => _isAdhocSale;
  bool get inputWithinRange => _inputWithinRange;
  bool get isValidInput => _isValidInput;

  init() async {
    //Add a listener for the text editing controller
    // _textEditingController.addListener(() {
    //   validateInput(textEditingController.text);
    // });
  }

  ManualInputWidgetViewModel(
      {@required int initialQuantity,
      @required this.product,
      bool isAdhocSale,
      num maxQuantity})
      : _isAdhocSale = isAdhocSale ?? false,
        _initialQuantity = initialQuantity,
        _maxQuantity = maxQuantity != null ? maxQuantity.toInt() : null,
        assert(product != null);

  setInputWithinRange(bool value) {
    _inputWithinRange = value;
    notifyListeners();
  }

  setIsValidInput(bool val) {
    _isValidInput = val;
    notifyListeners();
  }

  //Reset the values
  reset() {}

  //Validate the input
  validateInput(String val) {
    if (val.isNotEmpty) {
      // The length is fine
      // Validate the input
      setIsValidInput(true);
      // Check if the input is valid characters
      var input = checkInputValid(val);
      // Check if the value is within the allowed range
      if (input != null) {
        checkInputWithinRange(input);
      }
    } else {
      // The input length is not valid
      setIsValidInput(false);
      setValidationError("The quantity cannot be empty");
    }
  }

  String _validationError;
  String get validationError => _validationError;
  setValidationError(String val) {
    _validationError = val;
    notifyListeners();
  }

  //Check if the input within the range
  checkInputWithinRange(int val) {
    if (maxQuantity != null) {
      if (!val.isBetween(0, maxQuantity)) {
        setValidationError(
            "Quantity out of range. Maximum quantity is $maxQuantity");
        setIsValidInput(false);
      } else {
        setIsValidInput(true);
        setFinalQuantity(val);
      }
    } else {
      // This is a sales order
      // Set the final quantity to the value
      setFinalQuantity(val);
    }
  }

  checkInputValid(String val) {
    //Try and parse the input into a number
    var input = int.tryParse(val);
    if (input == null) {
      // This is not a valid quantity
      setIsValidInput(false);
      setValidationError("The input quantity is not valid");
      return null;
    } else {
      return input;
    }
  }

  setFinalQuantity(int val) {
    _finalQuantity = val;
    notifyListeners();
  }
}

//Extension to check values within range
extension Range on num {
  bool isBetween(num from, num to) {
    return from <= this && this <= to;
  }
}
