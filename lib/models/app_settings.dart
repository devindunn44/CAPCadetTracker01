class AppSettings {
  const AppSettings({this.jrotcMode = false});

  /// false = CAP 8-week time-in-grade, true = JROTC 4-week time-in-grade.
  final bool jrotcMode;

  static const int capTigWeeks = 8;
  static const int jrotcTigWeeks = 4;

  int get tigWeeks => jrotcMode ? jrotcTigWeeks : capTigWeeks;

  AppSettings copyWith({bool? jrotcMode}) =>
      AppSettings(jrotcMode: jrotcMode ?? this.jrotcMode);

  Map<String, dynamic> toJson() => {'jrotcMode': jrotcMode};

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      AppSettings(jrotcMode: json['jrotcMode'] as bool? ?? false);
}
