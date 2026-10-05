import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('JROTC Mode'),
              subtitle: Text(settings.jrotcMode
                  ? 'Active: minimum time-in-grade is 4 weeks.'
                  : 'Off: minimum time-in-grade is 8 weeks (CAP).'),
              value: settings.jrotcMode,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).setJrotcMode(v),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'CAP Mode uses 8-week TIG. JROTC Mode uses 4-week TIG.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
