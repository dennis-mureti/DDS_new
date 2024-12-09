import 'dart:convert';

import 'package:distributor/app/locator.dart';
import 'package:distributor/services/api_service.dart';
import 'package:stacked/stacked.dart';
import 'package:distributor/services/user_service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:http/http.dart' as http;

import 'package:tripletriocore/tripletriocore.dart';

class VisitService with ReactiveServiceMixin {
  // CustomerService _customerService = locator<CustomerService>();

  ApiService _apiService = locator<ApiService>();
  UserService _userService = locator<UserService>();
  Api get api => _apiService.api;
  User get user => _userService.user;
  final _dialogService = locator<DialogService>();
  final http.Client _client = http.Client();

  // Future createScheduleVisit(
  //     ScheduleVisit scheduleVisitRequest, Customer customer) async {
  //   // Reference the local ScheduleVisitService
  //   var result = await api.scheduleVisit(
  //     token: user.token,
  //     scheduleVisit: scheduleVisitRequest,
  //   );

  //   if (result is bool && result) {
  //     // Post-scheduling tasks, such as updating counters or notifying listeners
  //     // Assuming _visitsScheduled is a reactive service property that needs to be defined
  //     // Since it's not defined in the provided context, we'll simulate the increment
  //     // This should be replaced with the actual property incrementation once defined
  //     print("Simulating visit counter increment.");

  //     notifyListeners();

  //     print("Visit scheduled successfully.");
  //   }

  //   return result;
  // }

  // Future<List<Visits>> get visits async {
  //   List<Visits> _visit = await _apiService.api.fetchAllVisits();
  //   return _visit;
  // }
  // getVisits() async {
  //   var result = await api.fetchAllVisits();
  //   if (result is List<Visits>) {
  //     // _salesOrderItems.value = result;
  //   }
  //   return result;
  // }

  // fetchAllVisits() async {
  //   final String url =
  //       "https://demo.ddsolutions.tech/spvdev-backend/api/v1/crm/visitsSchedule";
  //   // Map<String, String> headers = {"x-auth-token": "$token"};
  //   http.Response response = await _client.get(url);
  //   return json.decode(response.body);
  // }

  getVisits() async {
    var result = await api.fetchAllVisits(user.token);
    print(result);
    // print(result.toString());
    return result;
  }
}
