import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/achievement.dart';
import '../models/achievement_catalog.dart';
import '../models/activity.dart';
import '../models/app_settings.dart';
import '../models/cadet.dart';
import '../models/fitness_standards.dart';
import 'cadet_service.dart';
import 'promotion_engine.dart';
import 'settings_service.dart';

/// Overridden in main() with the opened SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override sharedPreferencesProvider in main()'),
);

// ---------------- Settings ----------------
final settingsServiceProvider =
    Provider((ref) => SettingsService(ref.watch(sharedPreferencesProvider)));

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsServiceProvider).load();

  Future<void> setJrotcMode(bool value) async {
    state = state.copyWith(jrotcMode: value);
    await ref.read(settingsServiceProvider).save(state);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

// ---------------- Promotion engine ----------------
/// Rebuilds automatically whenever settings.jrotcMode changes, which is how
/// TIG switches between 8 weeks (CAP) and 4 weeks (JROTC).
final promotionEngineProvider = Provider<PromotionEngine>(
  (ref) => PromotionEngine(settings: ref.watch(settingsProvider)),
);

// ---------------- Cadets ----------------
final cadetServiceProvider =
    Provider((ref) => CadetService(ref.watch(sharedPreferencesProvider)));

final achievementsProvider =
    Provider<List<Achievement>>((ref) => capAchievements);

class CadetListNotifier extends Notifier<List<Cadet>> {
  @override
  List<Cadet> build() => ref.read(cadetServiceProvider).load();

  void _commit(List<Cadet> next) {
    state = next;
    ref.read(cadetServiceProvider).save(next);
  }

  void _update(String id, Cadet Function(Cadet) fn) =>
      _commit([for (final c in state) c.id == id ? fn(c) : c]);

  void add(Cadet cadet) => _commit([...state, cadet]);

  void remove(String id) => _commit(state.where((c) => c.id != id).toList());

  void toggleTest(String id, TestKind kind, int achievementNumber) {
    _update(id, (c) {
      final set = {...c.tests.setFor(kind)};
      if (!set.add(achievementNumber)) set.remove(achievementNumber);
      final t = c.tests;
      switch (kind) {
        case TestKind.leadership:
          return c.copyWith(tests: t.copyWith(leadership: set));
        case TestKind.aerospace:
          return c.copyWith(tests: t.copyWith(aerospace: set));
        case TestKind.drill:
          return c.copyWith(tests: t.copyWith(drill: set));
        case TestKind.special:
          return c.copyWith(tests: t.copyWith(special: set));
      }
    });
  }

  void recordFitness(String id, FitnessResult result) =>
      _update(id, (c) => c.copyWith(tests: c.tests.copyWith(hfz: result)));

  void addActivity(String id, Activity activity) =>
      _update(id, (c) => c.copyWith(activities: [...c.activities, activity]));

  void removeActivity(String id, String activityId) => _update(
      id,
      (c) => c.copyWith(
          activities: c.activities.where((a) => a.id != activityId).toList()));

  /// Awards [achievement]: updates rank and restarts the TIG clock.
  void promote(String id, Achievement achievement, {DateTime? effective}) =>
      _update(
          id,
          (c) => c.copyWith(
                currentAchievement: achievement.number,
                currentRank: achievement.rank,
                tigStart: effective ?? DateTime.now(),
              ));
}

final cadetListProvider =
    NotifierProvider<CadetListNotifier, List<Cadet>>(CadetListNotifier.new);

final cadetByIdProvider = Provider.family<Cadet?, String>((ref, id) {
  for (final c in ref.watch(cadetListProvider)) {
    if (c.id == id) return c;
  }
  return null;
});
