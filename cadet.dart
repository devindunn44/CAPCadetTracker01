import 'activity.dart';
import 'fitness_standards.dart';

/// Which kind of test/requirement a toggle applies to.
enum TestKind { leadership, aerospace, drill, special }

/// Completed requirements, keyed by the achievement `number` they satisfy.
class CadetTests {
  const CadetTests({
    this.leadership = const {},
    this.aerospace = const {},
    this.drill = const {},
    this.special = const {},
    this.hfz,
  });

  final Set<int> leadership;
  final Set<int> aerospace;
  final Set<int> drill;
  final Set<int> special;

  /// Most recent fitness (CPFT) test. HFZ status is derived from this using
  /// [FitnessStandards] and is only valid for 180 days.
  final FitnessResult? hfz;

  Set<int> setFor(TestKind kind) {
    switch (kind) {
      case TestKind.leadership:
        return leadership;
      case TestKind.aerospace:
        return aerospace;
      case TestKind.drill:
        return drill;
      case TestKind.special:
        return special;
    }
  }

  CadetTests copyWith({
    Set<int>? leadership,
    Set<int>? aerospace,
    Set<int>? drill,
    Set<int>? special,
    FitnessResult? hfz,
  }) =>
      CadetTests(
        leadership: leadership ?? this.leadership,
        aerospace: aerospace ?? this.aerospace,
        drill: drill ?? this.drill,
        special: special ?? this.special,
        hfz: hfz ?? this.hfz,
      );

  Map<String, dynamic> toJson() => {
        'leadership': leadership.toList(),
        'aerospace': aerospace.toList(),
        'drill': drill.toList(),
        'special': special.toList(),
        'hfz': hfz?.toJson(),
      };

  static Set<int> _ints(dynamic v) =>
      ((v as List?) ?? const []).map((e) => e as int).toSet();

  factory CadetTests.fromJson(Map<String, dynamic> json) => CadetTests(
        leadership: _ints(json['leadership']),
        aerospace: _ints(json['aerospace']),
        drill: _ints(json['drill']),
        special: _ints(json['special']),
        hfz: json['hfz'] == null
            ? null
            : FitnessResult.fromJson(json['hfz'] as Map<String, dynamic>),
      );
}

class Cadet {
  const Cadet({
    required this.id,
    required this.name,
    required this.joinDate,
    required this.dateOfBirth,
    required this.sex,
    required this.currentAchievement,
    required this.currentRank,
    required this.tigStart,
    this.tests = const CadetTests(),
    this.activities = const [],
  });

  final String id;
  final String name;
  final DateTime joinDate;
  final DateTime dateOfBirth;
  final Sex sex;

  /// `number` of the last achievement earned (0 = new cadet, none earned yet).
  final int currentAchievement;
  final String currentRank;

  /// Effective date of the last promotion (or join date for new cadets).
  final DateTime tigStart;
  final CadetTests tests;
  final List<Activity> activities;

  int ageOn(DateTime d) {
    var age = d.year - dateOfBirth.year;
    if (d.month < dateOfBirth.month ||
        (d.month == dateOfBirth.month && d.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  Cadet copyWith({
    String? name,
    int? currentAchievement,
    String? currentRank,
    DateTime? tigStart,
    CadetTests? tests,
    List<Activity>? activities,
  }) =>
      Cadet(
        id: id,
        name: name ?? this.name,
        joinDate: joinDate,
        dateOfBirth: dateOfBirth,
        sex: sex,
        currentAchievement: currentAchievement ?? this.currentAchievement,
        currentRank: currentRank ?? this.currentRank,
        tigStart: tigStart ?? this.tigStart,
        tests: tests ?? this.tests,
        activities: activities ?? this.activities,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'joinDate': joinDate.toIso8601String(),
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'sex': sex.name,
        'currentAchievement': currentAchievement,
        'currentRank': currentRank,
        'tigStart': tigStart.toIso8601String(),
        'tests': tests.toJson(),
        'activities': activities.map((a) => a.toJson()).toList(),
      };

  factory Cadet.fromJson(Map<String, dynamic> json) => Cadet(
        id: json['id'] as String,
        name: json['name'] as String,
        joinDate: DateTime.parse(json['joinDate'] as String),
        dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
        sex: Sex.values.byName(json['sex'] as String),
        currentAchievement: json['currentAchievement'] as int,
        currentRank: json['currentRank'] as String,
        tigStart: DateTime.parse(json['tigStart'] as String),
        tests: CadetTests.fromJson(json['tests'] as Map<String, dynamic>),
        activities: ((json['activities'] as List?) ?? const [])
            .map((e) => Activity.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
