import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:distributor/app/locator.dart';
import 'package:distributor/core/helper.dart';
import 'package:distributor/core/models/product_service.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/ui/views/crm/visits/details/details_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckInViewModel extends BaseViewModel {
  UserService _userService = locator<UserService>();
  ProductService _productService = locator<ProductService>();
  DialogService _dialogService = locator<DialogService>();

  String _selectedSku;

  String visitId;

  String gtSelectedProduct;

  String shelfPhotoUrlfinal;

  bool isCheckedIn = false;
  DateTime checkInTime;
  String duration = '00hrs 00min 00sec';
  Timer _timer;
  DateTime earlierCheckInTime;

  Color buttonColor = Colors.green;

  bool productSelected = false;

  List<Product> selectedProducts = [];
  Product selectedProduct;

  String get selectedSku => _selectedSku;
  // List<String> get skuList => _skuList;
  List<Map<String, dynamic>> gtproductList = [];

  String selectedProductName;

  // String _shelfAvailability;
  // String _shareOfShelf;
  // String _skuVolume;
  // String _competitorInfo;
  // String _activations;
  // String _priceCompliance;
  // String _retailPrice;
  // String _brandAvailability;
  // String _marketingRequest;
  // String _brandingRequest;
  // String _generalFeedback;

  Map<String, String> _shelfAvailabilityMap = {};
  Map<String, String> _priceComplianceMap = {};
  Map<String, double> _retailPriceMap = {};

  String getShelfAvailability(String productId) =>
      _shelfAvailabilityMap[productId] ?? '';
  String getPriceCompliance(String productId) =>
      _priceComplianceMap[productId] ?? '';
  double getRetailPrice(String productId) => _retailPriceMap[productId] ?? 0.0;

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

  File _shelfPhotoUrl;
  File get shelfPhotoUrl => _shelfPhotoUrl;

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

  Future<void> setCheckInTime(DateTime time) async {
    checkInTime = time;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('checkInTime', time.toIso8601String());
  }

  Future<DateTime> getCheckInTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String timeString = prefs.getString('checkInTime');
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  Future<void> captureShelfPhoto() async {
    final ImagePicker _picker = ImagePicker();
    final PickedFile photo = await _picker.getImage(source: ImageSource.camera);
    if (photo != null) {
      _shelfPhotoUrl = File(photo.path);
      notifyListeners();
    }
  }

  List<String> selectedBrands = [];
  // bool isCheckedIn = true;

  void addBrand(String brand) {
    if (!selectedBrands.contains(brand)) {
      selectedBrands.add(brand);
    }
  }

  void removeBrand(String brand) {
    selectedBrands.remove(brand);
  }

  // Method to set selected product name
  void setSelectedProductName(String name) {
    selectedProductName = name;
  }

  void fetchProduct() {
    if (selectedProducts.isNotEmpty) {
      selectedProduct = selectedProducts.first;
      notifyListeners();
    }
  }

  updateShelfPhotoUrl(File newFile) {
    _shelfPhotoUrl = newFile;
    notifyListeners();
  }

  // Function to upload image to Firebase Storage
  uploadImage() async {
    if (_shelfPhotoUrl == null) {
      return;
    }
    try {
      await Firebase.initializeApp();
      // await FirebaseAuth.instance.signInAnonymously();
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final fileRef = storageRef.child('images/$fileName.jpg');
      await fileRef.putFile(_shelfPhotoUrl);
      String mainurlmain = await fileRef.getDownloadURL();
      shelfPhotoUrlfinal = mainurlmain;
      // rebuildUi();
      notifyListeners();
      return shelfPhotoUrlfinal;
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Error uploading image: $e")),
      // );
      print("data here------ error --- $e ");
    }
  }

  List<Product> get listOfProducts {
    return productList;
  }

  List<Product> addedProducts = [];

  void setShelfAvailabilityForProductById(
      String productId, String availability) {
    _shelfAvailabilityMap[productId] = availability;
    notifyListeners();
  }

  void setPriceComplianceForProductById(String productId, String compliance) {
    _priceComplianceMap[productId] = compliance;
    notifyListeners();
  }

  void setRetailPriceForProductById(String productId, double price) {
    _retailPriceMap[productId] = price;
    notifyListeners();
  }

  void updateShelfAvailability(Product product, String availability) {
    if (availability != null) {
      // product.shelfAvailability = availability;
      notifyListeners();
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

  void setSelectedProduct(String value) {
    gtSelectedProduct = value;
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

  void saveProductSelection() {
    productSelected = true;
    notifyListeners();
  }

  // Add selected product to addedProducts list
  void addProductToList() {
    if (selectedProduct != null) {
      // addedProducts.add(selectedProduct);
      selectedProducts.add(selectedProduct);
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  // Remove product from addedProducts list
  void removeProductFromList(Product product) {
    // addedProducts.remove(product);
    selectedProducts.remove(product);
    notifyListeners();
  }

  void updateShelfAvailabilityWithDetails(
      String productId, String sectionId, String availability) {
    // Implement logic for detailed shelf availability updates
    debugPrint(
        'Shelf availability updated for product $productId in section $sectionId: $availability');
    notifyListeners();
  }

  void _calculateDuration() {
    if (checkInTime != null) {
      final timeDiff = DateTime.now().difference(checkInTime);
      duration = _formatDuration(timeDiff);
      checkInTime = null;
    }
  }

  List<int> getSelectedProductIds() {
    return selectedProducts.map((product) => product.id).toList();
  }

  // void toggleCheckin(BuildContext context, int visitId) async {
  //   if (!isCheckedIn) {
  //     // Check-In Logic
  //     checkInTime = DateTime.now();
  //     var dialogResponse = await _dialogService.showConfirmationDialog(
  //       title: 'Check In',
  //       description: 'Are you sure you want to check in?',
  //       confirmationTitle: 'Yes',
  //       cancelTitle: 'No',
  //     );

  //     if (dialogResponse.confirmed) {
  //       isCheckedIn = true;
  //       await setCheckedInState(true, checkInTime);
  //       notifyListeners();
  //       _startTimer();
  //       checkInRequest(context, visitId);
  //     }
  //   } else {
  //     // Before Check-Out, call createVisitData (or similar process)
  //     bool checklistResponse = await createVisitData(context, visitId);

  //     if (checklistResponse) {
  //       // Proceed with Check-Out Logic
  //       var dialogResponse = await _dialogService.showDialog(
  //         title: 'Check Out',
  //         description: 'Proceed to checkout',
  //         buttonTitle: 'Ok',
  //         // cancelTitle: 'No',
  //       );

  //       if (dialogResponse.confirmed) {
  //         isCheckedIn = false;
  //         await setCheckedInState(false, null);
  //         _stopTimer();
  //         _calculateDuration();

  //         // Await checkOutProcess before navigating
  //         await checkOutProcess(context, visitId: visitId);

  //         Navigator.pop(context);
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => ScheduleDetailsView(),
  //           ),
  //         );
  //       }
  //     } else {
  //       // If user cancels the checklist submission, do not proceed with checkout
  //       await _dialogService.showDialog(
  //         title: 'Action Cancelled',
  //         description:
  //             'You did not submit the checklist. Check-out process was canceled.',
  //       );
  //     }
  //   }
  // }

  // void toggleCheckin(BuildContext context, int visitId) async {
  //   if (!isCheckedIn) {
  //     // Check-In Logic
  //     checkInTime = DateTime.now();
  //     var dialogResponse = await _dialogService.showConfirmationDialog(
  //       title: 'Check In',
  //       description: 'Are you sure you want to check in?',
  //       confirmationTitle: 'Yes',
  //       cancelTitle: 'No',
  //     );

  //     if (!dialogResponse.confirmed) return;

  //     setBusy(true); // Show loader
  //     bool checkInSuccess = await checkInRequest(context, visitId);
  //     setBusy(false); // Hide loader

  //     if (!checkInSuccess) return;

  //     isCheckedIn = true;
  //     await setCheckedInState(true, checkInTime);
  //     _startTimer();
  //     notifyListeners();
  //   } else {
  //     // Before Check-Out, call createVisitData
  //     bool checklistResponse = await createVisitData(context, visitId);

  //     if (!checklistResponse) {
  //       await _dialogService.showDialog(
  //         title: 'Action Cancelled',
  //         description:
  //             'You did not submit the checklist. Check-out process was canceled.',
  //       );
  //       return;
  //     }

  //     var dialogResponse = await _dialogService.showDialog(
  //       title: 'Check Out',
  //       description: 'Proceed to checkout',
  //       buttonTitle: 'Ok',
  //     );

  //     if (!dialogResponse.confirmed) return;

  //     setBusy(true); // Show loader
  //     bool checkOutSuccess = await checkOutProcess(context, visitId: visitId);
  //     setBusy(false); // Hide loader

  //     if (!checkOutSuccess) return;

  //     isCheckedIn = false;
  //     await setCheckedInState(false, null);
  //     _stopTimer();
  //     _calculateDuration();

  //     notifyListeners();

  //     Navigator.pop(context);
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => ScheduleDetailsView(),
  //       ),
  //     );
  //   }
  // }

  void toggleCheckin(BuildContext context, int visitId) async {
    if (!isCheckedIn) {
      // Check-In Logic
      checkInTime = DateTime.now();
      var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Check In',
        description: 'Are you sure you want to check in?',
        confirmationTitle: 'Yes',
        cancelTitle: 'No',
      );

      if (!dialogResponse.confirmed) return;

      setBusy(true); // Show loader
      bool checkInSuccess = await checkInRequest(context, visitId);
      setBusy(false); // Hide loader

      if (!checkInSuccess) return; // Do not change state if check-in fails

      // Proceed with updating state only on success
      isCheckedIn = true;
      await setCheckedInState(true, checkInTime);
      _startTimer();
      notifyListeners();
    } else {
      // Before Check-Out, call createVisitData
      bool checklistResponse = await createVisitData(context, visitId);

      if (!checklistResponse) {
        await _dialogService.showDialog(
          title: 'Action Cancelled',
          description:
              'You did not submit the checklist. Check-out process was canceled.',
        );
        return;
      }

      var dialogResponse = await _dialogService.showDialog(
        title: 'Check Out',
        description: 'Proceed to checkout',
        buttonTitle: 'Ok',
      );

      if (!dialogResponse.confirmed) return;

      setBusy(true); // Show loader
      bool checkOutSuccess = await checkOutProcess(context, visitId: visitId);
      setBusy(false); // Hide loader

      if (!checkOutSuccess) return; // Do not change state if check-out fails

      // Proceed with updating state only on success
      isCheckedIn = false;
      await setCheckedInState(false, null);
      _stopTimer();
      _calculateDuration();

      notifyListeners();

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScheduleDetailsView(),
        ),
      );
    }
  }

  Future<void> loadCheckInState() async {
    final prefs = await SharedPreferences.getInstance();
    isCheckedIn = prefs.getBool('isCheckedIn') ?? false;
    final checkInTimeString = prefs.getString('checkInTime');
    if (checkInTimeString != null) {
      checkInTime = DateTime.parse(checkInTimeString);
    }
    notifyListeners();
  }

  Future<void> fetchCheckInState() async {
    final prefs = await SharedPreferences.getInstance();
    isCheckedIn = prefs.getBool('isCheckedIn') ?? false;
    notifyListeners();
  }

  Future<void> setCheckedInState(bool checkedIn, DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCheckedIn', checkedIn);
    // await prefs.setInt('checkInTime', time.millisecondsSinceEpoch);
    await prefs.setString('checkInTime', time?.toIso8601String() ?? "");
    isCheckedIn = checkedIn;
    checkInTime = time;
    notifyListeners();
  }

  // Future<void> checkInRequest(BuildContext context, int visitId) async {
  //   try {
  //     var payload = {
  //       "plannedVisitId": visitId,
  //       // "checkInTime": DateTime.now().toIso8601String(),
  //       "checkInTime":
  //           DateTime.now().toUtc().add(Duration(hours: 3)).toIso8601String(),
  //       "lat": -1.26777778,
  //       "lon": 36.90222222
  //     };

  //     // var dialogResponse = await _dialogService.showConfirmationDialog(
  //     //   title: 'Check-in',
  //     //   description: 'Are you sure you want to check in?',
  //     //   cancelTitle: 'No',
  //     //   confirmationTitle: 'Yes',
  //     // );

  //     // if (dialogResponse.confirmed) {
  //     setBusy(true);

  //     var response = await _api.checkIn(user.token, payload);

  //     // if (response is bool && response) {
  //     if (response == 'Check-in ') {
  //       await _dialogService.showDialog(
  //         title: 'Success',
  //         description: 'Checkin successfully started.',
  //       );
  //       isCheckedIn = true;
  //     } else if (response is CustomException) {
  //       // var errorMessage = response['payload'] ?? response['errorMessage'];
  //       await _dialogService.showDialog(
  //         // title: 'Checkin Failed',
  //         // // description: 'There was an issue checking in.\n$errorMessage',
  //         // description:
  //         //     'There was an issue checkin in.\nError: ${response.code}\nDescription: ${response.description}',
  //         title: 'Warning',
  //         description:
  //             'There was an issue checkin in because this check in is in progress.',
  //       );
  //     }
  //     // }
  //   } catch (e) {
  //     await _dialogService.showDialog(
  //       title: 'Error',
  //       description: 'An unexpected error occurred: ${e.toString()}',
  //     );
  //   } finally {
  //     setBusy(false);
  //     notifyListeners();
  //   }
  // }

  Position _currentPosition;
  // Future<void> checkInRequest(BuildContext context, int visitId) async {
  //   final hasPermission = await Helper().handleLocationPermission(context);
  //   if (!hasPermission) return;
  //   await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
  //       .then((Position position) async {
  //     _currentPosition = position;
  //     try {
  //       var payload = {
  //         "plannedVisitId": visitId,
  //         // "checkInTime": DateTime.now().toIso8601String(),
  //         "checkInTime":
  //             DateTime.now().toUtc().add(Duration(hours: 3)).toIso8601String(),
  //         "lat": _currentPosition.latitude.toString(),
  //         "lon": _currentPosition.longitude.toString(),
  //         // "lat": -1.26777778,
  //         // "lon": 36.90222222
  //       };

  //       // var dialogResponse = await _dialogService.showConfirmationDialog(
  //       //   title: 'Check-in',
  //       //   description: 'Are you sure you want to check in?',
  //       //   cancelTitle: 'No',
  //       //   confirmationTitle: 'Yes',
  //       // );

  //       // if (dialogResponse.confirmed) {
  //       setBusy(true);

  //       var response = await _api.checkIn(user.token, payload);

  //       // if (response is bool && response) {
  //       if (response == 'Check-in successful') {
  //         await _dialogService.showDialog(
  //           title: 'Success',
  //           description: 'Checkin successfully started.',
  //         );
  //         isCheckedIn = true;
  //       } else if (response is CustomException) {
  //         // var errorMessage = response['payload'] ?? response['errorMessage'];
  //         await _dialogService.showDialog(
  //           title: 'Checkin Failed ',
  //           // description: 'There was an issue checking in.\n$errorMessage',
  //           description:
  //               'There was an issue checkin in.\nError: ${response.code}\nDescription: ${response.description}',
  //           // title: 'Warning',
  //           // description:
  //           //     'There was an issue checkin in because this check in is in progress.',
  //         );
  //       }
  //       // }
  //     } catch (e) {
  //       await _dialogService.showDialog(
  //         title: 'Error',
  //         description: 'An unexpected error occurred: ${e.toString()}',
  //       );
  //     } finally {
  //       setBusy(false);
  //       notifyListeners();
  //     }
  //   }).catchError((e) {
  //     setBusy(false);
  //     notifyListeners();
  //   });
  // }
  Future<bool> checkInRequest(BuildContext context, int visitId) async {
    final hasPermission = await Helper().handleLocationPermission(context);
    if (!hasPermission) return false;

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Location Error',
        description: 'Failed to get location: ${e.toString()}',
      );
      return false;
    }

    _currentPosition = position;

    var payload = {
      "plannedVisitId": visitId,
      "checkInTime":
          DateTime.now().toUtc().add(Duration(hours: 3)).toIso8601String(),
      "lat": _currentPosition.latitude.toString(),
      "lon": _currentPosition.longitude.toString(),
    };

    setBusy(true);
    try {
      var response = await _api.checkIn(user.token, payload);

      if (response is Map<String, dynamic> &&
          response.containsKey('statusCode')) {
        int statusCode = response['statusCode'];

        if (statusCode < 200 || statusCode >= 300) {
          await _dialogService.showDialog(
            title: 'Check-in Failed',
            description:
                'The server rejected the check-in request. Error: ${response['message'] ?? 'Unknown Error'}',
          );
          return false;
        }
      } else if (response == 'Check-in successful') {
        await _dialogService.showDialog(
          title: 'Success',
          description: 'Check-in successfully started.',
        );
        isCheckedIn = true;
      } else if (response is CustomException) {
        await _dialogService.showDialog(
          title: 'Check-in Failed',
          // description:
          //     'Error: ${response.code}\nDescription: ${response.description}',
          description:
              'Kindly make sure you are at the customer location before checking in.',
        );
        return false;
      }
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'An unexpected error occurred: ${e.toString()}',
      );
      return false;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Future<void> checkOutProcess(
  //   BuildContext context, {
  //   String checkinId,
  //   int visitId,
  // }) async {
  //   try {
  //     // Show a confirmation dialog before checking out
  //     // var dialogResponse = await _dialogService.showConfirmationDialog(
  //     //   title: 'Check Out',
  //     //   description: 'Are you sure you want to check out?',
  //     //   cancelTitle: 'No',
  //     //   confirmationTitle: 'Yes',
  //     // );

  //     // // Proceed only if the user confirms
  //     // if (dialogResponse.confirmed) {
  //     // Prepare the payload for the checkout process
  //     Map<String, dynamic> payload = {
  //       "plannedVisitId": visitId,
  //       "checkOutTime": DateTime.now().toIso8601String(),
  //       "checkOutLat": -1.26877778,
  //       "checkOutLon": 36.90322222,
  //       "activations": _activations ?? '',
  //       "marketingRequest": _marketingRequest ?? '',
  //       "brandingRequest": _brandingRequest ?? '',
  //       "generalFeedback": _generalFeedback ?? '',
  //       // Add any additional data as necessary
  //     };

  //     // Show the loading spinner
  //     setBusy(true);

  //     // Call the API to process the checkout
  //     var result = await _api.checkOut(
  //       token: user.token,
  //       id: visitId,
  //       data: payload,
  //     );

  //     // Hide the loading spinner
  //     setBusy(false);

  //     if (result == true) {
  //       // After successful checkout, create the visit data
  //       // await createVisitData(context, visitId);

  //       // Show success message
  //       await _dialogService.showDialog(
  //         title: 'Success',
  //         description: 'You have successfully checked out.',
  //       );
  //       print("Checkout successful");
  //     } else {
  //       // Show error dialog
  //       CustomException error = result as CustomException;
  //       await _dialogService.showDialog(
  //         title: 'Check Out Failed',
  //         description: 'Error: ${error.title} - ${error.description}',
  //       );
  //       print("Error: ${error.title} - ${error.description}");
  //     }
  //     // }
  //   } catch (e) {
  //     setBusy(false);
  //     await _dialogService.showDialog(
  //       title: 'Error',
  //       description: 'An unexpected error occurred: ${e.toString()}',
  //     );
  //     print("Unexpected error: $e");
  //   }
  // }

  Future<bool> checkOutProcess(
    BuildContext context, {
    String checkinId,
    int visitId,
  }) async {
    final hasPermission = await Helper().handleLocationPermission(context);
    if (!hasPermission) return false;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      _currentPosition = position;
      try {
        // Show a confirmation dialog before checking out
        // var dialogResponse = await _dialogService.showConfirmationDialog(
        //   title: 'Check Out',
        //   description: 'Are you sure you want to check out?',
        //   cancelTitle: 'No',
        //   confirmationTitle: 'Yes',
        // );

        // // Proceed only if the user confirms
        // if (dialogResponse.confirmed) {
        // Prepare the payload for the checkout process
        Map<String, dynamic> payload = {
          "plannedVisitId": visitId,
          "checkOutTime": DateTime.now().toIso8601String(),
          "checkOutLat": _currentPosition.latitude.toString(),
          "checkOutLon": _currentPosition.longitude.toString(),
          // "checkOutLat": -1.26877778,
          // "checkOutLon": 36.90322222,
          "activations": _activations ?? '',
          "marketingRequest": _marketingRequest ?? '',
          "brandingRequest": _brandingRequest ?? '',
          "generalFeedback": _generalFeedback ?? '',
          // Add any additional data as necessary
        };

        // Show the loading spinner
        setBusy(true);

        // Call the API to process the checkout
        var result = await _api.checkOut(
          token: user.token,
          id: visitId,
          data: payload,
        );

        // Hide the loading spinner
        setBusy(false);

        if (result == true) {
          // After successful checkout, create the visit data
          // await createVisitData(context, visitId);

          // Show success message
          await _dialogService.showDialog(
            title: 'Success',
            description: 'You have successfully checked out.',
          );
          print("Checkout successful");
        } else {
          // Show error dialog
          CustomException error = result as CustomException;
          await _dialogService.showDialog(
            title: 'Check Out Failed',
            description: 'Error: ${error.title} - ${error.description}',
          );
          print("Error: ${error.title} - ${error.description}");
        }
        // }
      } catch (e) {
        setBusy(false);
        await _dialogService.showDialog(
          title: 'Error',
          description: 'An unexpected error occurred: ${e.toString()}',
        );
        print("Unexpected error: $e");
      }
    }).catchError((e) {
      setBusy(false);
      notifyListeners();
    });
  }

  Future<bool> createVisitData(BuildContext context, int visitId) async {
    try {
      // print("visitId: $visitId");
      // print(
      //     "selectedProducts: ${selectedProducts.map((product) => product.id).toList()}");
      // print("user.full_name: ${user.full_name}");

      if (selectedProducts == null || selectedProducts.isEmpty) {
        print("Error: selectedProducts is null or empty.");
        await _dialogService.showDialog(
          title: 'Error',
          description:
              'No products selected. Please select products and try again.',
        );
        return false; // Return false to indicate failure
      }

      // Ensure each product has an id
      if (selectedProducts.any((product) => product.id == null)) {
        print("Error: One or more selected products have null ids.");
        await _dialogService.showDialog(
          title: 'Error',
          description: 'One or more selected products do not have valid IDs.',
        );
        return false; // Return false to indicate failure
      }

      shelfPhotoUrlfinal = await uploadImage();

      final payload = {
        "plannedCustomerVisit": visitId,
        "submittedData": selectedProducts.map((product) {
          return {
            "sku": product.id,
            // "shelfAvailability": shelfAvailability,
            // "priceCompliance": priceCompliance,
            // "retailPrice": retailPrice,
            "shelfAvailability": _shelfAvailabilityMap[product.id] ?? '',
            "priceCompliance": _priceComplianceMap[product.id] ?? '',
            "retailPrice": _retailPriceMap[product.id] ?? "N/A",
          };
        }).toList(),
        "shareOfShelf": shareOfShelf,
        "activations": activations,
        "brandAvailability": brandAvailability,
        "marketingRequest": marketingRequest,
        "brandingRequest": brandingRequest,
        "generalFeedback": generalFeedback,
        "shelfPhotoUrl": shelfPhotoUrlfinal,
        "createdBy": user.full_name ?? "Unknown User",
      };

      String payloadJson;
      try {
        payloadJson = jsonEncode(payload);
        print("Payload JSON: $payloadJson");
      } catch (e) {
        print("Error encoding payload to JSON: $e");
        await _dialogService.showDialog(
          title: 'Error',
          description: 'Failed to process the data. Please try again.',
        );
        return false; // Return false to indicate failure
      }

      final dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Check-in Data',
        description: 'Are you sure you want to submit the checklist?',
        cancelTitle: 'No',
        confirmationTitle: 'Yes',
      );

      if (dialogResponse.confirmed) {
        setBusy(true);

        final response = await _api.createVisitData(user.token, payload);

        // Assuming the API returns a success status regardless of the response content
        if (response != null) {
          await _dialogService.showDialog(
            title: 'Success',
            description: 'Checklist successfully submitted.',
          );
          return true;
        } else {
          await _dialogService.showDialog(
            title: 'Error',
            description: 'Submission failed. Please try again.',
          );
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      await _dialogService.showDialog(
        title: 'Error',
        description: 'An unexpected error occurred: ${e.toString()}',
      );
      return false; // Return false to indicate failure
    } finally {
      setBusy(false);
    }
  }

  /// Helper method to submit visit data

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (checkInTime != null) {
        final timeDiff = DateTime.now().difference(checkInTime);
        duration = _formatDuration(timeDiff);
        notifyListeners();
      }
    });
  }

  void _stopTimer() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel(); // Stop the timer when check-out occurs
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}hrs '
        '${minutes.toString().padLeft(2, '0')}min '
        '${seconds.toString().padLeft(2, '0')}sec';
  }

  Future<List<Product>> futureToRun() => fetchProducts();
}
