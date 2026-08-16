import 'package:flutter/widgets.dart';

/// Ported from starterflutter-develop. Messages localized to Arabic.
String? validateEmail(String value, BuildContext context) {
  final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]"
    r"(?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
    r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );
  if (value.trim().isEmpty) {
    return "أدخل البريد الإلكتروني";
  } else if (!emailRegex.hasMatch(value.trim())) {
    return "أدخل بريدًا إلكترونيًا صحيحًا";
  }
  return null;
}
