import 'dart:math';

class FixDateUtilities {
  /// Fixing a string hour of whatsapp to a parsable dart date.
  /// Whatsapp displays message time in AM/PM format.
  /// Hence, 12 midnight is 12:00 AM (instead of 00:00) while 12 noon is 12:00 PM (normal).
  /// hourFromLine: 10:17 am] Dolev Test Phone: Hi (for android)
  /// hourFromLine: 10:17:07 am] Dolev Test Phone: Hi (for ios)
  static String hourStringOrganization(String hourFromLine) {
    var timeFromLine = hourFromLine.replaceAll(']', '');
    String hour = timeFromLine.split(':')[0];
    String minute = timeFromLine.split(':')[1].split(' ')[0];
    String seconds = timeFromLine.split(':').length < 3
        ? '${randomTime(5, 50).inSeconds}'
        : timeFromLine.split(':')[2].split(' ')[0];
    //
    if (timeFromLine.split(' ').length == 1) {
      return '${fixMonthOrDayTo01(hour)}:$minute:$seconds';
    }
    // If message was sent after 12 noon, message time should be converted to PM
    if (timeFromLine.split(' ')[1] == 'pm' && hour != "12") {
      hour = '${int.parse(hour) + 12}';
    }
    // If message was sent at 12 midnight, message time should be converted to AM
    else if (timeFromLine.split(' ')[1] == 'am' && hour == "12") {
      hour = '${int.parse(hour) - 12}';
    }
    // Otherwise, retain message time
    else {
      hour = fixMonthOrDayTo01(hour);
    }
    return "$hour:$minute:$seconds";
  }

  /// Fixing a string date of whatsapp to a parsable dart date
  /// dateFromLine: [25/04/2022 (ios)
  /// dateFromLine: 25/04/2022 (android)
  static String dateStringOrganization(String dateFromLine) {
    dateFromLine = dateFromLine.replaceAll('[', '');
    List listOfMonthDayYear = dateFromLine.split(RegExp(r"[/|.]"));
    listOfMonthDayYear[0] = fixMonthOrDayTo01(listOfMonthDayYear[0]);
    listOfMonthDayYear[1] = fixMonthOrDayTo01(listOfMonthDayYear[1]);
    listOfMonthDayYear[2] = _fixYear20(listOfMonthDayYear[2]);
    listOfMonthDayYear = _sortList(listOfMonthDayYear);
    String date = _listToStringDate(listOfMonthDayYear);
    return date;
  }

  /// List of String to String - to use the function [DateTime.parse]
  static String _listToStringDate(List list) {
    var concatenate = StringBuffer();
    for (var item in list) {
      concatenate.write(item);
    }
    return '$concatenate';
  }

  ///Sort the list in order to parse the list to string
  static List _sortList(List list) {
    List newList = [];
    newList.add(list[2]);
    newList.add('-');
    newList.add(list[1]);
    newList.add('-');
    newList.add(list[0]);
    return newList;
  }

  /// Som months write as one single number when they should be write as two, for example:
  /// 9 should be 09, 1 should be 01...
  static String fixMonthOrDayTo01(String fix) {
    if (fix.length == 2) {
      return fix;
    } else {
      return '0$fix';
    }
  }

  /// Generate random time in seconds
  static Duration randomTime(int min, int max) {
    final random = Random();
    var time = Duration(seconds: random.nextInt(max - min + 1) + min);
    return time;
  }

  ///The year in Whatsapp are 22, where it should be 2022.
  ///This function added the 2 missing numbers (maybe if you are watching this it is now 3!)
  static String _fixYear20(String year) {
    if (year.length == 4) return year;
    String firstFirstTwoLetters = '${DateTime.now().year}'.substring(0, 2);
    return '$firstFirstTwoLetters$year';
  }
}
