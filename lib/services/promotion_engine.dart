import 'dart:math' as math;

import '../models/achievement.dart';
import '../models/activity.dart';
import '../models/app_settings.dart';
import '../models/cadet.dart';
import '../models/fitness_standards.dart';

enum RequirementCategory {
  leadership,
  aerospace,
  drill,
  fitnessTest,
  fitnessActivity,
  characterActivity,
  special,
  timeInGrade,
}

class RequirementResult {
  const RequirementResult({
    required this.category,
    required this.label,
    required this.detail,
    required this.met,
    this.applicable = true,
  });

  final RequirementCategory category;
  final String label;
  final String detail;
  final bool met;

  /// false when the chart says "No requirement" for this achievement.
  final bool applicable;
}

class EligibilityReport {
  const EligibilityReport({
    required this.achievement,
    required this.results,
    required this.tigWeeks,
    required this.tigEligibleDate,
    required this.tigDaysRemaining,
    required this.tigProgress,
  });

  final Achievement achievement;
  final List<RequirementResult> results;
  final int tigWeeks;
  final DateTime tigEligibleDate;
  final int tigDaysRemaining;
  final double tigProgress;

  Iterable<RequirementResult> get _applicable =>
      results.where((r) => r.applicable);
  int get totalCount => _applicable.length;
  int get metCount => _applicable.where((r) => r.met).length;
  bool get eligible => _applicable.every((r) => r.met);
  double get progress => totalCount == 0 ? 1 : metCount / totalCount;
}

class PromotionEngine {
  PromotionEngine({required this.settings, DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final AppSettings settings;
  final DateTime Function() _clock;

  /// HFZ / CPFT results are valid for 180 days per the Super Chart.
  static const int fitnessValidityDays = 180;

  /// CAP mode: the achievement's own TIG (default 8 weeks).
  /// JROTC mode: shortened to at most 4 weeks.
  int tigWeeksFor(Achievement a) => settings.jrotcMode
      ? math.min(a.tigWeeks, AppSettings.jrotcTigWeeks)
      : a.tigWeeks;

  bool isEligible(Cadet cadet, Achievement achievement) =>
      evaluate(cadet, achievement).eligible;

  bool isFresh(FitnessResult? r) =>
      r != null && _clock().difference(r.date).inDays <= fitnessValidityDays;

  HfzAssessment? hfzAssessment(Cadet cadet) {
    final r = cadet.tests.hfz;
    if (r == null) return null;
    return FitnessStandards.assess(r, cadet.sex, cadet.ageOn(r.date));
  }

  bool hfzAttained(Cadet cadet) =>
      isFresh(cadet.tests.hfz) && (hfzAssessment(cadet)?.attained ?? false);

  /// Days left before the HFZ result expires (null if no valid HFZ).
  int? hfzDaysRemaining(Cadet cadet) {
    if (!hfzAttained(cadet)) return null;
    final used = _clock().difference(cadet.tests.hfz!.date).inDays;
    return fitnessValidityDays - used;
  }

  EligibilityReport evaluate(Cadet cadet, Achievement a) {
    final now = _clock();
    final results = <RequirementResult>[
      _test(RequirementCategory.leadership, 'Leadership', a.leadership,
          cadet.tests.leadership.contains(a.number)),
      _test(RequirementCategory.aerospace, 'Aerospace', a.aerospace,
          cadet.tests.aerospace.contains(a.number)),
      _test(RequirementCategory.drill, 'Drill', a.drill,
          cadet.tests.drill.contains(a.number)),
      ..._fitness(cadet, a, now),
      ..._activities(cadet, a),
      _test(RequirementCategory.special, 'Special requirement', a.special,
          cadet.tests.special.contains(a.number)),
    ];

    final weeks = tigWeeksFor(a);
    final eligibleDate = cadet.tigStart.add(Duration(days: weeks * 7));
    final remaining = math.max(0, (eligibleDate.difference(now).inHours / 24).ceil());
    final tigMet = !now.isBefore(eligibleDate);
    final elapsed = now.difference(cadet.tigStart).inHours / (weeks * 7 * 24);
    results.add(RequirementResult(
      category: RequirementCategory.timeInGrade,
      label: 'Time in grade ($weeks weeks, ${settings.jrotcMode ? 'JROTC' : 'CAP'})',
      detail: tigMet
          ? 'Complete'
          : '$remaining day${remaining == 1 ? '' : 's'} remaining',
      met: tigMet,
    ));

    return EligibilityReport(
      achievement: a,
      results: results,
      tigWeeks: weeks,
      tigEligibleDate: eligibleDate,
      tigDaysRemaining: tigMet ? 0 : remaining,
      tigProgress: elapsed.clamp(0.0, 1.0).toDouble(),
    );
  }

  RequirementResult _test(
      RequirementCategory c, String label, String? req, bool done) {
    if (req == null) {
      return RequirementResult(
          category: c,
          label: label,
          detail: 'No requirement',
          met: true,
          applicable: false);
    }
    return RequirementResult(
        category: c, label: label, detail: req, met: done);
  }

  List<RequirementResult> _fitness(Cadet cadet, Achievement a, DateTime now) {
    final out = <RequirementResult>[];
    final test = cadet.tests.hfz;
    if (a.hfzRequired) {
      final fresh = isFresh(test);
      final attained = fresh && (hfzAssessment(cadet)?.attained ?? false);
      String detail;
      if (test == null) {
        detail = 'Healthy Fitness Zone (<180 days) - no test recorded';
      } else if (!fresh) {
        detail = 'Healthy Fitness Zone - last test is older than 180 days';
      } else if (!attained) {
        detail = 'Healthy Fitness Zone - last test did not reach HFZ';
      } else {
        detail = 'Healthy Fitness Zone attained (${hfzDaysRemaining(cadet)} days left)';
      }
      out.add(RequirementResult(
          category: RequirementCategory.fitnessTest,
          label: 'Fitness test',
          detail: detail,
          met: attained));
    } else if (a.cpftAttemptRequired) {
      final ok = test != null && (a.number == 1 || isFresh(test));
      out.add(RequirementResult(
          category: RequirementCategory.fitnessTest,
          label: 'Fitness test',
          detail: a.number == 1
              ? 'Attempt CPFT as a baseline'
              : 'Attempt CPFT (<180 days)',
          met: ok));
    } else {
      out.add(const RequirementResult(
          category: RequirementCategory.fitnessTest,
          label: 'Fitness test',
          detail: 'No requirement',
          met: true,
          applicable: false));
    }
    return out;
  }

  int _countSinceTig(Cadet c, ActivityType type) => c.activities
      .where((x) => x.type == type && !x.date.isBefore(c.tigStart))
      .length;

  List<RequirementResult> _activities(Cadet cadet, Achievement a) {
    RequirementResult build(RequirementCategory cat, String label,
        ActivityType type, int required) {
      if (required == 0) {
        return RequirementResult(
            category: cat,
            label: label,
            detail: 'No requirement',
            met: true,
            applicable: false);
      }
      final have = _countSinceTig(cadet, type);
      return RequirementResult(
          category: cat,
          label: label,
          detail: '$have of $required completed this grade',
          met: have >= required);
    }

    return [
      build(RequirementCategory.fitnessActivity, 'Fitness activity',
          ActivityType.fitness, a.requiredFitnessActivities),
      build(RequirementCategory.characterActivity, 'Character activity',
          ActivityType.character, a.requiredCharacterActivities),
    ];
  }
}
