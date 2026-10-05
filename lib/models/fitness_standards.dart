/// Presidential Youth Fitness Program Healthy Fitness Zone (HFZ) standards,
/// transcribed from the Cadet Super Chart (CAP VA 60-100, May 2025).
/// HFZ = meet the aerobic standard (PACER *or* 1-mile run) PLUS 2 of 3 of
/// curl-ups, push-ups, sit & reach.
enum Sex { male, female }

class AgeStandard {
  const AgeStandard({
    required this.pacer,
    required this.mileSeconds,
    required this.curlUps,
    required this.pushUps,
    required this.sitReach,
  });

  final int pacer; // laps (minimum)
  final int mileSeconds; // maximum time
  final int curlUps; // minimum
  final int pushUps; // minimum
  final double sitReach; // inches (minimum)
}

class FitnessResult {
  const FitnessResult({
    required this.date,
    this.pacer,
    this.mileSeconds,
    this.curlUps,
    this.pushUps,
    this.sitReach,
  });

  final DateTime date;
  final int? pacer;
  final int? mileSeconds;
  final int? curlUps;
  final int? pushUps;
  final double? sitReach;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'pacer': pacer,
        'mileSeconds': mileSeconds,
        'curlUps': curlUps,
        'pushUps': pushUps,
        'sitReach': sitReach,
      };

  factory FitnessResult.fromJson(Map<String, dynamic> json) => FitnessResult(
        date: DateTime.parse(json['date'] as String),
        pacer: json['pacer'] as int?,
        mileSeconds: json['mileSeconds'] as int?,
        curlUps: json['curlUps'] as int?,
        pushUps: json['pushUps'] as int?,
        sitReach: (json['sitReach'] as num?)?.toDouble(),
      );
}

class HfzAssessment {
  const HfzAssessment({
    required this.aerobic,
    required this.curlUps,
    required this.pushUps,
    required this.sitReach,
  });

  final bool aerobic;
  final bool curlUps;
  final bool pushUps;
  final bool sitReach;

  int get secondaryMet => [curlUps, pushUps, sitReach].where((e) => e).length;
  bool get attained => aerobic && secondaryMet >= 2;
}

class FitnessStandards {
  FitnessStandards._();

  static const int minAge = 10;
  static const int maxAge = 18; // 18 means "18+"

  // Index 0 = age 10 ... index 8 = age 18+
  static const Map<Sex, List<int>> _pacer = {
    Sex.male: [17, 20, 23, 29, 36, 42, 47, 50, 54],
    Sex.female: [17, 20, 23, 25, 27, 30, 32, 35, 38],
  };
  static const Map<Sex, List<int>> _mileSeconds = {
    Sex.male: [690, 670, 640, 586, 562, 544, 522, 502, 484],
    Sex.female: [690, 670, 640, 620, 609, 598, 586, 574, 562],
  };
  static const Map<Sex, List<int>> _curlUps = {
    Sex.male: [12, 15, 18, 21, 24, 24, 24, 24, 24],
    Sex.female: [12, 15, 18, 18, 18, 18, 18, 18, 18],
  };
  static const Map<Sex, List<int>> _pushUps = {
    Sex.male: [7, 8, 10, 12, 14, 16, 18, 18, 18],
    Sex.female: [7, 7, 7, 7, 7, 7, 7, 7, 7],
  };
  static const Map<Sex, List<double>> _sitReach = {
    Sex.male: [8, 8, 8, 8, 8, 8, 8, 8, 8],
    Sex.female: [9, 10, 10, 10, 10, 12, 12, 12, 12],
  };

  static AgeStandard forAge(Sex sex, int age) {
    final i = age.clamp(minAge, maxAge).toInt() - minAge;
    return AgeStandard(
      pacer: _pacer[sex]![i],
      mileSeconds: _mileSeconds[sex]![i],
      curlUps: _curlUps[sex]![i],
      pushUps: _pushUps[sex]![i],
      sitReach: _sitReach[sex]![i],
    );
  }

  static HfzAssessment assess(FitnessResult r, Sex sex, int age) {
    final s = forAge(sex, age);
    final pacerOk = r.pacer != null && r.pacer! >= s.pacer;
    final mileOk = r.mileSeconds != null && r.mileSeconds! <= s.mileSeconds;
    return HfzAssessment(
      aerobic: pacerOk || mileOk,
      curlUps: r.curlUps != null && r.curlUps! >= s.curlUps,
      pushUps: r.pushUps != null && r.pushUps! >= s.pushUps,
      sitReach: r.sitReach != null && r.sitReach! >= s.sitReach,
    );
  }

  static String formatMile(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  /// Parses "mm:ss" into seconds. Returns null if invalid.
  static int? parseMile(String text) {
    final parts = text.trim().split(':');
    if (parts.length != 2) return null;
    final m = int.tryParse(parts[0]);
    final s = int.tryParse(parts[1]);
    if (m == null || s == null || s < 0 || s > 59) return null;
    return m * 60 + s;
  }
}
