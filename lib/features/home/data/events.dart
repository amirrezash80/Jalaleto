class Event {
  final String title;
  final DateTime dateTime;
  final int daysBeforeToRemind;
  final bool remindByEmail;
  final int repeatInterval;
  final int priorityLevel;
  final String notes;

  Event({
    required this.title,
    required this.dateTime,
    required this.daysBeforeToRemind,
    required this.remindByEmail,
    required this.repeatInterval,
    required this.priorityLevel,
    required this.notes,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'] ?? '',
      dateTime: DateTime.parse(json['dateTime'] ?? ''),
      daysBeforeToRemind: json['daysBeforeToRemind'] ?? 0,
      remindByEmail: json['remindByEmail'] ?? false,
      repeatInterval: json['repeatInterval'] ?? 1,
      priorityLevel: json['priorityLevel'] ?? 0,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'daysBeforeToRemind': daysBeforeToRemind,
      'remindByEmail': remindByEmail,
      'repeatInterval': repeatInterval,
      'priorityLevel': priorityLevel,
      'notes': notes,
    };
  }
}
