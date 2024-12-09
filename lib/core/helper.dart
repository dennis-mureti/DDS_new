import 'package:intl/intl.dart';

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
}
