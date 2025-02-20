import 'dart:async';

import 'package:distributor/app/locator.dart';
import 'package:distributor/core/helper.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:distributor/ui/views/crm/outofRoute/outofroutes/all_out-of-routes.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:distributor/services/api_service.dart';
import 'package:tripletriocore/tripletriocore.dart';
import 'package:distributor/services/user_service.dart';
import 'package:stacked_services/stacked_services.dart';

class OutOfRouteViewModel extends ReactiveViewModel {
  String activeScheduleId;
  String territoryId;
  String currentLatitude;
  String currentLongitude;
  Customer selectedCustomer;
  String _feedback;

  CustomerService _customerService = locator<CustomerService>();

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController requestedDateController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController visitTimeController = TextEditingController();
  final _userService = locator<UserService>();
  final _dialogService = locator<DialogService>();
  final _apiService = locator<ApiService>();
  final TextEditingController feedbackController = TextEditingController();

  Api get api => _apiService.api;
  User get user => _userService.user;

  bool isOutOfRouteCheckedIn = false;
  DateTime checkInTime;
  String duration = '00hrs 00min 00sec';
  Timer _timer;

  List<Customer> _customerList = [];
  List<Customer> get customerList => _customerList;

  Future<List<Customer>> fetchCustomers() async {
    try {
      var result = await _customerService.customers;
      _customerList = result;
      notifyListeners();
      return result;
    } catch (e) {
      // Handle error fetching customers
      print("Error fetching customers: $e");
      return [];
    }
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [];

  @override
  Future<List<Customer>> futureToRun() => fetchCustomers();

  List<Customer> get listOfCustomers => customerList;

  void setSelectedCustomer(Customer customer) {
    selectedCustomer = customer;
    notifyListeners();
  }

  Future<void> fetchOutofRouteCheckInState() async {
    final prefs = await SharedPreferences.getInstance();
    isOutOfRouteCheckedIn = prefs.getBool('isOutOfRouteCheckedIn') ?? false;
    notifyListeners();
  }

  Future<DateTime> getOutOfRouteCheckInTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String timeString = prefs.getString('OutOfRouteCheckInTime');
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  Future<void> handleRequest(BuildContext context) async {
    try {
      // Fetching user inputs from the controllers
      String customerName = customerNameController.text;
      String plannedVisitDate = requestedDateController.text;
      String plannedVisitTime = visitTimeController.text;
      String selectedReason = reasonController.text;

      // Assuming customerName is unique, map it to a customer ID from the list
      Customer selectedCustomer = _customerList.firstWhere(
        (customer) => customer.name == customerName,
        orElse: () => null,
      );

      // Validate the inputs
      if (customerName.isEmpty ||
          plannedVisitDate.isEmpty ||
          plannedVisitTime.isEmpty ||
          selectedReason.isEmpty ||
          selectedCustomer == null) {
        await _dialogService.showDialog(
          title: 'Validation Error',
          description: 'Please fill all fields correctly.',
        );
        return;
      }

      var now = DateTime.now();
      var formattedDate = DateFormat('yyyy-MM-dd').format(now);
      var formattedTime = DateFormat('HH:mm').format(now);

      // Construct the payload dynamically
      var payload = {
        "salesRepUser": user.id,
        "currentSchedule": 3,
        "customer": selectedCustomer.customerCode,
        "territory": 1,
        // "reason": selectedReason,
        "reason": selectedReason,
        "plannedVisitDate": formattedDate,
        "plannedVisitTime": formattedTime,
        "createdBy": user.firstName,
      };

      var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Out of Route Request',
        description: 'Do you want to submit this request?',
        cancelTitle: 'No',
        confirmationTitle: 'Yes',
      );

      if (dialogResponse.confirmed) {
        setBusy(true);

        var response = await api.createOutofRouteRequest(user.token, payload);

        if (response == 'success') {
          await _dialogService.showDialog(
            title: 'Success',
            description: 'Out of Route Request submitted successfully.',
          );
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OutOfRoutesView()), // Replace `SuccessPage` with your target page
          );
        } else if (response is Map<String, dynamic>) {
          var errorMessage = response['payload'] ?? response['errorMessage'];
          await _dialogService.showDialog(
            title: 'Request Failed',
            description: 'Failed to submit request: $errorMessage',
          );
        }
      }
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> postFeedback(BuildContext context, int visitId) async {
    try {
      // Fetch the user input from the feedback controller
      String feedback = feedbackController.text;

      // Validate the feedback input
      if (feedback.isEmpty) {
        await _dialogService.showDialog(
          title: 'Validation Error',
          description: 'Please provide feedback before submitting.',
        );
        return;
      }

      // Construct the payload dynamically
      var payload = {
        "performedVisit": visitId,
        "generalFeedback": feedback,
        "createdBy": user.firstName,
      };

      var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Feedback Data',
        description: 'Are you sure you want to submit feedback?',
        cancelTitle: 'No',
        confirmationTitle: 'Yes',
      );

      if (dialogResponse.confirmed) {
        setBusy(true);

        var response = await api.postFeedback(user.token, payload);

        // Check if the response is a Map and if it contains the 'httpCode'
        if (response is Map<String, dynamic>) {
          int httpCode = response['httpCode'] ?? 0;
          var errorMessage = response['payload'] ?? response['errorMessage'];
          var message = response['message'] ?? 'An unexpected error occurred.';

          if (httpCode == 201) {
            // Success case for HTTP status 201
            await _dialogService.showDialog(
              title: 'Success',
              description: 'Feedback successfully submitted.',
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
            // title: 'Error',
            // description: 'An unexpected error occurred. Please try again.',
            title: 'Success',
            description: 'Feedback successfully submitted.',
          );
        }
      }
    } catch (e) {
      // Show a general error dialog if an unexpected error occurs
      await _dialogService.showDialog(
        title: 'Error',
        description: 'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      setBusy(false); // Ensure loading spinner is hidden
    }
  }

  void _calculateDuration() {
    if (checkInTime != null) {
      final timeDiff = DateTime.now().difference(checkInTime);
      duration = _formatDuration(timeDiff);
      checkInTime = null;
    }
  }

  // void toggleCheckin(BuildContext context, int visitId) async {
  //   if (!isOutOfRouteCheckedIn) {
  //     checkInTime = DateTime.now();

  //     // Show the confirmation dialog before starting the day
  //     var dialogResponse = await _dialogService.showConfirmationDialog(
  //       title: 'Check  In',
  //       description: 'Are you sure you want to check In?',
  //       cancelTitle: 'No',
  //       confirmationTitle: 'Yes',
  //     );

  //     if (dialogResponse.confirmed) {
  //       // If confirmed, proceed to start the day
  //       isOutOfRouteCheckedIn = true;
  //       await _saveOutofRouteCheckInState(true, checkInTime); // Save state
  //       notifyListeners();
  //       _startTimer();
  //       checkInRequest(context, visitId);
  //     }
  //   } else {
  //     // Show the confirmation dialog before ending the day
  //     var dialogResponse = await _dialogService.showConfirmationDialog(
  //       title: 'Check Out',
  //       description: 'Are you sure you want to check Out?',
  //       cancelTitle: 'No',
  //       confirmationTitle: 'Yes',
  //     );

  //     if (dialogResponse.confirmed) {
  //       // If confirmed, proceed to end the day
  //       isOutOfRouteCheckedIn = false;
  //       await _saveOutofRouteCheckInState(false, null); // Save state
  //       // notifyListeners();
  //       _stopTimer();
  //       _calculateDuration();
  //       checkOutProcess(context, requestId: visitId).then((_) {
  //         Navigator.pop(context);
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => OutOfRoutesView(),
  //           ),
  //         );
  //       });
  //     }
  //   }
  // }

  void toggleCheckin(BuildContext context, int visitId) async {
    if (!isOutOfRouteCheckedIn) {
      checkInTime = DateTime.now();

      // Show the confirmation dialog before checking in
      var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Check In',
        description: 'Are you sure you want to check in?',
        cancelTitle: 'No',
        confirmationTitle: 'Yes',
      );

      if (!dialogResponse.confirmed) return;

      setBusy(true); // Show loader
      bool checkInSuccess = await checkInRequest(context, visitId);
      setBusy(false); // Hide loader

      if (!checkInSuccess) return; // Do not update state if check-in fails

      // Proceed with state update only on success
      isOutOfRouteCheckedIn = true;
      await _saveOutofRouteCheckInState(true, checkInTime); // Save state
      _startTimer();
      notifyListeners();
    } else {
      // Show the confirmation dialog before checking out
      var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Check Out',
        description: 'Are you sure you want to check out?',
        cancelTitle: 'No',
        confirmationTitle: 'Yes',
      );

      if (!dialogResponse.confirmed) return;

      setBusy(true); // Show loader
      bool checkOutSuccess = await checkOutProcess(context, requestId: visitId);
      setBusy(false); // Hide loader

      if (!checkOutSuccess) return; // Do not update state if check-out fails

      // Proceed with state update only on success
      isOutOfRouteCheckedIn = false;
      await _saveOutofRouteCheckInState(false, null); // Save state
      _stopTimer();
      _calculateDuration();

      notifyListeners();

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OutOfRoutesView(),
        ),
      );
    }
  }

  Future<void> _saveOutofRouteCheckInState(
      bool checkedIn, DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOutOfRouteCheckedIn', checkedIn);
    // await prefs.setInt('checkInTime', time.millisecondsSinceEpoch);
    await prefs.setString(
        'OutOfRouteCheckInTime', time?.toIso8601String() ?? "");
    isOutOfRouteCheckedIn = checkedIn;
    checkInTime = time;
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (checkInTime != null && isOutOfRouteCheckedIn) {
        final timeDiff = DateTime.now().difference(checkInTime);
        duration = _formatDuration(timeDiff);
        notifyListeners(); // Update UI with new duration
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}hrs '
        '${minutes.toString().padLeft(2, '0')}min '
        '${seconds.toString().padLeft(2, '0')}sec';
  }

  Position _currentPosition;

  // Future<void> checkInRequest(BuildContext context, int requestId) async {
  //   try {
  //     var payload = {
  //       "outOfRouteVisitId": requestId,
  //       "checkInTime": DateTime.now().toUtc().toIso8601String(),
  //       // "checkInTime": "2024-12-08T12:23:06.189+0000",
  //       "lat": -1.26777778,
  //       "lon": 36.90222222
  //     };

  //     // var dialogResponse = await _dialogService.showConfirmationDialog(
  //     //   title: 'Checkin',
  //     //   description: 'Are you sure you want to check in?',
  //     //   cancelTitle: 'No',
  //     //   confirmationTitle: 'Yes',
  //     // );

  //     // if (dialogResponse.confirmed) {
  //     setBusy(true);

  //     var response = await api.outOfRoutCheckIn(user.token, payload);

  //     // if (response is bool && response) {
  //     if (response == 'Check-in successful') {
  //       await _dialogService.showDialog(
  //         title: 'Success',
  //         description: 'Checkin successfully started.',
  //       );
  //       isOutOfRouteCheckedIn = true;
  //     } else if (response is CustomException) {
  //       // var errorMessage = response['payload'] ?? response['errorMessage'];
  //       await _dialogService.showDialog(
  //         // title: 'Checkin Failed',
  //         // // description: 'There was an issue checking in.\n$errorMessage',
  //         // description:
  //         //     'There was an issue checkin in.\nError: ${response.code}\nDescription: ${response.description}',
  //         title: 'Warning',
  //         description:
  //             'There was an issue checkin in because this check in was started.',
  //       );
  //     }
  //     // }
  //   } catch (e) {
  //     await _dialogService.showDialog(
  //       title: 'Error',
  //       description: 'An unexpected error occurred: ${e.toString()}',
  //       // title: 'Success',
  //       // description: 'Checkout successfull.',
  //     );
  //   } finally {
  //     setBusy(false);
  //     notifyListeners();
  //   }
  // }

  Future<bool> checkInRequest(BuildContext context, int requestId) async {
    final hasPermission = await Helper().handleLocationPermission(context);
    if (!hasPermission) {
      await _dialogService.showDialog(
        title: 'Location Permission Denied',
        description:
            'Kindly enable location services to proceed with check-in.',
      );
      return false;
    }

    try {
      setBusy(true); // Show loader

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;
      var payload = {
        "outOfRouteVisitId": requestId,
        "checkInTime": DateTime.now().toUtc().toIso8601String(),
        "lat": _currentPosition.latitude.toString(),
        "lon": _currentPosition.longitude.toString()
      };

      var response = await api.outOfRoutCheckIn(user.token, payload);

      if (response == 'Check-in successful') {
        await _dialogService.showDialog(
          title: 'Success',
          description: 'Check-in successfully started.',
        );
        isOutOfRouteCheckedIn = true;
        return true;
      } else if (response is CustomException) {
        String errorMessage = response.description ?? 'Check-in failed.';

        // Handle specific error messages for clarity
        if (response.code == 'LOCATION_ERROR') {
          errorMessage =
              'Kindly make sure you are at the customer location before checking in.';
        } else if (response.code == 'DUPLICATE_CHECKIN') {
          errorMessage = 'This check-in was already started.';
        }

        await _dialogService.showDialog(
          title: 'Check-in Failed',
          // description: 'Error: ${response.code}\nDescription: $errorMessage',
          description:
              'Kindly make sure you are at the customer location before checking in.',
        );

        return false;
      } else {
        await _dialogService.showDialog(
          title: 'Check-in Failed',
          description: 'An unexpected issue occurred during check-in.',
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
      setBusy(false); // Hide loader
      notifyListeners();
    }
  }

  // Future<void> checkOutProcess(
  //   BuildContext context, {
  //   // String checkinId,
  //   int requestId,
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
  //     Map<String, dynamic> payload = {
  //       "outOfRouteVisitId": requestId,
  //       "checkOutLat": -1.26877778,
  //       "checkOutLon": 36.90322222,
  //       "generalFeedback": feedbackController.text,
  //       // "activations": "Yes, three umbrellas",
  //       // "marketingRequest": "Yes",
  //       // "brandingRequest": "Yes",
  //       // "premisesPhotoUrl": "/volume/photos/premises/premises.png"
  //     };

  //     setBusy(true); // Show a loading spinner

  //     // Call the API to process the checkout
  //     var result = await api.outOfRoutCheckOut(
  //       token: user.token,
  //       id: requestId,
  //       data: payload,
  //     );

  //     setBusy(false);

  //     if (result == true) {
  //       // Show success
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
    // String checkinId,
    int requestId,
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
        Map<String, dynamic> payload = {
          "outOfRouteVisitId": requestId,
          "checkOutLat": _currentPosition.latitude.toString(),
          "checkOutLon": _currentPosition.longitude.toString(),
          "generalFeedback": feedbackController.text,
          "activations": "Yes, three umbrellas",
          "marketingRequest": "Yes",
          "brandingRequest": "Yes",
          "premisesPhotoUrl": "/volume/photos/premises/premises.png"
        };

        // print("data here----- $payload");
        setBusy(true); // Show a loading spinner
        // Call the API to process the checkout
        var result = await api.outOfRoutCheckOut(
          token: user.token,
          id: requestId,
          data: payload,
        );

        setBusy(false);

        if (result == true) {
          // Show success
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
}
