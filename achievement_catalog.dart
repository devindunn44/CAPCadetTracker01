import 'achievement.dart';
import 'cadet.dart';

const String _sda = 'Staff Duty Analysis (service, writing, presentation)';

/// Full CAP promotion ladder from the Cadet Super Chart (VA 60-100, May 2025).
const List<Achievement> capAchievements = [
  Achievement(
    number: 1, name: 'Achievement 1', rank: 'C/Amn',
    namesake: 'Maj. Gen. John F. Curry',
    leadership: 'L2L Ch. 1 test', drill: 'Drill & Ceremonies test',
    cpftAttemptRequired: true,
    requiredFitnessActivities: 0, requiredCharacterActivities: 0,
    special: 'Cadet Welcome Course & Cadet Wingman Course', tigWeeks: 3,
  ),
  Achievement(
    number: 2, name: 'Achievement 2', rank: 'C/A1C',
    namesake: 'Gen. Hap Arnold',
    leadership: 'L2L Ch. 2 test', drill: 'Drill & Ceremonies test',
    aerospace: 'Aerospace Dimensions Module 1 test',
    cpftAttemptRequired: true, special: 'Properly wear the uniform',
  ),
  Achievement(
    number: 3, name: 'Achievement 3', rank: 'C/SrA',
    namesake: 'Col. Mary Feik',
    leadership: 'L2L Ch. 3 test', drill: 'Drill & Ceremonies test',
    aerospace: 'Aerospace Dimensions Module 2 test',
    cpftAttemptRequired: true,
  ),
  Achievement(
    number: 4, name: 'Wright Brothers Award', rank: 'C/SSgt',
    namesake: 'Orville & Wilbur Wright',
    leadership: 'L2L Ch. 1-3 comprehensive closed-book exam',
    drill: 'Comprehensive Drill & Ceremonies test',
    hfzRequired: true, requiredCharacterActivities: 0,
  ),
  Achievement(
    number: 5, name: 'Achievement 4', rank: 'C/TSgt',
    namesake: 'Capt. Eddie Rickenbacker',
    leadership: 'L2L Ch. 4 test', drill: 'Drill & Ceremonies test',
    aerospace: 'Aerospace Dimensions Module 3 test', hfzRequired: true,
  ),
  Achievement(
    number: 6, name: 'Achievement 5', rank: 'C/MSgt',
    leadership: 'L2L Ch. 5 test', drill: 'Drill & Ceremonies test',
    aerospace: 'Aerospace Dimensions Module 4 test', hfzRequired: true,
  ),
  Achievement(
    number: 7, name: 'Achievement 6', rank: 'C/SMSgt',
    namesake: 'Gen. Jimmy Doolittle',
    leadership: 'L2L Ch. 6 test', drill: 'Drill & Ceremonies test',
    aerospace: 'Aerospace Dimensions Module 5 test', hfzRequired: true,
  ),
  Achievement(
    number: 8, name: 'Achievement 7', rank: 'C/CMSgt',
    namesake: 'Dr. Robert H. Goddard',
    leadership: 'L2L Ch. 7 test', drill: 'Drill & Ceremonies test',
    aerospace: 'Aerospace Dimensions Module 6 test', hfzRequired: true,
  ),
  Achievement(
    number: 9, name: 'Achievement 8', rank: 'C/CMSgt',
    namesake: 'Neil Armstrong',
    leadership: 'L2L Ch. 8 test', drill: 'Drill & Ceremonies test',
    aerospace: 'Aerospace Dimensions Module 7 test', hfzRequired: true,
    special: 'Speech & Essay',
  ),
  Achievement(
    number: 10, name: 'Billy Mitchell Award', rank: 'C/2d Lt',
    namesake: 'Brig. Gen. Billy Mitchell',
    leadership: 'L2L Ch. 4-8 comprehensive closed-book exam',
    aerospace: 'Aerospace Dimensions Modules 1-7 comprehensive exam',
    hfzRequired: true, requiredCharacterActivities: 0,
    special: 'Graduate from Encampment',
  ),
  Achievement(
    number: 11, name: 'Achievement 9', rank: 'C/2d Lt',
    leadership: 'L2L Ch. 9 test + $_sda',
    aerospace: 'Journey of Flight Ch. 1, 7, 8 test', hfzRequired: true,
  ),
  Achievement(
    number: 12, name: 'Achievement 10', rank: 'C/1st Lt',
    namesake: '1st Lt. Willa Brown',
    leadership: 'L2L Ch. 10 test + $_sda',
    aerospace: 'Journey of Flight Ch. 2, 9, 10 test', hfzRequired: true,
  ),
  Achievement(
    number: 13, name: 'Achievement 11', rank: 'C/1st Lt',
    leadership: 'L2L Ch. 11 test + $_sda',
    aerospace: 'Journey of Flight Ch. 3, 18, 19 test', hfzRequired: true,
  ),
  Achievement(
    number: 14, name: 'Amelia Earhart Award', rank: 'C/Capt',
    namesake: 'Amelia Earhart',
    leadership: 'L2L Ch. 9-11 comprehensive closed-book exam',
    hfzRequired: true, requiredCharacterActivities: 0,
  ),
  Achievement(
    number: 15, name: 'Achievement 12', rank: 'C/Capt',
    leadership: 'L2L Ch. 12 test + $_sda', hfzRequired: true,
  ),
  Achievement(
    number: 16, name: 'Achievement 13', rank: 'C/Capt',
    leadership: 'L2L Ch. 13 test + $_sda', hfzRequired: true,
  ),
  Achievement(
    number: 17, name: 'Achievement 14', rank: 'C/Maj',
    namesake: 'Col. George Boyd',
    leadership: 'L2L Ch. 14 test + $_sda',
    aerospace: 'Journey of Flight Ch. 4, 21, 23 test', hfzRequired: true,
  ),
  Achievement(
    number: 18, name: 'Achievement 15', rank: 'C/Maj',
    namesake: 'Dr. Sally Ride',
    leadership: 'L2L Ch. 15 test + $_sda',
    aerospace: 'Journey of Flight Ch. 5, 24, 25 test', hfzRequired: true,
  ),
  Achievement(
    number: 19, name: 'Achievement 16', rank: 'C/Maj',
    leadership: 'L2L Ch. 16 test + $_sda',
    aerospace: 'Journey of Flight Ch. 6, 26, 27 test', hfzRequired: true,
  ),
  Achievement(
    number: 20, name: 'Ira C. Eaker Award', rank: 'C/Lt Col',
    namesake: 'Gen. Ira C. Eaker',
    leadership: 'Speech & Essay', hfzRequired: true,
    requiredCharacterActivities: 0,
    special: 'Graduate from a Leadership Academy',
  ),
  Achievement(
    number: 21, name: 'Gen. Carl A. Spaatz Award', rank: 'C/Col',
    namesake: 'Gen. Carl A. Spaatz',
    leadership: 'L2L Vols. 1-4 comprehensive closed-book exam',
    aerospace: 'Journey of Flight all chapters comprehensive exam',
    requiredFitnessActivities: 0, requiredCharacterActivities: 0,
    special: 'USAFA Candidate Fitness Assessment & character essay exam',
  ),
];

/// The achievement a cadet is currently working toward (null = Spaatz earned).
Achievement? nextAchievementFor(Cadet cadet) {
  for (final a in capAchievements) {
    if (a.number == cadet.currentAchievement + 1) return a;
  }
  return null;
}
