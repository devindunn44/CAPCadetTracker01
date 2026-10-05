import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.label,
    this.trailing,
    this.height = 10,
    this.color,
  });

  /// 0.0 - 1.0
  final double value;
  final String? label;
  final String? trailing;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0).toDouble();
    final barColor =
        color ?? (v >= 1 ? Colors.green.shade600 : Theme.of(context).colorScheme.primary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || trailing != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(label!, style: Theme.of(context).textTheme.labelMedium),
                if (trailing != null)
                  Text(trailing!, style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: LinearProgressIndicator(
            value: v,
            minHeight: height,
            color: barColor,
            backgroundColor: barColor.withOpacity(0.15),
          ),
        ),
      ],
    );
  }
}
