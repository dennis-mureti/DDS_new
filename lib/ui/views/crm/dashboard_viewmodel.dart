import 'dart:async';
import 'dart:convert';

import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/core/helper.dart';
import 'package:distributor/services/logistics_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:distributor/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

class CRMDashboardViewModel extends FutureViewModel<List<Customer>> {
  String activeScheduleId;
  String territoryId;
  // String currentLatitude;
  // String currentLongitude;
  final _apiService = locator<ApiService>();
  bool isDayStarted = false;
  bool loadingStates = false;
  Position get currentPosition => _currentPosition;

  // CustomerService _customerService = locator<CustomerService>();
  LogisticsService _logisticsService = locator<LogisticsService>();
  UserService _userService = locator<UserService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  SnackbarService snackBarService = locator<SnackbarService>();

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

  PayloadDetail crmStats;

  int scheduledVisits = 0;
  int completedVisits = 0;
  int pendingVisits = 0;
  int cuustomeritems = 0;
  int outofroute = 0;

  loadcrmDashboardTiles() async {
    try {
      var response = await api.fetchDashboardStats(user.token);
      if (response != null) {
        List<dynamic> Payloadlist = response['payload'];
        crmStats = PayloadDetail.fromJson(jsonDecode(Payloadlist.first));
        completedVisits = crmStats.completedVisits;
        scheduledVisits = crmStats.scheduledVisits;
        pendingVisits = crmStats.inProgressVisits;
        outofroute = crmStats.outofroute ?? 0;
        notifyListeners();
      } else {
        print('No crmDashboardTiles requests found');
      }
      return crmStats;
    } catch (e) {
      print('Error fetching crmDashboardTiles requests: $e');
    }
  }

  // int getOutOfRouteCount() => outOfRouteRequests.length;
  int getScheduledVisitsCount() => scheduledVisits;
  int getCompletedVisitsCount() => completedVisits;
  int getPendingVisitsCount() => pendingVisits;
  int getOutOfRouteCount() => outofroute;
  int getCustomerCount() => cuustomeritems;

  Future<void> loadDayState() async {
    final prefs = await SharedPreferences.getInstance();
    isDayStarted = prefs.getBool('isDayStarted') ?? false;
    notifyListeners();
  }

  // Future<bool> _handleLocationPermission() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //     //     content: Text('Location services are disabled. Please enable the services')));
  //     snackBarService.showSnackbar(
  //         message:
  //             'Location services are disabled. Please enable the services');
  //     return false;
  //   }
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       snackBarService.showSnackbar(
  //           message: 'Location permissions are denied');
  //       // ScaffoldMessenger.of(context).showSnackBar(
  //       //     const SnackBar(content: Text('Location permissions are denied')));
  //       return false;
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     snackBarService.showSnackbar(
  //         message:
  //             'Location permissions are permanently denied, we cannot request permissions.');
  //     // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //     //     content: Text('Location permissions are permanently denied, we cannot request permissions.')));
  //     return false;
  //   }
  //   return true;
  // }

  // Save the day state to shared preferences
  Future<void> _saveDayState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDayStarted', isDayStarted);
  }

  Position _currentPosition;

  // Future<void> _getCurrentPosition() async {
  //   final hasPermission = await _handleLocationPermission();
  //   if (!hasPermission) return;
  //   await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
  //       .then((Position position) {
  //     _currentPosition = position;
  //     notifyListeners();
  //   }).catchError((e) {
  //     debugPrint(e);
  //   });
  // }

  void toggleDay(BuildContext context) async {
    if (!isDayStarted) {
      var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Start Your Day',
        description: 'Are you sure you want to start your day?',
        cancelTitle: 'No',
        confirmationTitle: 'Yes',
      );

      if (dialogResponse.confirmed) {
        // If confirmed, proceed to start the day
        isDayStarted = true;
        await _saveDayState();
        notifyListeners();
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

  Future<void> startDayRequest(BuildContext context) async {
    try {
      // Build the payload
      var payload = {
        "salesRepUser": user.id,
        "territory": 4,
        // "firstLoginLat": _currentPosition.latitude.toString(),
        // "firstLoginLon": _currentPosition.longitude.toString(),
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

  // Future<void> startDayRequest(BuildContext context) async {
  //   final hasPermission = await Helper().handleLocationPermission(context);
  //   if (!hasPermission) return;
  //   await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
  //       .then((Position position) async {
  //     _currentPosition = position;
  //     try {
  //       // Build the payload
  //       var payload = {
  //         "salesRepUser": user.id,
  //         "territory": 4,
  //         // "firstLoginLat": _currentPosition.latitude.toString(),
  //         // "firstLoginLon": _currentPosition.longitude.toString(),
  //         "firstLoginLat": -1.26777778,
  //         "firstLoginLon": 36.90222222
  //       };
  //       setBusy(true);

  //       // Call the API
  //       var response = await api.startDay(user.token, payload);

  //       // Check if the response is the success message or another return type
  //       if (response == 'Day started successfully') {
  //         await _dialogService.showDialog(
  //           title: 'Success',
  //           description: 'Your day has been successfully started.',
  //         );
  //         loadingStates = false;
  //         isDayStarted = true;
  //         await _saveDayState();
  //         notifyListeners();
  //       } else if (response is CustomException) {
  //         // Handle errors by displaying the error code and description
  //         await _dialogService.showDialog(
  //           title: 'Warning',
  //           description:
  //               'There was an issue starting your day because it had started earlier.',
  //         );
  //         loadingStates = false;
  //         notifyListeners();
  //       }
  //     } catch (e) {
  //       // Show a general error dialog for unexpected exceptions
  //       await _dialogService.showDialog(
  //         title: 'Error',
  //         description: 'An unexpected error occurred: ${e.toString()}',
  //       );
  //       loadingStates = false;
  //       notifyListeners();
  //     } finally {
  //       setBusy(false);
  //       loadingStates = false;
  //       notifyListeners();
  //     }
  //   }).catchError((e) {
  //     // print("data here -- error 0 " + e);
  //     loadingStates = false;
  //     notifyListeners();
  //   });
  // }

  Future<void> endDayProcess(BuildContext context) async {
    try {
      // Prepare the payload for ending the day
      Map<String, dynamic> data = {
        "salesRepUser": user.id,
        "territory": 4,
        // "lastLoginLat": _currentPosition.latitude.toString(),
        // "lastLoginLon": _currentPosition.longitude.toString(),
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

  // Future<void> endDayProcess(BuildContext context) async {
  //   final hasPermission = await Helper().handleLocationPermission(context);
  //   if (!hasPermission) return;
  //   await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
  //       .then((Position position) async {
  //     _currentPosition = position;
  //     try {
  //       // Prepare the payload for ending the day
  //       Map<String, dynamic> data = {
  //         "salesRepUser": user.id,
  //         "territory": 4,
  //         // "lastLoginLat": currentPosition.latitude.toString(),
  //         // "lastLoginLon": currentPosition.longitude.toString(),
  //         "lastLoginLat": -1.26777778,
  //         "lastLoginLon": 36.90222222
  //       };
  //       setBusy(true);
  //       var result = await api.endDay(token: user.token, data: data);
  //       setBusy(false);

  //       if (result == true) {
  //         // Show success message
  //         await _dialogService.showDialog(
  //           title: 'Success',
  //           description: 'Your day has been successfully ended.',
  //         );
  //         loadingStates = false;
  //         isDayStarted = false;
  //         await _saveDayState();
  //         notifyListeners();
  //         print("Day successfully ended");
  //       } else {
  //         // Handle the error response
  //         CustomException error = result as CustomException;
  //         await _dialogService.showDialog(
  //           title: 'End Day Failed',
  //           description: 'Error: ${error.title} - ${error.description}',
  //         );
  //         loadingStates = false;
  //         notifyListeners();
  //         print("Error: ${error.title} - ${error.description}");
  //       }
  //     } catch (e) {
  //       // Handle unexpected exceptions
  //       await _dialogService.showDialog(
  //         title: 'Error',
  //         description: 'An unexpected error occurred: ${e.toString()}',
  //       );
  //       loadingStates = false;
  //       notifyListeners();
  //     }
  //   }).catchError((e) {
  //     // print("data here -- error 0 " + e);
  //     loadingStates = false;
  //     notifyListeners();
  //   });
  // }

  User get user => _userService.user;
  bool get hasJourney => _logisticsService.hasJourney;
  final String formattedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());

  void init() async {
    // This is not a minishop
    // Dont fetch user journeys
    if (!user.hasSalesChannel) {
      await _logisticsService.fetchJourneys();
    }
    loadcrmDashboardTiles();
    // _handleLocationPermission();
    // _getCurrentPosition();

    setBusy(true);
    // await _fetchCustomerDetails();
    setBusy(false);
  }

  navigateToInvoicingView() async {
    _navigationService.navigateTo(
      Routes.homeView,
      arguments: HomeViewArguments(index: 4),
    );
  }

  @override
  Future<List<Customer>> futureToRun() {
    throw UnimplementedError();
  }
}
