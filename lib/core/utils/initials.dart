/// Up to two initials for an avatar, e.g. "سارة يوسف" -> "س ي".
/// Empty when no usable name was captured.
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '';
  return parts.take(2).map((p) => p.substring(0, 1)).join(' ');
}
