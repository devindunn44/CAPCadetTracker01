import 'package:flutter/material.dart';

class RequirementTile extends StatelessWidget {
  const RequirementTile({
    super.key,
    required this.title,
    required this.detail,
    required this.met,
    this.applicable = true,
    this.onTap,
  });

  final String title;
  final String detail;
  final bool met;
  final bool applicable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final IconData icon;
    final Color color;
    if (!applicable) {
      icon = Icons.remove_circle_outline;
      color = scheme.outline;
    } else if (met) {
      icon = Icons.check_circle;
      color = Colors.green.shade600;
    } else {
      icon = Icons.radio_button_unchecked;
      color = scheme.error;
    }
    return ListTile(
      onTap: applicable ? onTap : null,
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(detail),
      trailing: (applicable && onTap != null)
          ? Icon(Icons.chevron_right, color: scheme.outline)
          : null,
      dense: true,
    );
  }
}
