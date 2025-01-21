import 'dart:async';

import 'package:distributor/app/locator.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:distributor/services/out_of_route.dart';
import 'package:distributor/ui/views/crm/outofRoute/outofroutes/all_out-of-routes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  OutOfRouteService _outOfRouteService = locator<OutOfRouteService>();
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

  bool isCheckedIn = false;
  DateTime checkInTime;
  String duration = '00hrs 00min 00sec';
  Timer _timer;

  List<String> reasons = ['Work emergency', 'Personal Emergency'];

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
        "customer": selectedCustomer.id,
        "territory": 1,
        // "reason": selectedReason, // Using the text directly as the reason
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
        "generalFeedback": 'feedback',
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

  // void toggleCheckin(BuildContext context, int visitId) {
  //   isCheckedIn = !isCheckedIn;
  //   notifyListeners();

  //   if (isCheckedIn) {
  //     checkInTime = DateTime.now();
  //     _startTimer();
  //     checkInRequest(
  //         context, visitId); // Pass visitId when calling checkInRequest
  //   } else {
  //     _stopTimer();

  //     if (checkInTime != null) {
  //       final timeDiff = DateTime.now().difference(checkInTime);
  //       duration = _formatDuration(timeDiff);
  //     }
  //     checkInTime = null;

  //     checkOutProcess(context,
  //         visitId: visitId); // Initiates the check-out process
  //   }

  //   notifyListeners();
  // }

  void _calculateDuration() {
    if (checkInTime != null) {
      final timeDiff = DateTime.now().difference(checkInTime);
      duration = _formatDuration(timeDiff);
      checkInTime = null;
    }
  }

  void toggleCheckin(BuildContext context, int visitId) {
    isCheckedIn = !isCheckedIn;
    notifyListeners();

    if (isCheckedIn) {
      checkInTime = DateTime.now();
      _startTimer();
      checkInRequest(context, visitId);
    } else {
      _stopTimer();
      _calculateDuration();
      checkOutProcess(context, visitId: visitId).then((_) {
        // After checkout, navigate to the ScheduleDetailsView
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OutOfRoutesView(),
          ),
        );
      });
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

  Future<void> checkInRequest(BuildContext context, int visitId) async {
    try {
      var payload = {
        "plannedVisitId": visitId,
        "checkInTime": DateTime.now().toUtc().toIso8601String(),
        // "checkInTime": "2024-12-08T12:23:06.189+0000",
        "lat": -1.26777778,
        "lon": 36.90222222
      };

      var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Checkin',
        description: 'Are you sure you want to check in?',
        cancelTitle: 'No',
        confirmationTitle: 'Yes',
      );

      if (dialogResponse.confirmed) {
        setBusy(true);

        var response = await api.checkIn(user.token, payload);

        // if (response is bool && response) {
        if (response == 'Check-in successful') {
          await _dialogService.showDialog(
            title: 'Success',
            description: 'Checkin successfully started.',
          );
          isCheckedIn = true;
        } else if (response is CustomException) {
          // var errorMessage = response['payload'] ?? response['errorMessage'];
          await _dialogService.showDialog(
            // title: 'Checkin Failed',
            // // description: 'There was an issue checking in.\n$errorMessage',
            // description:
            //     'There was an issue checkin in.\nError: ${response.code}\nDescription: ${response.description}',
            title: 'Warning',
            description:
                'There was an issue checkin in because this check in was started.',
          );
        }
      }
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'An unexpected error occurred: ${e.toString()}',
        // title: 'Success',
        // description: 'Checkout successfull.',
      );
    } finally {
      setBusy(false);
      notifyListeners(); // Ensure the UI rebuilds and reflects the new state
    }
  }

  Future<void> checkOutProcess(
    BuildContext context, {
    String checkinId,
    int visitId,
  }) async {
    try {
      // Show a confirmation dialog before checking out
      var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Check Out',
        description: 'Are you sure you want to check out?',
        cancelTitle: 'No',
        confirmationTitle: 'Yes',
      );

      // Proceed only if the user confirms
      if (dialogResponse.confirmed) {
        Map<String, dynamic> payload = {
          "plannedVisitId": visitId,
          "checkOutTime": DateTime.now().toUtc().toIso8601String(),
          "checkOutLat": -1.26877778,
          "checkOutLon": 36.90322222,
          "activations": "Yes, three umbrellas",
          "marketingRequest": "Yes",
          "brandingRequest": "Yes",
          "generalFeedback": _feedback,
          "premisesPhotoUrl": "/volume/photos/premises/premises.png"
        };

        setBusy(true); // Show a loading spinner

        // Call the API to process the checkout
        var result = await api.checkOut(
          token: user.token,
          id: visitId,
          data: payload,
        );

        setBusy(false); // Hide the loading spinner

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
      }
    } catch (e) {
      setBusy(false); // Ensure the spinner is hidden in case of error
      // Show generic error dialog
      await _dialogService.showDialog(
        title: 'Error',
        description: 'An unexpected error occurred: ${e.toString()}',
      );
      print("Unexpected error: $e");
    }
  }
}
