import 'dart:convert';
import 'package:distributor/app/locator.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:distributor/services/visit_service.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class ScheduleViewModel extends FutureViewModel<List<Visits>> {
  VisitService _visitService = locator<VisitService>();
  ApiService _apiService = locator<ApiService>();
  UserService _userService = locator<UserService>();

  bool isDayStarted = false;

  Api get api => _apiService.api;
  User get user => _userService.user;

  void toggleDay() {
    isDayStarted = !isDayStarted;
    notifyListeners();
  }

  // List<Map<String, dynamic>> visitFilters = [
  //   {"name": "All", "value": "All"},
  //   {"name": "Name", "value": "Sort By Name"},
  //   {"name": "Route", "value": "Sort By Route"},
  // ];

  // String _visitFilters = "All";
  // String get visitFilter => _visitFilters;
  // set visitFilter(String val) {
  //   _visitFilters = val;
  //   notifyListeners();
  // }

  bool _sortAscending = false;
  bool get sortAscending => _sortAscending;
  toggleSortAscending() {
    _sortAscending = !sortAscending;
    notifyListeners();
  }

  bool _sortAsc = true;
  bool get sortAsc => _sortAsc;

  List<Visits> _unorderedList = [];
  List<Visits> get unorderedList => _unorderedList;

  List<Visits> _visitList = [];
  List<Visits> get visitList => _visitList;

  init() async {
    await fetchVisits();
    print('Visits fetch: $_visitList');
  }

  // void setVisitList(List<Visits> visits) {
  //   _visitList = visits;
  //   notifyListeners(); // Ensures UI updates
  // }
  // set visitList(List<Visits> value) {
  //   _visitList = value;
  //   notifyListeners(); // Notify listeners about the change
  // }

  // init() async {
  //   // Initialization logic here
  //   setBusy(true);
  //   await Future.delayed(Duration(seconds: 1)); // Simulate data fetching
  //   setBusy(false);
  // }

  // set visitList(List<Visits> newList) {
  //   _visitList = newList;
  //   notifyListeners(); // To notify listeners if using a reactive ViewModel
  // }

  // Future<List<Visits>> fetchVisits() async {
  //   setBusy(true);
  //   try {
  //     var result = await _visitService.getVisits();

  //     if (result == null || result.isEmpty) {
  //       print('Error: API response is null or empty');
  //       return [];
  //     }

  //     if (result is Map<String, dynamic> && result.containsKey('payload')) {
  //       var payload = result['payload'];

  //       // Handle different payload types
  //       if (payload is String) {
  //         payload = json.decode(payload);
  //       }

  //       if (payload is Map<String, dynamic> && payload.containsKey('data')) {
  //         payload = payload['data'];
  //       }

  //       if (payload is List) {
  //         _unorderedList = payload.map((item) {
  //           if (item is Map<String, dynamic>) {
  //             return Visits.fromJson(item);
  //           } else if (item is String) {
  //             return Visits.fromJson(json.decode(item));
  //           } else {
  //             throw Exception(
  //                 'Unexpected payload item type: ${item.runtimeType}');
  //           }
  //         }).toList();
  //         _visitList = _unorderedList;
  //       } else {
  //         print('Error: payload is not a List');
  //       }
  //     } else {
  //       print('Error: result is not a Map or missing "payload"');
  //     }
  //   } catch (e) {
  //     print('Error fetching visits: $e');
  //   } finally {
  //     setBusy(false);
  //     notifyListeners();
  //   }
  //   return _visitList;
  // }

  // Future<List<Visits>> fetchVisits() async {
  //   setBusy(true);
  //   // try {
  //   var result = await _visitService.getVisits();

  //   if (result is Map<String, dynamic>) {
  //     var payload = result['payload'];

  //     if (payload != null && payload is List) {
  //       _unorderedList = payload.map((item) {
  //         if (item is String) {
  //           return Visits.fromJson(json.decode(item));
  //         } else {
  //           return Visits.fromJson(item);
  //         }
  //       }).toList();
  //       _visitList = _unorderedList;
  //     } else {
  //       // Handle empty or malformed payload
  //       _unorderedList = [];
  //       _visitList = [];
  //     }
  //   } else {
  //     // Handle the case where result is not a Map
  //     _unorderedList = [];
  //     _visitList = [];
  //   }
  //   setBusy(false);
  //   notifyListeners();
  //   // }
  //   return _visitList;
  // }

  // List<Visits> get listOfVisits {
  //   return visitList;
  // }

  Future<List<Visits>> fetchVisits() async {
    setBusy(true);
    await Future.delayed(Duration(seconds: 2));
    var result = await _visitService.getVisits();

    // Check if result is a List and cast it to List<Visits>
    // if (result is List) {
    //   _unorderedList = result
    //       .map((item) => Visits.fromJson(item))
    //       .toList(); // Assuming Visits has a fromJson method
    //   _visitList = _unorderedList; //  Set _visitList to the same data
    //   if (_visitList.isNotEmpty) {
    //     _visitList.sort((b, a) => a.status.compareTo(b.status));
    //   }
    // }
    if (result is Map<String, dynamic>) {
      // Decode the payload and convert it to List<ScheduleDetails>
      var payload = result['payload'];

      if (payload != null && payload is List) {
        _unorderedList =
            payload.map((item) => Visits.fromJson(json.decode(item))).toList();
        _visitList = _unorderedList;

        // Optionally, sort the list (uncomment if required)
        // if (_scheduleDetailsList.isNotEmpty) {
        //   _scheduleDetailsList.sort((b, a) => a.startDay.compareTo(b.startDay));
        // }
      } else {
        // Handle empty or malformed payload
        _unorderedList = [];
        _visitList = [];
      }
    } else {
      // Handle the case where result is not a List
      _unorderedList = [];
      _visitList = [];
    }
    setBusy(false);
    notifyListeners();
    return _visitList;
  }

  // Future<List<Visits>> fetchVisits() async {
  //   setBusy(true);

  //   // Fetching the result from the API
  //   var result = await api.fetchAllVisits(token: user.token);

  //   if (result is Map<String, dynamic>) {
  //     // Decode the payload and convert it to List<ScheduleDetails>
  //     var payload = result['payload'];

  //     if (payload != null && payload is List) {
  //       _unorderedList =
  //           payload.map((item) => Visits.fromJson(json.decode(item))).toList();
  //       _visitList = _unorderedList;

  //       // Optionally, sort the list (uncomment if required)
  //       // if (_scheduleDetailsList.isNotEmpty) {
  //       //   _scheduleDetailsList.sort((b, a) => a.startDay.compareTo(b.startDay));
  //       // }
  //     } else {
  //       // Handle empty or malformed payload
  //       _unorderedList = [];
  //       _visitList = [];
  //     }
  //     // } else {
  //     //   // Handle the case where result is not  a Map
  //     //   _unorderedList = [];
  //     //   _visitList = [];
  //   }
  //   setBusy(false);
  //   notifyListeners();

  //   return _visitList;
  // }

  // Future<List<Visits>> fetchVisits() async {
  //   setBusy(true);
  //   try {
  //     var result = await _visitService.getVisits();
  //     if (result != null && result['payload'] != null) {
  //       var payload = result['payload'];
  //       if (payload is List) {
  //         _unorderedList =
  //             payload.map((item) => Visits.fromJson(item)).toList();
  //         _visitList = _unorderedList;
  //       } else {
  //         print('Unexpected payload format');
  //       }
  //     } else {
  //       print('Result or payload is null');
  //     }
  //   } catch (e) {
  //     print('Error fetching visits: $e');
  //   } finally {
  //     setBusy(false);
  //   }
  //   notifyListeners();
  //   return _visitList;
  // }
  // Future<List<Visits>> fetchVisits() async {
  //   setBusy(true);
  //   try {
  //     var result = await _visitService.getVisits();

  //     if (result is String) {
  //       // Decode the string into a map
  //       result = json.decode(result) as Map<String, dynamic>;
  //     }

  //     if (result != null && result['payload'] != null) {
  //       var payload = result['payload'];
  //       if (payload is List) {
  //         _unorderedList =
  //             payload.map((item) => Visits.fromJson(item)).toList();
  //         _visitList = _unorderedList;
  //       } else {
  //         print('Unexpected payload format');
  //       }
  //     } else {
  //       print('Result or payload is null');
  //     }
  //   } catch (e) {
  //     print('Error fetching visits: $e');
  //   } finally {
  //     setBusy(false);
  //   }
  //   notifyListeners();
  //   return _visitList;
  // }

  // Future<List<Visits>> fetchVisits() async {
  //   setBusy(true);
  //   var result = await _visitService.getVisits();

  //   if (result is Map<String, dynamic>) {
  //     var payload = result['payload'];

  //     if (payload != null && payload is List) {
  //       try {
  //         _unorderedList = payload
  //             .map((item) => Visits.fromJson(item as Map<String, dynamic>))
  //             .toList();
  //         _visitList = _unorderedList;

  //         // Uncomment if sorting is needed
  //         // if (_visitList.isNotEmpty) {
  //         //   _visitList.sort((b, a) => a.scheduleStartDate.compareTo(b.scheduleStartDate));
  //         // }
  //       } catch (e) {
  //         print("Error parsing Visits: $e");
  //         _unorderedList = [];
  //         _visitList = [];
  //       }
  //     } else {
  //       _unorderedList = [];
  //       _visitList = [];
  //     }
  //     // } else {
  //     //   _unorderedList = [];
  //     //   _visitList = [];
  //   }

  //   setBusy(false);
  //   notifyListeners();
  //   return _visitList;
  // }

  // List<Visits> get listOfVisits {
  //   return visitList;
  // }

  // Future<List<Visits>> fetchVisits() async {
  //   var result = await _visitService.visits;
  //   return result;
  // }

  // fetchVisits() async {
  //   setBusy(true);
  //   _visitList = await _visitService.getVisits();
  //   // _customerSalesOrders = await _customerService
  //   //     .fetchCustomerOrdersNonReactive(customer.customerCode);
  //   setBusy(false);
  //   notifyListeners();
  // }

  // init() async {
  //   // This is not a minishop
  //   // Dont fetch user journeys
  //   // if (!user.hasSalesChannel) {
  //   //   await _logisticsService.fetchJourneys();
  //   // }
  // }
  // ScheduleViewModel.dart (example)
  // Future<void> init() async {
  //   setBusy(true);
  //   try {
  //     // Fetch the visits from API or database
  //     _visitList = await fetchVisits();
  //   } catch (e) {
  //     print('Error fetching visits: $e');
  //   } finally {
  //     setBusy(false);
  //   }
  // }

  @override
  Future<List<Visits>> futureToRun() => fetchVisits();
}
