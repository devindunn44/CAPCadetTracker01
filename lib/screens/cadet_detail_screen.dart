import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/achievement.dart';
import '../models/achievement_catalog.dart';
import '../models/activity.dart';
import '../models/cadet.dart';
import '../models/fitness_standards.dart';
import '../services/promotion_engine.dart';
import '../services/providers.dart';
import '../widgets/progress_bar.dart';
import '../widgets/requirement_tile.dart';

class CadetDetailScreen extends ConsumerWidget {
  const CadetDetailScreen({super.key, required this.cadetId});
  final String cadetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cadet = ref.watch(cadetByIdProvider(cadetId));
    if (cadet == null) {
      return Scaffold(
          appBar: AppBar(), body: const Center(child: Text('Cadet not found')));
    }
    final engine = ref.watch(promotionEngineProvider);
    final next = nextAchievementFor(cadet);
    final report = next == null ? null : engine.evaluate(cadet, next);
    final fmt = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(title: Text(cadet.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${cadet.currentRank} • Age ${cadet.ageOn(DateTime.now())} • '
              'Joined ${fmt.format(cadet.joinDate)}'),
          const SizedBox(height: 12),
          if (next == null || report == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Spaatz Award earned — all achievements complete.'),
              ),
            )
          else ...[
            Text('Working toward: ${next.name} (${next.rank})',
                style: Theme.of(context).textTheme.titleLarge),
            if (next.namesake != null) Text(next.namesake!),
            const SizedBox(height: 12),
            ProgressBar(
              value: report.progress,
              label: 'Overall progress',
              trailing: '${report.metCount}/${report.totalCount}',
              height: 12,
            ),
            _section(context, 'Time in grade'),
            _TigCard(report: report, jrotc: ref.watch(settingsProvider).jrotcMode),
            _section(context, 'Healthy Fitness Zone'),
            _HfzCard(cadet: cadet, engine: engine),
            _section(context, 'Requirements (tap to update)'),
            Card(
              child: Column(
                children: [
                  for (final r in report.results.where(
                      (r) => r.category != RequirementCategory.timeInGrade))
                    RequirementTile(
                      title: r.label,
                      detail: r.detail,
                      met: r.met,
                      applicable: r.applicable,
                      onTap: () => _onTap(context, ref, cadet, next, r),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.military_tech),
              label: Text('Promote to ${next.rank}'),
              onPressed: report.eligible
                  ? () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Promote ${cadet.name}?'),
                          content: Text('Award ${next.name} and promote to ${next.rank}. '
                              'The time-in-grade clock restarts today.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Promote')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        ref.read(cadetListProvider.notifier).promote(cadet.id, next);
                      }
                    }
                  : null,
            ),
          ],
          _section(context, 'Activities'),
          if (cadet.activities.isEmpty)
            const Text('No activities logged.')
          else
            Card(
              child: Column(children: [
                for (final a in ([...cadet.activities]..sort((x, y) => y.date.compareTo(x.date))))
                  ListTile(
                    dense: true,
                    leading: Icon(a.type == ActivityType.fitness
                        ? Icons.directions_run
                        : a.type == ActivityType.character
                            ? Icons.diversity_3
                            : Icons.event),
                    title: Text(a.name),
                    subtitle: Text('${a.type.name} • ${fmt.format(a.date)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref
                          .read(cadetListProvider.notifier)
                          .removeActivity(cadet.id, a.id),
                    ),
                  ),
              ]),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Log activity'),
            onPressed: () => _logActivity(context, ref, cadet, ActivityType.fitness),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      );

  Future<void> _onTap(BuildContext context, WidgetRef ref, Cadet cadet,
      Achievement a, RequirementResult r) async {
    final notifier = ref.read(cadetListProvider.notifier);
    switch (r.category) {
      case RequirementCategory.leadership:
        notifier.toggleTest(cadet.id, TestKind.leadership, a.number);
      case RequirementCategory.aerospace:
        notifier.toggleTest(cadet.id, TestKind.aerospace, a.number);
      case RequirementCategory.drill:
        notifier.toggleTest(cadet.id, TestKind.drill, a.number);
      case RequirementCategory.special:
        notifier.toggleTest(cadet.id, TestKind.special, a.number);
      case RequirementCategory.fitnessTest:
        await _recordFitness(context, ref, cadet);
      case RequirementCategory.fitnessActivity:
        await _logActivity(context, ref, cadet, ActivityType.fitness);
      case RequirementCategory.characterActivity:
        await _logActivity(context, ref, cadet, ActivityType.character);
      case RequirementCategory.timeInGrade:
        break;
    }
  }

  Future<void> _logActivity(BuildContext context, WidgetRef ref, Cadet cadet,
      ActivityType type) async {
    final a = await showDialog<Activity>(
        context: context, builder: (_) => _ActivityDialog(initialType: type));
    if (a != null) ref.read(cadetListProvider.notifier).addActivity(cadet.id, a);
  }

  Future<void> _recordFitness(
      BuildContext context, WidgetRef ref, Cadet cadet) async {
    final r = await showDialog<FitnessResult>(
        context: context, builder: (_) => const _FitnessDialog());
    if (r != null) ref.read(cadetListProvider.notifier).recordFitness(cadet.id, r);
  }
}

class _TigCard extends StatelessWidget {
  const _TigCard({required this.report, required this.jrotc});
  final EligibilityReport report;
  final bool jrotc;

  @override
  Widget build(BuildContext context) {
    final done = report.tigDaysRemaining == 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(done
                ? 'Time in grade complete'
                : '${report.tigDaysRemaining} days remaining',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${report.tigWeeks}-week TIG (${jrotc ? 'JROTC' : 'CAP'} mode) • '
                'eligible ${DateFormat.yMMMd().format(report.tigEligibleDate)}'),
            const SizedBox(height: 12),
            ProgressBar(value: report.tigProgress),
          ],
        ),
      ),
    );
  }
}

class _HfzCard extends StatelessWidget {
  const _HfzCard({required this.cadet, required this.engine});
  final Cadet cadet;
  final PromotionEngine engine;

  @override
  Widget build(BuildContext context) {
    final test = cadet.tests.hfz;
    final attained = engine.hfzAttained(cadet);
    final left = engine.hfzDaysRemaining(cadet);
    final age = test == null ? cadet.ageOn(DateTime.now()) : cadet.ageOn(test.date);
    final std = FitnessStandards.forAge(cadet.sex, age);
    final a = engine.hfzAssessment(cadet);

    Widget row(String label, String score, String standard, bool? ok) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            Icon(ok == null ? Icons.help_outline : ok ? Icons.check : Icons.close,
                size: 16, color: ok == null ? Colors.grey : ok ? Colors.green.shade600 : Colors.red.shade600),
            const SizedBox(width: 8),
            SizedBox(width: 90, child: Text(label)),
            Expanded(child: Text('$score  (standard $standard)')),
          ]),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(attained ? Icons.verified : Icons.warning_amber_rounded,
                  color: attained ? Colors.green.shade600 : Colors.orange.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  attained
                      ? 'HFZ attained • $left days until it expires'
                      : test == null
                          ? 'No fitness test recorded'
                          : engine.isFresh(test)
                              ? 'HFZ not attained'
                              : 'HFZ expired (test older than 180 days)',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ]),
            if (test != null) ...[
              const SizedBox(height: 8),
              Text('Tested ${DateFormat.yMMMd().format(test.date)} (age $age)'),
              const SizedBox(height: 4),
              row('Aerobic',
                  test.pacer != null
                      ? 'PACER ${test.pacer}'
                      : test.mileSeconds != null
                          ? 'Mile ${FitnessStandards.formatMile(test.mileSeconds!)}'
                          : '-',
                  'PACER ≥${std.pacer} or mile ≤${FitnessStandards.formatMile(std.mileSeconds)}',
                  a?.aerobic),
              row('Curl-ups', '${test.curlUps ?? '-'}', '≥${std.curlUps}', a?.curlUps),
              row('Push-ups', '${test.pushUps ?? '-'}', '≥${std.pushUps}', a?.pushUps),
              row('Sit & reach', '${test.sitReach ?? '-'} in', '≥${std.sitReach.toStringAsFixed(0)} in', a?.sitReach),
              const SizedBox(height: 4),
              const Text('HFZ = aerobic standard + 2 of 3 of curl-ups, push-ups, sit & reach.',
                  style: TextStyle(fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActivityDialog extends StatefulWidget {
  const _ActivityDialog({required this.initialType});
  final ActivityType initialType;

  @override
  State<_ActivityDialog> createState() => _ActivityDialogState();
}

class _ActivityDialogState extends State<_ActivityDialog> {
  final _name = TextEditingController();
  late ActivityType _type = widget.initialType;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log activity'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Activity name'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ActivityType>(
          value: _type,
          decoration: const InputDecoration(labelText: 'Type'),
          items: [
            for (final t in ActivityType.values)
              DropdownMenuItem(value: t, child: Text(t.name)),
          ],
          onChanged: (t) => setState(() => _type = t ?? _type),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _name.text.trim().isEmpty
              ? null
              : () => Navigator.pop(
                  context,
                  Activity(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    name: _name.text.trim(),
                    type: _type,
                    date: DateTime.now(),
                  )),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _FitnessDialog extends StatefulWidget {
  const _FitnessDialog();

  @override
  State<_FitnessDialog> createState() => _FitnessDialogState();
}

class _FitnessDialogState extends State<_FitnessDialog> {
  final _pacer = TextEditingController();
  final _mile = TextEditingController();
  final _curl = TextEditingController();
  final _push = TextEditingController();
  final _sit = TextEditingController();

  @override
  void dispose() {
    for (final c in [_pacer, _mile, _curl, _push, _sit]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _field(String label, TextEditingController c, {bool decimal = false, bool text = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          controller: c,
          keyboardType: text
              ? TextInputType.text
              : TextInputType.numberWithOptions(decimal: decimal),
          decoration: InputDecoration(labelText: label),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record CPFT (today)'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _field('PACER laps', _pacer),
          _field('1-mile run (mm:ss)', _mile, text: true),
          _field('Curl-ups', _curl),
          _field('Push-ups', _push),
          _field('Sit & reach (inches)', _sit, decimal: true),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            FitnessResult(
              date: DateTime.now(),
              pacer: int.tryParse(_pacer.text.trim()),
              mileSeconds: FitnessStandards.parseMile(_mile.text),
              curlUps: int.tryParse(_curl.text.trim()),
              pushUps: int.tryParse(_push.text.trim()),
              sitReach: double.tryParse(_sit.text.trim()),
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
