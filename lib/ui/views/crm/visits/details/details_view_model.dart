import 'package:distributor/app/locator.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class ScheduleDetailsViewModel extends FutureViewModel<List<ScheduleDetails>> {
  ApiService _apiService = locator<ApiService>();
  UserService _userService = locator<UserService>();

  bool isDayStarted = false;

  Api get api => _apiService.api;
  User get user => _userService.user;

  bool _sortAscending = false;
  bool get sortAscending => _sortAscending;
  toggleSortAscending() {
    _sortAscending = !sortAscending;
    notifyListeners();
  }

  List<ScheduleDetails> _unorderedList = []; // Initialize the unordered list
  List<ScheduleDetails> get unorderedList => _unorderedList;

  List<ScheduleDetails> _scheduleDetailsList = [];
  List<ScheduleDetails> get scheduleDetailsList => _scheduleDetailsList;

  init() async {
    await fetchScheduleDetails();
    print('Schedule Details after fetch: $_scheduleDetailsList');
  }

  Future<List<ScheduleDetails>> fetchScheduleDetails() async {
    setBusy(true);
    try {
      // Fetching the result from the API
      var result = await api.fetchAllScheduleDetails(user.token);

      // Check if the result contains the required structure
      if (result is Map<String, dynamic>) {
        print("API Response: $result");

        if (result.containsKey('message') && result.containsKey('payload')) {
          // Parse the entire response into ScheduleDetails
          ScheduleDetails scheduleDetails = ScheduleDetails.fromJson(result);

          // Wrap the object in a list for uniform handling
          _unorderedList = [scheduleDetails];
          _scheduleDetailsList = _unorderedList;
        } else {
          print("Invalid structure, payload missing.");
          _unorderedList = [];
          _scheduleDetailsList = [];
        }
      } else {
        print("Result is not a Map: $result");
        _unorderedList = [];
        _scheduleDetailsList = [];
      }
    } catch (e) {
      // Log and handle any unexpected errors
      print("Error fetching schedule details: $e");
      _unorderedList = [];
      _scheduleDetailsList = [];
    } finally {
      setBusy(false);
      notifyListeners();
    }

    return _scheduleDetailsList;
  }

  @override
  Future<List<ScheduleDetails>> futureToRun() => fetchScheduleDetails();
}
