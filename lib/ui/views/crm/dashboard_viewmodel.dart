import 'dart:async';

import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/core/enums.dart';
import 'package:distributor/services/access_controller_service.dart';
import 'package:distributor/services/customer_service.dart';
import 'package:distributor/services/logistics_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/src/ui/views/stock_transaction/stock_transaction_list_view.dart';
import 'package:distributor/ui/views/stock_transfer_request/stock_transfer_request_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:distributor/services/api_service.dart';
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

  CustomerService _customerService = locator<CustomerService>();
  LogisticsService _logisticsService = locator<LogisticsService>();
  UserService _userService = locator<UserService>();
  DialogService _dialogService = locator<DialogService>();
  AccessControlService _accessControlService = locator<AccessControlService>();
  NavigationService _navigationService = locator<NavigationService>();

  Api get api => _apiService.api;

  // bool isDayStarted = false;

  bool isCheckedIn = false;
  DateTime checkInTime;
  String duration = '00hrs 00min 00sec';
  Timer _timer;

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

  List<AllOutofRoute> outOfRouteRequests = [];
  // List<AllOutofRoute> get outOfRouteRequests => _outOfRouteRequests;
  final List<String> scheduledVisits = ['Visit 1', 'Visit 2', 'Visit 3'];
  final List<String> completedVisits = ['Visit 1'];
  final List<String> pendingVisits = ['Visit 1', 'Visit 2'];
  final List<String> plannerItems = ['Task 1'];
  final List<String> cuustomeritems = ['Task 1'];

  void loadOutOfRouteRequests() async {
    outOfRouteRequests = await api.fetchAllOutofRoute(user.token);
    notifyListeners();
  }

  // Methods to get the count of items for each card
  int getOutOfRouteCount() => outOfRouteRequests.length;
  int getScheduledVisitsCount() => scheduledVisits.length;
  int getCompletedVisitsCount() => completedVisits.length;
  int getPendingVisitsCount() => pendingVisits.length;
  int getPlannerCount() => plannerItems.length;
  int getCustomerCount() => cuustomeritems.length;

  void toggleDay(BuildContext context) {
    isDayStarted = !isDayStarted;

    if (isDayStarted) {
      // Call the start day request when the day is being started
      startDayRequest(context);
    } else {
      // Trigger the end day logic here
      endDayProcess(context);
    }
  }

  Future<void> startDayRequest(BuildContext context) async {
    try {
      // Build the payload
      var payload = {
        "salesRepUser": user.id,
        "activeSchedule": 7,
        "territory": 4,
        "firstLoginTime": DateTime.now().toIso8601String(),
        "firstLoginLat": -1.26777778,
        "firstLoginLon": 36.90222222
      };

      // Show confirmation dialog
      var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Start Your Day',
        description: 'Are you sure you want to start your day?',
        cancelTitle: 'No',
        confirmationTitle: 'Yes',
      );

      if (dialogResponse.confirmed) {
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
            title: 'Start Day Failed',
            description:
                'There was an issue starting your day.\nError: ${response.code}\nDescription: ${response.description}',
            // title: 'Success',
            // description: 'Your day has been successfully Started.',
          );
        }
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

  // ... existing code ...
  // Future<void> endDayProcess(BuildContext context) async {
  //   // Optional: Show a confirmation dialog before ending the day
  //   var dialogResponse = await _dialogService.showConfirmationDialog(
  //     title: 'End Your Day',
  //     description: 'Are you sure you want to end your day?',
  //     cancelTitle: 'No',
  //     confirmationTitle: 'Yes',
  //   );

  //   // Proceed only if the user confirms
  //   if (dialogResponse.confirmed) {
  //     // Payload for ending the day
  //     Map<String, dynamic> data = {
  //       "salesRepUser": user.id,
  //       "activeSchedule": activeScheduleId, // Active schedule ID
  //       "territory": territoryId, // Territory ID
  //       "firstLoginTime": DateTime.now().toIso8601String(), // ISO time format
  //       "firstLoginLat": currentLatitude, // Current latitude
  //       "firstLoginLon": currentLongitude, // Current longitude
  //     };

  //     // Retrieve the dynamic ID for ending the day
  //     String dayLogId = getStartedDayLogId(); // Replace this with actual logic

  //     // Call the API to end the day
  //     setBusy(true); // Show a loading spinner
  //     var result = await api.endDay(id: dayLogId, data: data);
  //     setBusy(false); // Hide the loading spinner

  //     if (result == true) {
  //       // Show success message
  //       await _dialogService.showDialog(
  //         title: 'Success',
  //         description: 'Your day has been successfully ended.',
  //       );
  //       print("Day successfully ended");
  //     } else {
  //       // Show error message
  //       CustomException error = result as CustomException;
  //       await _dialogService.showDialog(
  //         title: 'End Day Failed',
  //         description: 'Error: ${error.title} - ${error.description}',
  //       );
  //       print("Error: ${error.title} - ${error.description}");
  //     }
  //   }
  // }

  Future<void> endDayProcess(BuildContext context) async {
    // Optional: Show a confirmation dialog before ending the day
    var dialogResponse = await _dialogService.showConfirmationDialog(
      title: 'End Your Day',
      description: 'Are you sure you want to end your day?',
      cancelTitle: 'No',
      confirmationTitle: 'Yes',
    );

    // Proceed only if the user confirms
    if (dialogResponse.confirmed) {
      // Payload for ending the day
      Map<String, dynamic> data = {
        "salesRepUser": user.id,
        "activeSchedule": activeScheduleId, // Active schedule ID
        "territory": territoryId, // Territory ID
        "firstLoginTime": DateTime.now().toIso8601String(), // ISO time format
        "firstLoginLat": currentLatitude, // Current latitude
        "firstLoginLon": currentLongitude, // Current longitude
      };

      // Retrieve the dynamic ID for ending the day
      String dayLogId = getStartedDayLogId();

      // Call the API to end the day
      setBusy(true); // Show a loading spinner
      var result = await api.endDay(id: dayLogId, data: data);
      setBusy(false); // Hide the loading spinner

      if (result == true) {
        // Show success message
        await _dialogService.showDialog(
          title: 'Success',
          description: 'Your day has been successfully ended.',
        );
        print("Day successfully ended");
      } else {
        // Show error message
        CustomException error = result as CustomException;
        await _dialogService.showDialog(
          title: 'End Day Failed',
          description: 'Error: ${error.title} - ${error.description}',

          // title: 'Success',
          // description: 'Your day has been successfully ended.',
        );
        print("Error: ${error.title} - ${error.description}");
        // print("Success Day Stopped");
      }
    }
  }

// Example method to dynamically fetch the started day ID
  String getStartedDayLogId() {
    return "12"; // Placeholder: Replace with actual logic
    // return dayLogId;
  }

// --------------------------------------------------------------------------------

  navigateToPendingStockTransactions() async {
    _navigationService.navigateTo(Routes.stockTransactionListView);
  }

  navigateToReturnStock() async {
    _navigationService.navigateTo(Routes.stockTransferView);
  }

  navigateToNewContractSale() async {
    await _navigationService.navigateTo(Routes.adhocSalesView,
        arguments: AdhocSalesViewArguments(saleType: CustomerType.Contract));
  }

  navigateToWalkInSale() async {
    await _navigationService.navigateTo(Routes.adhocSalesView,
        arguments: AdhocSalesViewArguments(saleType: CustomerType.Walk_In));
  }

  User get user => _userService.user;
  bool get hasJourney => _logisticsService.hasJourney;
  final String formattedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());

  //Check if user can list journeys
  bool get canListJourneys => _accessControlService.enableJourneyTab;

  // bool get isMiniShop {
  //   if (user.hasSalesChannel) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  // bool get isMiniShop => _accessControlService.isOutlet;

  Future fetchUserJourneys() async {
    //Check if this is a minishop
    if (!user.hasSalesChannel) {
      var result = await _logisticsService.fetchJourneys();
      return result;
    }
  }

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

  init() async {
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

  UserSummary _userSummary;
  UserSummary get userSummary => _userSummary;

  // navigateToPostSale() async {
  //   _navigationService.navigateToView(POSView());
  // }

  navigateToSalesTab() async {
    _navigationService.navigateTo(
      Routes.homeView,
      arguments: HomeViewArguments(index: 1),
    );
  }

  // navigateToSalesReturns() async {
  //   await _navigationService.navigateToView(SalesReturnsView());
  // }

  navigateToPendingTransactions() async {
    _navigationService.navigateToView(
      StockTransactionListView(),
    );
  }

  navigateToStockTransferRequest() async {
    _navigationService.navigateToView(
      StockTransferRequestView(),
    );
  }

  // navigateToCreateQuotationView() async {
  //   _navigationService.navigateToView(
  //     QuotationView(),
  //   );
  // }

  navigateToInvoicingView() async {
    _navigationService.navigateTo(
      Routes.homeView,
      arguments: HomeViewArguments(index: 4),
    );
  }

  navigateToAddAdhocSale() async {
    var result = await _navigationService.navigateTo(Routes.adhocSalesView);
    if (result is bool) {
      setBusy(true);
      // _startDate = DateTime.now();
      // await fetchAdhocSales();
      setBusy(false);
    }
  }

  @override
  Future<List<Customer>> futureToRun() {
    // TODO: implement futureToRun
    throw UnimplementedError();
  }
}
