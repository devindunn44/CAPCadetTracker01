import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/achievement_catalog.dart';
import '../models/cadet.dart';
import '../models/fitness_standards.dart';
import '../services/providers.dart';
import '../widgets/progress_bar.dart';
import 'cadet_detail_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cadets = ref.watch(cadetListProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CAP Cadet Progress Tracker'),
        actions: [
          Center(
            child: Chip(
              label: Text(settings.jrotcMode ? 'JROTC • 4 wk TIG' : 'CAP • 8 wk TIG'),
              visualDensity: VisualDensity.compact,
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: cadets.isEmpty
          ? const Center(child: Text('No cadets yet. Tap "Add cadet" to begin.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cadets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _CadetCard(cadet: cadets[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Add cadet'),
        onPressed: () => _addCadet(context, ref),
      ),
    );
  }

  Future<void> _addCadet(BuildContext context, WidgetRef ref) async {
    final cadet = await showDialog<Cadet>(
        context: context, builder: (_) => const _AddCadetDialog());
    if (cadet != null) ref.read(cadetListProvider.notifier).add(cadet);
  }
}

class _CadetCard extends ConsumerWidget {
  const _CadetCard({required this.cadet});
  final Cadet cadet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(promotionEngineProvider);
    final next = nextAchievementFor(cadet);
    final report = next == null ? null : engine.evaluate(cadet, next);
    final initials = cadet.name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CadetDetailScreen(cadetId: cadet.id))),
        onLongPress: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Remove ${cadet.name}?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
              ],
            ),
          );
          if (ok == true) ref.read(cadetListProvider.notifier).remove(cadet.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(child: Text(initials)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cadet.name, style: Theme.of(context).textTheme.titleMedium),
                      Text('${cadet.currentRank} • Age ${cadet.ageOn(DateTime.now())}'),
                    ],
                  ),
                ),
                if (report?.eligible ?? false)
                  Chip(
                    label: const Text('Eligible'),
                    backgroundColor: Colors.green.shade100,
                    visualDensity: VisualDensity.compact,
                  ),
              ]),
              const SizedBox(height: 12),
              if (report == null || next == null)
                const Text('All achievements complete — Spaatz Award earned.')
              else ...[
                Text('Next: ${next.name} (${next.rank})',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ProgressBar(
                  value: report.progress,
                  label: 'Requirements',
                  trailing: '${report.metCount}/${report.totalCount}',
                ),
                const SizedBox(height: 8),
                Text(report.tigDaysRemaining == 0
                    ? 'Time in grade met (${report.tigWeeks} wks)'
                    : 'TIG: ${report.tigDaysRemaining} days remaining '
                        '(eligible ${DateFormat.yMMMd().format(report.tigEligibleDate)})'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCadetDialog extends StatefulWidget {
  const _AddCadetDialog();

  @override
  State<_AddCadetDialog> createState() => _AddCadetDialogState();
}

class _AddCadetDialogState extends State<_AddCadetDialog> {
  final _name = TextEditingController();
  Sex _sex = Sex.male;
  DateTime _dob = DateTime(DateTime.now().year - 13, 1, 1);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add cadet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Name'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SegmentedButton<Sex>(
            segments: const [
              ButtonSegment(value: Sex.male, label: Text('Male')),
              ButtonSegment(value: Sex.female, label: Text('Female')),
            ],
            selected: {_sex},
            onSelectionChanged: (s) => setState(() => _sex = s.first),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.cake),
            label: Text('Born ${DateFormat.yMMMd().format(_dob)}'),
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _dob,
                firstDate: DateTime(1990),
                lastDate: DateTime.now(),
              );
              if (d != null) setState(() => _dob = d);
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _name.text.trim().isEmpty
              ? null
              : () {
                  final now = DateTime.now();
                  Navigator.pop(
                    context,
                    Cadet(
                      id: now.microsecondsSinceEpoch.toString(),
                      name: _name.text.trim(),
                      joinDate: now,
                      dateOfBirth: _dob,
                      sex: _sex,
                      currentAchievement: 0,
                      currentRank: 'C/AB',
                      tigStart: now,
                    ),
                  );
                },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
