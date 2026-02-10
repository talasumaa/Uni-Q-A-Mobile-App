import 'package:flutter/material.dart';

class MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const MiniChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(
        label,
        style: t.textTheme.labelMedium,      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}
