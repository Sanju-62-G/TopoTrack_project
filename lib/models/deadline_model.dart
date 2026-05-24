class Deadline {
  final String id;
  final String title;
  final String course;
  final DateTime dateTime;

  Deadline({
    required this.id,
    required this.title,
    required this.course,
    required this.dateTime,
  });

  // Factory to create from Firebase/JSON
  factory Deadline.fromMap(Map<String, dynamic> data, String id) {
    return Deadline(
      id: id,
      title: data['title'] ?? '',
      course: data['course'] ?? '',
      dateTime: DateTime.parse(data['dateTime']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'course': course,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  bool get isExpired => dateTime.isBefore(DateTime.now());
}
