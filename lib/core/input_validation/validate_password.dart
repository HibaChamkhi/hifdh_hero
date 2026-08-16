import 'package:flutter/widgets.dart';

/// Ported from starterflutter-develop. Messages localized to Arabic.
String? validatePassword(String value, BuildContext context) {
  if (value.trim().isEmpty) {
    return "أدخل كلمة المرور";
  } else if (value.trim().length < 8) {
    return "يجب أن تكون كلمة المرور 8 أحرف على الأقل";
  }
  return null;
}
