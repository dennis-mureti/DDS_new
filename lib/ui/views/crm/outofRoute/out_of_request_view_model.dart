import 'package:distributor/app/locator.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:distributor/services/out_of_route.dart';
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

  OutOfRouteService _outOfRouteService = locator<OutOfRouteService>();
  CustomerService _customerService = locator<CustomerService>();

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController requestedDateController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController visitTimeController = TextEditingController();
  final _userService = locator<UserService>();
  final _dialogService = locator<DialogService>();
  final _apiService = locator<ApiService>();

  Api get api => _apiService.api;
  User get user => _userService.user;

  List<String> reasons = ['Work emergency', 'Personal Emergency'];
  // List<Map<String, dynamic>> reasons = [
  //   {'id': 1, 'label': 'Work emergency'},
  //   {'id': 2, 'label': 'Personal Emergency'},
  // ];
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

  // handleRequest(BuildContext context) async {
  //   final customerName = customerNameController.text;
  //   final requestedDate = requestedDateController.text;
  //   final reason = reasonController.text;
  //   final requestedTime = visitTimeController.text;

  //   // Validate the fields
  //   if (customerName.isEmpty ||
  //       requestedDate.isEmpty ||
  //       reason.isEmpty ||
  //       requestedTime.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please fill all fields')),
  //     );
  //     return;
  //   }
  //   try {
  //     final response = await _outOfRouteService.outOfRouteRequest();

  //     // Check the response
  //     if (response != null && response == true) {
  //       // Show success message
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Request submitted successfully')),
  //       );
  //     } else {
  //       // Handle API errors
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Request submitted successfully')),
  //       );
  //     }
  //   } catch (error) {
  //     // Handle any exceptions during the API call
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $error')),
  //     );
  //   }
  // }

  // Future<void> handleRequest(BuildContext context) async {
  //   try {
  //     var payload = {
  //       "salesRepUser": user.id,
  //       "currentSchedule": 1,
  //       "customer": 1,
  //       "territory": 1,
  //       "reason": 1,
  //       "plannedVisitDate": "2024-11-19",
  //       "plannedVisitTime": "08:30",
  //       "createdBy": user.full_name
  //     };

  //     var dialogResponse = await _dialogService.showConfirmationDialog(
  //       title: 'Out of Route Request',
  //       description: 'Make Out of Route Request',
  //       cancelTitle: 'No',
  //       confirmationTitle: 'Yes',
  //     );

  //     if (dialogResponse.confirmed) {
  //       setBusy(true);

  //       var response = await api.createOutofRouteRequest(user.token, payload);

  //       // Check if the response is a map before accessing keys
  //       if (response is bool && response) {
  //         await _dialogService.showDialog(
  //           title: 'Success',
  //           description: 'Request Was successfull.',
  //         );
  //       } else if (response is Map<String, dynamic>) {
  //         // Handle as a map if necessary
  //         var errorMessage = response['payload'] ?? response['errorMessage'];
  //         await _dialogService.showDialog(
  //           title: 'Request Failed',
  //           description:
  //               'There was an issue Making out of route request In.\n$errorMessage',
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

  Future<void> handleRequest(BuildContext context) async {
    try {
      // Fetching user inputs from the controllers
      String customerName = customerNameController.text;
      String plannedVisitDate = requestedDateController.text;
      String plannedVisitTime = visitTimeController.text;
      String reason = reasonController.text;

      // Assuming customerName is unique, map it to a customer ID from the list
      Customer selectedCustomer = _customerList.firstWhere(
        (customer) => customer.name == customerName,
        orElse: () => null,
      );

      // Validate the inputs
      if (customerName.isEmpty ||
          plannedVisitDate.isEmpty ||
          plannedVisitTime.isEmpty ||
          reason.isEmpty ||
          selectedCustomer == null) {
        await _dialogService.showDialog(
          title: 'Validation Error',
          description: 'Please fill all fields correctly.',
        );
        return;
      }

      // Constructing the payload dynamically
      // var payload = {
      //   "salesRepUser": user.id,
      //   "currentSchedule": 3,
      //   "customer": selectedCustomer.id,
      //   "territory": 1,
      //   "reason": 1,
      //   "plannedVisitDate": "2024-11-19",
      //   "plannedVisitTime": "08:30",
      //   // "plannedVisitDate": plannedVisitDate,
      //   // "plannedVisitTime": plannedVisitTime,
      //   "createdBy": user.full_name,
      // };

      var now = DateTime.now();
      var formattedDate = DateFormat('yyyy-MM-dd').format(now);
      var formattedTime = DateFormat('HH:mm').format(now);

      var payload = {
        "salesRepUser": user.id,
        "currentSchedule": 3,
        "customer": selectedCustomer.id,
        "territory": 1,
        "reason": 1,
        "plannedVisitDate": formattedDate, // Dynamically fetched date
        "plannedVisitTime": formattedTime, // Dynamically fetched time
        "createdBy": user.full_name,
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

        // if (response is bool && response) {

        if (response == 'success') {
          await _dialogService.showDialog(
            title: 'Success',
            description: 'Out of Route Request submitted successfully.',
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
}
