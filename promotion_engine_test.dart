import 'package:cap_cadet_progress_tracker/models/achievement_catalog.dart';
import 'package:cap_cadet_progress_tracker/models/app_settings.dart';
import 'package:cap_cadet_progress_tracker/services/promotion_engine.dart';
import 'package:cap_cadet_progress_tracker/services/sample_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 6, 1);
  final jordan = buildSampleCadets(now).first; // 6 weeks in grade, all else done
  final next = nextAchievementFor(jordan)!;

  test('CAP mode requires 8 weeks TIG', () {
    final engine = PromotionEngine(settings: const AppSettings(), clock: () => now);
    expect(engine.tigWeeksFor(next), 8);
    expect(engine.isEligible(jordan, next), isFalse);
  });

  test('JROTC mode requires only 4 weeks TIG', () {
    final engine = PromotionEngine(
        settings: const AppSettings(jrotcMode: true), clock: () => now);
    expect(engine.tigWeeksFor(next), 4);
    expect(engine.isEligible(jordan, next), isTrue);
  });

  test('Expired HFZ blocks promotion', () {
    final sam = buildSampleCadets(now)[2];
    final engine = PromotionEngine(settings: const AppSettings(), clock: () => now);
    expect(engine.hfzAttained(sam), isFalse);
    expect(engine.isEligible(sam, nextAchievementFor(sam)!), isFalse);
  });
}
