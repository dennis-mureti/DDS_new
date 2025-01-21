import 'dart:async';

import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/services/access_controller_service.dart';
import 'package:distributor/services/logistics_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:distributor/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class CRMDashboardViewModel extends FutureViewModel<List<Customer>> {
  String activeScheduleId;
  String territoryId;
  String currentLatitude;
  String currentLongitude;
  final _apiService = locator<ApiService>();
  bool isDayStarted = false;

  // CustomerService _customerService = locator<CustomerService>();
  LogisticsService _logisticsService = locator<LogisticsService>();
  UserService _userService = locator<UserService>();
  DialogService _dialogService = locator<DialogService>();
  AccessControlService _accessControlService = locator<AccessControlService>();
  NavigationService _navigationService = locator<NavigationService>();

  Api get api => _apiService.api;

  // bool isDayStarted = false;

  fetchAllCustomers() async {
    setBusy(true);
    _customerList = await api.fetchAllCustomers(user.token);
    setBusy(false);
    notifyListeners();
    return _customerList;
  }

  bool _sortAscending = false;
  bool get sortAscending => _sortAscending;
  toggleSortAscending() {
    _sortAscending = !sortAscending;
    notifyListeners();
  }

  List<Customer> _unorderedList;
  List<Customer> get unorderedList => _unorderedList;

  List<Customer> _customerList;

  List<AllOutofRoute> _outOfRouteRequests = [];
  List<AllOutofRoute> get outOfRouteRequests => _outOfRouteRequests;

  final List<String> scheduledVisits = ['Visit 1', 'Visit 2', 'Visit 3'];
  final List<String> completedVisits = ['Visit 1'];
  final List<String> pendingVisits = ['Visit 1', 'Visit 2'];
  final List<String> plannerItems = ['Task 1'];
  final List<String> cuustomeritems = ['Task 1'];
  // List<Customer> _customerListing;
  // List<Customer> get customerListing => _customerListing;

  // void loadOutOfRouteRequests() async {
  //   _outOfRouteRequests = await api.fetchAllOutofRoute(user.token);
  //   notifyListeners();
  // }

  void loadOutOfRouteRequests() async {
    try {
      var response = await api.fetchAllOutofRoute(user.token);
      if (response != null && response is List) {
        _outOfRouteRequests = response;
        print(
            'Out of route requests: ${_outOfRouteRequests.length}'); // Debugging
      } else {
        print('No out of route requests found');
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching out-of-route requests: $e');
    }
  }

  // Methods to get the count of items for each card
  int getOutOfRouteCount() => outOfRouteRequests.length;
  int getScheduledVisitsCount() => scheduledVisits.length;
  int getCompletedVisitsCount() => completedVisits.length;
  int getPendingVisitsCount() => pendingVisits.length;
  int getPlannerCount() => plannerItems.length;
  int getCustomerCount() => cuustomeritems.length;

  // void toggleDay(BuildContext context) {
  //   isDayStarted = !isDayStarted;

  //   if (isDayStarted) {
  //     // Call the start day request when the day is being started
  //     startDayRequest(context);
  //   } else {
  //     // Trigger the end day logic here
  //     endDayProcess(context);
  //   }
  // }
  // void toggleDay(BuildContext context) async {
  //   if (isDayStarted) {
  //     // If day is already started, end it without confirmation
  //     isDayStarted = false;
  //     notifyListeners();
  //   } else {
  //     bool confirmStartDay = await _showStartDayConfirmationDialog(context);
  //     if (confirmStartDay == true) {
  //       isDayStarted = true;
  //       notifyListeners();
  //     }
  //   }
  // }

  Future<void> loadDayState() async {
    final prefs = await SharedPreferences.getInstance();
    isDayStarted = prefs.getBool('isDayStarted') ?? false;
    notifyListeners(); // Ensure UI updates
  }

  // Save the day state to shared preferences
  Future<void> _saveDayState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDayStarted', isDayStarted);
  }

  void toggleDay(BuildContext context) async {
    if (!isDayStarted) {
      // Show the confirmation dialog before starting the day
      var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Start Your Day',
        description: 'Are you sure you want to start your day?',
        cancelTitle: 'No',
        confirmationTitle: 'Yes',
      );

      if (dialogResponse.confirmed) {
        // If confirmed, proceed to start the day
        isDayStarted = true;
        await _saveDayState(); // Save state
        notifyListeners(); // Ensure UI updates
        startDayRequest(context);
      }
    } else {
      // Show the confirmation dialog before ending the day
      var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'End Your Day',
        description: 'Are you sure you want to end your day?',
        cancelTitle: 'No',
        confirmationTitle: 'Yes',
      );

      if (dialogResponse.confirmed) {
        // If confirmed, proceed to end the day
        isDayStarted = false;
        await _saveDayState();
        notifyListeners();
        endDayProcess(context);
      }
    }
  }

  Future<bool> _showStartDayConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Start Day"),
          content: const Text("Are you sure you want to start the day?"),
          actions: <Widget>[
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> startDayRequest(BuildContext context) async {
    try {
      // Build the payload
      var payload = {
        "salesRepUser": user.id,
        "territory": 4,
        "firstLoginLat": -1.26777778,
        "firstLoginLon": 36.90222222
      };

      setBusy(true);

      // Call the API
      var response = await api.startDay(user.token, payload);

      // Check if the response is the success message or another return type
      if (response == 'Day started successfully') {
        await _dialogService.showDialog(
          title: 'Success',
          description: 'Your day has been successfully started.',
        );
      } else if (response is CustomException) {
        // Handle errors by displaying the error code and description
        await _dialogService.showDialog(
          title: 'Warning',
          description:
              'There was an issue starting your day because it had started earlier.',
        );
      }
    } catch (e) {
      // Show a general error dialog for unexpected exceptions
      await _dialogService.showDialog(
        title: 'Error',
        description: 'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> endDayProcess(BuildContext context) async {
    try {
      // Prepare the payload for ending the day
      Map<String, dynamic> data = {
        "salesRepUser": user.id,
        "territory": 4,
        "lastLoginLat": -1.26777778,
        "lastLoginLon": 36.90222222
      };

      setBusy(true);
      var result = await api.endDay(token: user.token, data: data);
      setBusy(false);

      if (result == true) {
        // Show success message
        await _dialogService.showDialog(
          title: 'Success',
          description: 'Your day has been successfully ended.',
        );
        print("Day successfully ended");
      } else {
        // Handle the error response
        CustomException error = result as CustomException;
        await _dialogService.showDialog(
          title: 'End Day Failed',
          description: 'Error: ${error.title} - ${error.description}',
        );
        print("Error: ${error.title} - ${error.description}");
      }
    } catch (e) {
      // Handle unexpected exceptions
      await _dialogService.showDialog(
        title: 'Error',
        description: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

// Example method to dynamically fetch the started day ID
  // String getStartedDayLogId() {
  //   return "7";
  //   // return dayLogId;
  // }

// --------------------------------------------------------------------------------

  // navigateToPendingStockTransactions() async {
  //   _navigationService.navigateTo(Routes.stockTransactionListView);
  // }

  // navigateToReturnStock() async {
  //   _navigationService.navigateTo(Routes.stockTransferView);
  // }

  // navigateToNewContractSale() async {
  //   await _navigationService.navigateTo(Routes.adhocSalesView,
  //       arguments: AdhocSalesViewArguments(saleType: CustomerType.Contract));
  // }

  // navigateToWalkInSale() async {
  //   await _navigationService.navigateTo(Routes.adhocSalesView,
  //       arguments: AdhocSalesViewArguments(saleType: CustomerType.Walk_In));
  // }

  User get user => _userService.user;
  bool get hasJourney => _logisticsService.hasJourney;
  final String formattedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());

  //Check if user can list journeys
  // bool get canListJourneys => _accessControlService.enableJourneyTab;

  // bool get isMiniShop {
  //   if (user.hasSalesChannel) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  // bool get isMiniShop => _accessControlService.isOutlet;

  // Future fetchUserJourneys() async {
  //   //Check if this is a minishop
  //   if (!user.hasSalesChannel) {
  //     var result = await _logisticsService.fetchJourneys();
  //     return result;
  //   }
  // }

  // @override
  // Future<List<DeliveryJourney>> futureToRun() async {
  //   List<DeliveryJourney> result = await fetchUserJourneys();

  //   return result;
  // }

  // @override
  // void onData(List<DeliveryJourney> data) {
  //   // SystemNavigator.pop();
  //   super.onData(data);
  // }

  // @override
  // void onError(error) async {
  //   await _dialogService.showDialog(
  //       title: 'Error', description: error.toString());
  //   super.onError(error);
  // }

  void init() async {
    // This is not a minishop
    // Dont fetch user journeys
    if (!user.hasSalesChannel) {
      await _logisticsService.fetchJourneys();
    }
    loadOutOfRouteRequests();

    setBusy(true);
    // await _fetchCustomerDetails();
    setBusy(false);

    //  try {
    //   // Fetch customers from the backend or other sources
    //   customers = await fetchCustomers();
    // } catch (e) {
    //   customers = []; // Ensure it's still a list if fetch fails
    //   print('Error fetching customers: $e');
    // } finally {
    //   setBusy(false);
    //   notifyListeners();
    // }
  }

  navigateToInvoicingView() async {
    _navigationService.navigateTo(
      Routes.homeView,
      arguments: HomeViewArguments(index: 4),
    );
  }

  @override
  Future<List<Customer>> futureToRun() {
    // TODO: implement futureToRun
    throw UnimplementedError();
  }
}
