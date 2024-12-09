//Service to manage the timeout

import 'dart:async';

import 'package:distributor/app/locator.dart';
import 'package:distributor/app/router.gr.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';

@lazySingleton
class TimeoutService {
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _apiService = locator<ApiService>();
  final _userService = locator<UserService>();

  User get user => _userService.user;

  Api get api => _apiService.api;

  Timer _timer;
  Timer get timer => _timer;

  //Timeout in hours
  final int duration = 8;

  //Initialize the timer
  init() {
    _timer = Timer(Duration(hours: duration), handleTimeout);
  }

  void handleTimeout() async {
    await api.syncOfflineData(user: user);
    //@TODO Clear the db

    //@TODO Stop all background services and streams

    //Display a dialog that the session has timed out
    await _dialogService.showDialog(
        title: 'SESSION EXPIRED',
        description: 'Your session has expired. Please sign in again.');

    //Navigate the user to the login page
    _navigationService.pushNamedAndRemoveUntil(Routes.loginView);
  }
}
