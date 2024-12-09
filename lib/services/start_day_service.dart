import 'package:distributor/app/locator.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class StartDayService with ReactiveServiceMixin {
  ApiService _apiService = locator<ApiService>();
  UserService _userService = locator<UserService>();

  Api get _api => _apiService.api;
  User get _user => _userService.user;

  // startDayService() {
  //   listenToReactiveValues([
  //     _startDayState,
  //   ]);
  // }

  // StartDay() async {
  //   ActionResultService result = await _api.startDay(token: _user.token);

  //   /// Update the status of [journeyState] to [JourneyState.onGoing]
  //   /// Update the [journeyState]
  //   if (result.actionStatus == ActionStatus.success) {
  //     _startDayState.value = JourneyState.onTrip;
  //     init(currentJourney.journeyId)
  //         .then((value) => value)
  //         .catchError((e) => print(e.toString()));

  //     /// Fetch and populate all info
  //     return true;
  //   } else {
  //     /// The update failed. Return the error string to caller
  //     await _dialogService.showDialog(
  //         title: 'Error', description: result.message);
  //     return false;
  //   }
  // }
}
