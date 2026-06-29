// =============================================================================
// widgets/category_badge.dart
// Reusable category chip/badge
// =============================================================================

import 'package:flutter/material.dart';
import '../models/scan_entry.dart';

class CategoryBadge extends StatelessWidget {
  final EntryCategory category;
  final bool          small;

  const CategoryBadge({super.key, required this.category, this.small = false});

  Color _color(EntryCategory cat, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (cat) {
      EntryCategory.note     => scheme.primary,
      EntryCategory.receipt  => Colors.orange.shade700,
      EntryCategory.document => Colors.blue.shade700,
      EntryCategory.id       => Colors.purple.shade700,
      EntryCategory.other    => Colors.grey.shade600,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(category, context);
    final size  = small ? 11.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 8, vertical: small ? 2 : 3),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.icon, style: TextStyle(fontSize: size)),
          const SizedBox(width: 4),
          Text(category.label,
              style: TextStyle(
                  fontSize:   size,
                  color:      color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
