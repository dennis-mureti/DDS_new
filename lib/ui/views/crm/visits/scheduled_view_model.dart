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

  Future<List<Visits>> fetchVisits() async {
    setBusy(true);
    await Future.delayed(Duration(seconds: 2));
    var result = await _visitService.getVisits();

    if (result is Map<String, dynamic>) {
      // Decode the payload and convert it to List<ScheduleDetails>
      var payload = result['payload'];

      if (payload != null && payload is List) {
        _unorderedList =
            payload.map((item) => Visits.fromJson(json.decode(item))).toList();
        _visitList = _unorderedList;

        // }
      } else {
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

  @override
  Future<List<Visits>> futureToRun() => fetchVisits();
}
