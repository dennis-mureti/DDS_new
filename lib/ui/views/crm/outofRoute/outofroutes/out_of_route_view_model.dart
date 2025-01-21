import 'package:distributor/app/locator.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class OutOfRoutesViewModel extends BaseViewModel {
  ApiService _apiService = locator<ApiService>();
  UserService _userService = locator<UserService>();

  bool isDayStarted = false;

  Api get api => _apiService.api;
  User get user => _userService.user;

  List<AllOutofRoute> _unorderedList = [];
  List<AllOutofRoute> get unorderedList => _unorderedList;

  List<AllOutofRoute> _outOfRoutesList = [];
  List<AllOutofRoute> get outOfRoutesList => _outOfRoutesList;

  init() async {
    await fetchOutOfRoutes();
    print('Out of oute fetch: $_outOfRoutesList');
  }

  Future<List<AllOutofRoute>> fetchOutOfRoutes() async {
    setBusy(true);

    try {
      var result = await api.fetchAllOutofRoute(user.token);

      if (result is List) {
        // If the result is already a list, process it directly
        _unorderedList = result.map((item) {
          return AllOutofRoute.fromJson(item);
        }).toList();
        _outOfRoutesList = _unorderedList;
      } else {
        // Handle unexpected regit branch sult format if needed
        _unorderedList = [];
        _outOfRoutesList = [];
      }
    } catch (error) {
      // Handle any errors that occur during the fetch
      print("Error fetching out of routes: $error");
      _unorderedList = [];
      _outOfRoutesList = [];
    }

    setBusy(false);
    notifyListeners();
    return _outOfRoutesList;
  }

  @override
  Future<List<AllOutofRoute>> futureToRun() => fetchOutOfRoutes();
}
