class Achievement {
  const Achievement({
    required this.number,
    required this.name,
    required this.rank,
    this.namesake,
    this.leadership,
    this.aerospace,
    this.drill,
    this.hfzRequired = false,
    this.cpftAttemptRequired = false,
    this.requiredFitnessActivities = 1,
    this.requiredCharacterActivities = 1,
    this.special,
    this.tigWeeks = 8,
  });

  /// Sequential promotion step, 1..21 (awards are steps too, e.g. 4 = Wright Bros.).
  final int number;
  final String name; // e.g. "Achievement 1", "Wright Brothers Award"
  final String rank; // rank earned on promotion, e.g. "C/Amn"
  final String? namesake;

  /// Requirement descriptions. `null` means "No requirement".
  final String? leadership;
  final String? aerospace;
  final String? drill;

  /// Must have attained the Healthy Fitness Zone within the last 180 days.
  final bool hfzRequired;

  /// Must have attempted a CPFT (baseline for Ach. 1; within 180 days for 2-3).
  final bool cpftAttemptRequired;

  final int requiredFitnessActivities;
  final int requiredCharacterActivities;
  int get requiredActivities =>
      requiredFitnessActivities + requiredCharacterActivities;

  /// Extra one-off requirement (encampment, leadership academy, etc.).
  final String? special;

  /// Minimum time-in-grade in CAP mode. JROTC mode caps this at 4 weeks.
  final int tigWeeks;
}
