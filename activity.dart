enum ActivityType { fitness, character, other }

class Activity {
  const Activity({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
  });

  final String id;
  final String name;
  final ActivityType type;
  final DateTime date;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'date': date.toIso8601String(),
      };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        name: json['name'] as String,
        type: ActivityType.values.byName(json['type'] as String),
        date: DateTime.parse(json['date'] as String),
      );
}
