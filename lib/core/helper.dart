import 'package:distributor/app/locator.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked_services/stacked_services.dart';

DialogService _dialogService = locator<DialogService>();

class Helper {
  static String formatDateTime(var valToFormat) {
    var formatter = DateFormat('dd-MM-yyyy h:mm a');
    String formatted = formatter.format(DateTime.parse(valToFormat));
    return formatted;
  }

  static formatDate(DateTime dateTime) {
    var formatter = DateFormat('dd MMM yyyy');
    String formatted = formatter.format(dateTime);
    return formatted;
  }

  static formatDateShort(DateTime dateTime) {
    var formatter = DateFormat('dd MMM');
    String formatted = formatter.format(dateTime);
    return formatted;
  }

  static formatDateFromString(String val) {
    DateTime dateTime = DateTime.parse(val);
    var formatter = DateFormat('dd MMM yyyy');
    String formatted = formatter.format(dateTime);
    return formatted;
  }

  static formatTimeFromString(String val) {
    DateTime dateTime = DateTime.parse(val);
    var formatter = DateFormat.jm();
    String formatted = formatter.format(dateTime);
    return formatted;
  }

  static formatToTime(DateTime dateTime) {
    var formatter = DateFormat.jm();
    String formatted = formatter.format(dateTime);
    return formatted;
  }

  static String formatDateForAccounts(var valToFormat) {
    var formatter = DateFormat('dd MMM yyyy');
    String formatted = formatter.format(DateTime.parse(valToFormat));
    return formatted;
  }

  static String getDay(var valToFormat) {
    var formatter = DateFormat('dd MMM yyyy');
    String formatted = formatter.format(DateTime.parse(valToFormat));
    return formatted;
  }

  static String formatRegistration(String value) {
    //Check if the registration has spaces
    String result = value.trim();
    String formattedRegistration;
    List<String> parts = result.split(' ');
    print(parts.length);
    if (parts.length == 1) {
      String first = result.substring(0, 3);
      String second = result.substring(3);
      formattedRegistration = first + ' ' + second;
    } else {
      formattedRegistration = result;
    }
    return formattedRegistration;
  }

  static String formatStringWithHtml(String val) {
    return val.replaceAll('<br>', ',');
  }

  static String getTime(var valToFormat) {
    var formatter = DateFormat('h:mm a');
    String formatted = formatter.format(DateTime.parse(valToFormat));
    return formatted;
  }

  static formatCurrency(var valToFormat) {
    var f = NumberFormat("###,##0.00");
    String formattedString;
    if (valToFormat == null) {
      formattedString = " ";
    } else {
      formattedString = f.format(valToFormat);
    }
    return formattedString;
  }

  Future<bool> handleLocationPermission(BuildContext context) async {
    final permissions = Permission.location;

    final result = await permissions.request();

    debugPrint("the loc permission $result");

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text('Location services are disabled. Please enable the services')));

      final response = await _dialogService.showDialog(
          title: "Could not complete request",
          description:
              'Location services are disabled. Please enable the services');
      if (response.confirmed) {
        await Geolocator.openLocationSettings();
      }
      return false;
    }
// Requesting location permission
    PermissionStatus status = await Permission.location.request();

    // If permission is denied
    if (status == PermissionStatus.denied) {
      // Asking again after denying once
      status = await Permission.location.request();
      if (status == PermissionStatus.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permissions are denied'),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                // Navigate to location settings, if needed
              },
            ),
          ),
        );
        return false;
      }
    }

    // If permission is denied forever
    if (status == PermissionStatus.permanentlyDenied) {
      final response = await _dialogService.showDialog(
        title: "Could not complete request",
        description:
            'Location permissions are permanently denied. Please go to settings to enable permissions.',
      );
      if (response.confirmed) {
        await Geolocator.openAppSettings();
      }
      return false;
    }

    // If permission is granted
    return true;
  }

  Position currentPosition;
  getCurrentPosition(BuildContext context) async {
    final hasPermission = await handleLocationPermission(context);
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      currentPosition = position;
      // notifyListeners();
      // print("data here -- error 0 " + currentPosition.longitude.toString());
      return currentPosition;
    }).catchError((e) {
      // print("data here -- error 0 " + e);
    });
  }
}
