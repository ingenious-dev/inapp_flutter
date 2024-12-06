import 'dart:convert';

/// For unexplained error messages, we defaultly return a generic message to mask
/// potentially sensitive API [messages], while at the same time attempting to parse
/// the provided error message and reformat it in a way that is presentable to the
/// user.
String sanitiseUnexplainedErrorMessage(String error) {
  return error;
}

String getErrorMessage(err) {
  String message = '';
  try {
    String jsonString = err.toString().replaceAll('Exception: ', '');
    Map e = jsonDecode(jsonString);
    e.forEach((key, value) {
      if(value is List) {
        value.forEach((element) { message += '$element '; });
      } else {
        message += '$value ';
      }
    });
  } catch(e) {
    message = err.toString().replaceAll('Exception: ', '');
  }
  return message;
}