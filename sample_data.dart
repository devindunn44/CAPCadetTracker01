import '../models/achievement.dart';
import '../models/achievement_catalog.dart';
import '../models/activity.dart';
import '../models/cadet.dart';
import '../models/fitness_standards.dart';

/// Three example achievements (the first three steps of the catalog).
List<Achievement> get sampleAchievements => capAchievements.take(3).toList();

/// Example HFZ standards for a 14-year-old female and a 17-year-old male.
AgeStandard get sampleHfzFemale14 => FitnessStandards.forAge(Sex.female, 14);
AgeStandard get sampleHfzMale17 => FitnessStandards.forAge(Sex.male, 17);

DateTime _weeksAgo(DateTime now, int w) => now.subtract(Duration(days: w * 7));
DateTime _daysAgo(DateTime now, int d) => now.subtract(Duration(days: d));

List<Cadet> buildSampleCadets(DateTime now) {
  return [
    // Jordan: all Ach. 2 requirements done, 6 weeks TIG -> eligible in JROTC
    // mode (4 wks) but not in CAP mode (8 wks).
    Cadet(
      id: 'cadet-1',
      name: 'Jordan Ellis',
      joinDate: _weeksAgo(now, 22),
      dateOfBirth: DateTime(now.year - 15, 3, 12),
      sex: Sex.male,
      currentAchievement: 1,
      currentRank: 'C/Amn',
      tigStart: _weeksAgo(now, 6),
      tests: CadetTests(
        leadership: {1, 2},
        aerospace: {2},
        drill: {1, 2},
        special: {1, 2},
        hfz: FitnessResult(
            date: _daysAgo(now, 40), pacer: 20, curlUps: 18, pushUps: 9, sitReach: 7),
      ),
      activities: [
        Activity(id: 'a1', name: '5K fun run', type: ActivityType.fitness, date: _weeksAgo(now, 3)),
        Activity(id: 'a2', name: 'Monthly character forum', type: ActivityType.character, date: _weeksAgo(now, 2)),
      ],
    ),
    // Maya: Wright Bros. earned 3 weeks ago, HFZ attained, working toward Ach. 4.
    Cadet(
      id: 'cadet-2',
      name: 'Maya Chen',
      joinDate: _weeksAgo(now, 60),
      dateOfBirth: DateTime(now.year - 14, 8, 2),
      sex: Sex.female,
      currentAchievement: 4,
      currentRank: 'C/SSgt',
      tigStart: _weeksAgo(now, 3),
      tests: CadetTests(
        leadership: {1, 2, 3, 4, 5},
        aerospace: {2, 3},
        drill: {1, 2, 3, 4, 5},
        special: {1, 2},
        hfz: FitnessResult(
            date: _daysAgo(now, 20), pacer: 30, curlUps: 18, pushUps: 7, sitReach: 10),
      ),
      activities: [
        Activity(id: 'b1', name: 'Squadron PT night', type: ActivityType.fitness, date: _daysAgo(now, 10)),
      ],
    ),
    // Sam: Ach. 8 earned 10 weeks ago; HFZ test is expired, missing encampment.
    Cadet(
      id: 'cadet-3',
      name: 'Sam Patel',
      joinDate: _weeksAgo(now, 100),
      dateOfBirth: DateTime(now.year - 17, 1, 20),
      sex: Sex.male,
      currentAchievement: 9,
      currentRank: 'C/CMSgt',
      tigStart: _weeksAgo(now, 10),
      tests: CadetTests(
        leadership: {1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
        aerospace: {2, 3, 5, 6, 7, 8, 9},
        drill: {1, 2, 3, 4, 5, 6, 7, 8, 9},
        special: {1, 2, 9},
        hfz: FitnessResult(
            date: _daysAgo(now, 200), pacer: 52, curlUps: 24, pushUps: 20, sitReach: 9),
      ),
      activities: [
        Activity(id: 'c1', name: 'Cross-country meet', type: ActivityType.fitness, date: _weeksAgo(now, 4)),
      ],
    ),
  ];
}
