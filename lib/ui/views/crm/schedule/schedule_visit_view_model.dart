import 'package:distributor/app/locator.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
// import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';
import 'package:distributor/services/api_service.dart';
import 'package:stacked_services/stacked_services.dart';

class ScheduleVisitViewModel extends FutureViewModel<List<Customer>> {
  final _apiService = locator<ApiService>();
  CustomerService _customerService = locator<CustomerService>();
  UserService _userService = locator<UserService>();
  final _dialogService = locator<DialogService>();

  Api get _api => _apiService.api;
  User get user => _userService.user;

  bool _isLargeScreen;
  set isLargeScreen(bool val) {
    _isLargeScreen = val;
  }

  bool get isLargeScreen => _isLargeScreen;

  bool _isAsc = true;
  bool get isAsc => _isAsc;

  Customer selectedCustomer;
  String selectedVisitSchedule;
  String selectedReason;
  DateTime selectedDate;
  TimeOfDay selectedTime;

  bool _sortAscending = false;
  bool get sortAscending => _sortAscending;

  toggleSortAscending() {
    _sortAscending = !_sortAscending;
    notifyListeners();
  }

  List<String> salesReps = ['Rep 1', 'Rep 2', 'Rep 3'];
  List<String> visitReasons = [
    'Audit',
    'Couching',
    'Addressing challenges',
    'Opportunities',
    'Aligning of targets',
    'Incentives',
    'Trade visit',
    'General meeting',
    'Sales planning',
    'Sales followup',
    'Filling market gaps',
  ];
  List<String> customerNames = ['Customer A', 'Customer B', 'Customer C'];

  List<Customer> _unorderedList;
  List<Customer> get unorderedList => _unorderedList;

  List<Customer> _customerList = [];
  List<Customer> get customerList => _customerList;

  // Added the 'fetchCustomers' method here
  Future<List<Customer>> fetchCustomers() async {
    var result = await _customerService.customers;
    _customerList = result;
    notifyListeners();
    return result;
  }

  List<Customer> get listOfCustomers {
    return customerList; // Returning the customer list
  }

  List<String> _filters = <String>[];
  List<String> get filters => _filters ?? <String>[];

  bool checkIfFilterExists(String val) {
    return _filters.contains(val);
  }

  List<Map<String, dynamic>> customerFilters = [
    {"name": "All", "value": "All"},
    {"name": "Name", "value": "Sort By Name"},
    {"name": "Route", "value": "Sort By Route"},
  ];

  String _customerFilter = "All";
  String get customerFilter => _customerFilter;
  set customerFilter(String val) {
    _customerFilter = val;
    notifyListeners();
  }

  void setSelectedCustomer(Customer customer) {
    selectedCustomer = customer;
    notifyListeners();
  }

  void setSelectedReason(String reason) {
    selectedReason = reason;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void setSelectedTime(TimeOfDay time) {
    selectedTime = time;
    notifyListeners();
  }

  Map _route = {};
  Map get route => _route;

  Customer _customer;
  Customer get customer => _customer;
  set customer(var c) {
    _customer = c;
    notifyListeners();
  }

  Future<void> confirmVisit(BuildContext context) async {
    try {
      var payload = {
        "salesRepUser": 133,
        "createdBy": user.full_name,
        "customers": [
          {
            "id": 3,
            "customerCode": "C0515",
            "customerName": "A-One Supermarket",
          },
          {
            "id": 2,
            "customerCode": "C0735",
            "customerName": "77 Supermarket",
          }
        ],
        "reason": 1,
        "scheduleStartDate": "2024-11-27T00:00:00.000Z",
        "scheduleEndDate": "2024-11-29T00:00:00.000Z"
      };

      var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Schedule Request',
        description: 'Are you sure you want to schedule request?',
        cancelTitle: 'No',
        confirmationTitle: 'Yes',
      );

      if (dialogResponse.confirmed) {
        setBusy(true);

        var response = await _api.scheduleVisit(user.token, payload);

        // Check if the response is a map before accessing keys
        if (response is bool && response) {
          await _dialogService.showDialog(
            title: 'Success',
            description: 'Schedule request successfull.',
          );
        } else if (response is Map<String, dynamic>) {
          // Handle as a map if necessary
          var errorMessage = response['payload'] ?? response['errorMessage'];
          await _dialogService.showDialog(
            title: 'Checkin Faled Failed',
            description: 'There was an issue Checking In.\n$errorMessage',
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

  // Reset the form fields
  void resetForm() {
    selectedCustomer = null;
    selectedReason = null;
    selectedDate = null;
    selectedTime = null;
    notifyListeners();
  }

  // Display error message (to be replaced with actual error handling)
  // void showErrorMessage(String message) {
  //   print(message); // Replace with actual error handling
  // }

  // // Display success message (to be replaced with actual success handling)
  // void showSuccessMessage(String message) {
  //   print(message); // Replace with actual success handling
  // }

  // Method to initiate the fetching of customers
  @override
  Future<List<Customer>> futureToRun() => fetchCustomers();
}
