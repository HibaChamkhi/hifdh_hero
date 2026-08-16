import 'package:flutter/widgets.dart';

/// Ported from starterflutter-develop. Generic required-field validator.
String? validateField(String value, BuildContext context, {String? fieldName}) {
  if (value.trim().isEmpty) {
    return "${fieldName ?? 'هذا الحقل'} مطلوب";
  }
  return null;
}
