import 'package:distributor/app/locator.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class OutOfRouteService with ReactiveServiceMixin {
  UserService _userService = locator<UserService>();
  ApiService _apiService = locator<ApiService>();

  Api get api => _apiService.api;

  User get user => _userService.user;

  // outOfRouteRequest() async {
  //   var data = {
  //     "salesRepUser": user.id,
  //     "items": [],
  //     "createdBy": user.full_name

  //     // "territory": user.
  //   };
  //   var response = await _apiService.api.createOutofRouteRequest(data: data);
  //   return response;
  // }
}
