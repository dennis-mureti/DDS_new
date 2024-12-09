import 'dart:async';

import 'package:distributor/app/locator.dart';
import 'package:distributor/core/models/product_service.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class CheckInViewModel extends BaseViewModel {
  UserService _userService = locator<UserService>();
  ProductService _productService = locator<ProductService>();
  DialogService _dialogService = locator<DialogService>();

  String _selectedSku;
  // List<String> _skuList = ["SKU1", "SKU2", "SKU3"];
  Product selectedProduct;

  String visitId;

  bool isCheckedIn = false;
  DateTime checkInTime;
  String duration = '00hrs 00min 00sec';
  Timer _timer;

  Color buttonColor = Colors.green;

  String get selectedSku => _selectedSku;
  // List<String> get skuList => _skuList;

  String _shelfAvailability;
  String get shelfAvailability => _shelfAvailability;

  String _shareOfShelf;
  String get shareOfShelf => _shareOfShelf;

  String _skuVolume;
  String get skuVolume => _skuVolume;

  String _competitorInfo;
  String get competitorInfo => _competitorInfo;

  String _activations;
  String get activations => _activations;

  String _priceCompliance;
  String get priceCompliance => _priceCompliance;

  String _retailPrice;
  String get retailPrice => _retailPrice;

  String _brandAvailability;
  String get brandAvailability => _brandAvailability;

  String _marketingRequest;
  String get marketingRequest => _marketingRequest;

  String _brandingRequest;
  String get brandingRequest => _brandingRequest;

  String _generalFeedback;
  String get generalFeedback => _generalFeedback;

  ApiService _apiService = locator<ApiService>();
  Api get _api => _apiService.api;
  User get user => _userService.user;

  List<Product> _productList = [];
  List<Product> get productList => _productList;

  Future<List<Product>> fetchProducts() async {
    try {
      var result = await _productService.listAllItems();
      _productList = result ?? [];
      notifyListeners();
      return _productList;
    } catch (e) {
      debugPrint("Error fetching products: ${e}");
      await _dialogService.showDialog(
        title: "Error",
        description: "Failed to fetch products. Please try again.",
      );
      return [];
    }
  }

  List<Product> get listOfProducts {
    return productList;
  }

  // Future<void> createVisitData(BuildContext context, String visitId) async {
  //   try {
  //     // var payload = {
  //     //   "performedVisit": 9,
  //     //   "sku": int.parse(selectedProduct.id),
  //     //   "shelfAvailability": "Yes",
  //     //   "shareOfShelf": "70%",
  //     //   "skuVolume": "max",
  //     //   "skuWeight": "1.5Kg",
  //     //   "competitorInfo": "No Info",
  //     //   "activations": "Yes, three umbrellas",
  //     //   "priceCompliance": "No",
  //     //   "retailPrice": "Ksh 176",
  //     //   "brandAvailability": "Yes",
  //     //   "marketingRequest": "Yes",
  //     //   "brandingRequest": "Yes",
  //     //   "generalFeedback": "The customers are happy",
  //     //   "shelfPhotoUrl": "/volume/photos/shelf/shelf.png",
  //     //   "createdBy": user.full_name
  //     // };

  //     var payload = {
  //       "performedVisit": visitId,
  //       "sku": 1,
  //       "shelfAvailability": "Yes",
  //       "shareOfShelf": "60%",
  //       "skuVolume": "test",
  //       "skuWeight": "100g",
  //       "competitorInfo": "test",
  //       "activations": "Yes, three umbrellas",
  //       "priceCompliance": "Yes",
  //       "retailPrice": "N/A",
  //       "brandAvailability": "Yes"
  //     };

  //     var dialogResponse = await _dialogService.showConfirmationDialog(
  //       title: 'Checkin Data',
  //       description: 'Are you sure you want to suubmt checklist?',
  //       cancelTitle: 'No',
  //       confirmationTitle: 'Yes',
  //     );

  //     if (dialogResponse.confirmed) {
  //       setBusy(true);

  //       var response = await _api.createVisitData(user.token, payload);

  //       // Check if the response is a map before accessing keys
  //       if (response is bool && response) {
  //         await _dialogService.showDialog(
  //           title: 'Success',
  //           description: 'Check-List successfully started.',
  //         );
  //       } else if (response is Map<String, dynamic>) {
  //         // Handle as a map if necessary
  //         var errorMessage = response['payload'] ?? response['errorMessage'];
  //         await _dialogService.showDialog(
  //           title: 'Checklst Failed',
  //           description:
  //               'There was an issue submitting checklist In.\n$errorMessage',
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     await _dialogService.showDialog(
  //       title: 'Error',
  //       description: 'An unexpected error occurred: ${e.toString()}',
  //     );
  //   } finally {
  //     setBusy(false); // Ensure loading spinner is hidden
  //   }
  // }

  Future<void> createVisitData(BuildContext context, String visitId) async {
    try {
      var payload = {
        "performedVisit": visitId,
        "sku": 1,
        "shelfAvailability": "Yes",
        "shareOfShelf": "60%",
        "skuVolume": "test",
        "skuWeight": "100g",
        "competitorInfo": "test",
        "activations": "Yes, three umbrellas",
        "priceCompliance": "Yes",
        "retailPrice": "N/A",
        "brandAvailability": "Yes"
      };

      var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Checkin Data',
        description: 'Are you sure you want to submit checklist?',
        cancelTitle: 'No',
        confirmationTitle: 'Yes',
      );

      if (dialogResponse.confirmed) {
        setBusy(true);

        var response = await _api.createVisitData(user.token, payload);

        // Check if the response is a Map and if it contains the 'httpCode'
        if (response is Map<String, dynamic>) {
          int httpCode = response['httpCode'] ?? 0;
          var errorMessage = response['payload'] ?? response['errorMessage'];
          var message = response['message'] ?? 'An unexpected error occurred.';

          if (httpCode == 201) {
            // Success case for HTTP status 201
            await _dialogService.showDialog(
              title: 'Success',
              description: 'Checklist successfully submitted.',
            );
          } else {
            // Error case for other HTTP status codes
            await _dialogService.showDialog(
              title: 'Error',
              description:
                  'Submission failed.\nError Code: $httpCode\nError Message: $message\nDetails: $errorMessage',
            );
          }
        } else {
          // Handle unexpected response format
          await _dialogService.showDialog(
            title: 'Error',
            description: 'An unexpected error occurred. Please try again.',
            // title: 'Success',
            // description: 'Checklist submitted successfully.',
          );
        }
      }
    } catch (e) {
      // Show a general error dialog if an unexpected error occurs
      await _dialogService.showDialog(
        title: 'Error',
        description: 'An unexpected error occurred: ${e.toString()}',
        // title: 'Success',
        // description: 'Checklist submitted successfully.',
      );
    } finally {
      setBusy(false); // Ensure loading spinner is hidden
    }
  }

  void setSelectedSku(Product product) {
    selectedProduct = product;
    notifyListeners();
  }

  void setShelfAvailability(String value) {
    _shelfAvailability = value;
    notifyListeners();
  }

  void setShareOfShelf(String value) {
    _shareOfShelf = value;
    notifyListeners();
  }

  void setSkuVolume(String volume) {
    _skuVolume = volume;
    notifyListeners();
  }

  void setCompetitorInfo(String info) {
    _competitorInfo = info;
    notifyListeners();
  }

  void setActivations(String value) {
    _activations = value;
    notifyListeners();
  }

  void setPriceCompliance(String value) {
    _priceCompliance = value;
    notifyListeners();
  }

  void setRetailPrice(String value) {
    _retailPrice = value;
    notifyListeners();
  }

  void setBrandAvailability(String value) {
    _brandAvailability = value;
    notifyListeners();
  }

  void setMarketingRequest(String value) {
    _marketingRequest = value;
    notifyListeners();
  }

  void setBrandingRequest(String value) {
    _brandingRequest = value;
    notifyListeners();
  }

  void setGeneralFeedback(String feedback) {
    _generalFeedback = feedback;
    notifyListeners();
  }

  void uploadPhoto() {
    // Implement your photo upload logic here
  }

  // void toggleCheckin() {
  //   isCheckedIn = !isCheckedIn;
  //   notifyListeners();

  //   if (isCheckedIn) {
  //     // User checks in
  //     checkInTime = DateTime.now();
  //     _startTimer();
  //   } else {
  //     // User checks out
  //     _stopTimer();
  //     if (checkInTime != null) {
  //       final timeDiff = DateTime.now().difference(checkInTime);
  //       duration = _formatDuration(timeDiff);
  //     }
  //     checkInTime = null; // Reset check-in time
  //   }

  //   notifyListeners(); // Refresh UI
  // }

  void toggleCheckin() {
    isCheckedIn = !isCheckedIn;
    buttonColor =
        isCheckedIn ? Colors.red : Colors.green; // Change button color
    notifyListeners();

    if (isCheckedIn) {
      // User checks in
      checkInTime = DateTime.now();
      _startTimer();
    } else {
      // User checks out
      _stopTimer();
      if (checkInTime != null) {
        final timeDiff = DateTime.now().difference(checkInTime);
        duration = _formatDuration(timeDiff);
      }
      checkInTime = null; // Reset check-in time
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (checkInTime != null && isCheckedIn) {
        final timeDiff = DateTime.now().difference(checkInTime);
        duration = _formatDuration(timeDiff);
        notifyListeners(); // Update UI with new duration
      }
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}hrs '
        '${minutes.toString().padLeft(2, '0')}min '
        '${seconds.toString().padLeft(2, '0')}sec';
  }

  // Stop the timer when checking out
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // void submitCheckIn(BuildContext context) {
  //   // Added context parameter
  //   createVisitData(context); // Removed the semicolon after context
  //   // Implement your submission logic here
  // }

  Future<void> submitCheckIn(BuildContext context) async {
    toggleCheckin();
    if (isCheckedIn) {
      await createVisitData(
        context,
        visitId,
      );
    }
  }

  Future<List<Product>> futureToRun() => fetchProducts();
}
