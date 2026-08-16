import 'package:flutter/material.dart';
import '../../../core/ui/widgets/selection_row.dart';

/// A selectable answer option (screens 16/20/23).
///
/// Thin wrapper over the shared [SelectionRow] so the challenge feature keeps
/// its own name while the look stays in one place.
class OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const OptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionRow(
      label: label,
      selected: selected,
      onTap: onTap,
    );
  }
}
