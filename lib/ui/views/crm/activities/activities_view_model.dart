import 'dart:async';

import 'package:distributor/app/locator.dart';
import 'package:distributor/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tripletriocore/tripletriocore.dart';
import 'package:distributor/services/api_service.dart';

class ActivitiesViewModel extends MultipleFutureViewModel {
  String _feedback;

  final _apiService = locator<ApiService>();

  UserService _userService = locator<UserService>();
  DialogService _dialogService = locator<DialogService>();

  User get user => _userService.user;
  Api get api => _apiService.api;

  bool isCheckedIn = false;
  DateTime checkInTime;
  String duration = '00hrs 00min 00sec';
  Timer _timer;

  String currentLatitude;
  String currentLongitude;

  String get feedback => _feedback;

  void saveFeedback(String feedback) {
    _feedback = feedback;
    notifyListeners();
  }

  void toggleCheckin(BuildContext context, int visitId) {
    isCheckedIn = !isCheckedIn;
    notifyListeners();

    if (isCheckedIn) {
      checkInTime = DateTime.now();
      _startTimer();
      checkInRequest(
          context, visitId); // Pass visitId when calling checkInRequest
    } else {
      _stopTimer();

      if (checkInTime != null) {
        final timeDiff = DateTime.now().difference(checkInTime);
        duration = _formatDuration(timeDiff);
      }
      checkInTime = null;

      checkOutProcess(context,
          visitId: visitId); // Initiates the check-out process
    }

    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (checkInTime != null && isCheckedIn) {
        final timeDiff = DateTime.now().difference(checkInTime);
        duration = _formatDuration(timeDiff);
        notifyListeners();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}hrs '
        '${minutes.toString().padLeft(2, '0')}min '
        '${seconds.toString().padLeft(2, '0')}sec';
  }

  Future<void> checkInRequest(BuildContext context, int visitId) async {
    try {
      var payload = {
        "plannedVisitId": visitId,
        "checkInTime": DateTime.now().toUtc().toIso8601String(),
        // "checkInTime": "2024-12-08T12:23:06.189+0000",
        "lat": -1.26777778,
        "lon": 36.90222222
      };

      var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Checkin Day',
        description: 'Are you sure you want to check in?',
        cancelTitle: 'No',
        confirmationTitle: 'Yes',
      );

      if (dialogResponse.confirmed) {
        setBusy(true);

        var response = await api.checkIn(user.token, payload);

        // if (response is bool && response) {
        if (response == 'Check-in successful') {
          await _dialogService.showDialog(
            title: 'Success',
            description: 'Checkin successfully started.',
          );
          isCheckedIn = true;
        } else if (response is CustomException) {
          await _dialogService.showDialog(
            title: 'Checkin Failed',
            // description: 'There was an issue checking in.\n$errorMessage',
            description:
                'There was an issue checkin in.\nError: ${response.code}\nDescription: ${response.description}',
          );
        }
      }
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> checkOutProcess(
    BuildContext context, {
    String checkinId,
    int visitId,
  }) async {
    try {
      // Show a confirmation dialog before checking out
      var dialogResponse = await _dialogService.showConfirmationDialog(
        title: 'Check Out',
        description: 'Are you sure you want to check out?',
        cancelTitle: 'No',
        confirmationTitle: 'Yes',
      );

      // Proceed only if the user confirms
      if (dialogResponse.confirmed) {
        Map<String, dynamic> payload = {
          "plannedVisitId": visitId,
          "checkOutTime": DateTime.now().toUtc().toIso8601String(),
          "checkOutLat": -1.26777778,
          "checkOutLon": 36.90222222,
          "generalFeedback": _feedback,
          "premisesPhotoUrl": "/volume/photos/premises/premises.png"
        };

        setBusy(true); // Show a loading spinner

        // Call the API to process the checkout
        var result = await api.checkOut(id: visitId, data: payload);

        setBusy(false); // Hide the loading spinner

        if (result == true) {
          // Show success
          await _dialogService.showDialog(
            title: 'Success',
            description: 'You have successfully checked out.',
          );
          print("Checkout successful");
        } else {
          // Show error dialog
          CustomException error = result as CustomException;
          await _dialogService.showDialog(
            title: 'Check Out Failed',
            description: 'Error: ${error.title} - ${error.description}',
          );
          print("Error: ${error.title} - ${error.description}");
        }
      }
    } catch (e) {
      setBusy(false); // Ensure the spinner is hidden in case of error
      // Show generic error dialog
      await _dialogService.showDialog(
        title: 'Error',
        description: 'An unexpected error occurred: ${e.toString()}',
      );
      print("Unexpected error: $e");
    }
  }

  @override
  Map<String, Future Function()> get futuresMap => {};
}
