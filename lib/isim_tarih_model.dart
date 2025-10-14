class AcademicEvent {
  final String title;
  final String period; // "Güz", "Bahar", "Yaz" veya "Resmi Tatil" vb.
  final DateTime start;
  final DateTime end;
  final String? notes;

  AcademicEvent({
    required this.title,
    required this.period,
    required this.start,
    required this.end,
    this.notes,
  });

  @override
  String toString() {
    final startStr =
        "${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
    final endStr =
        "${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";
    return "$period | $title : $startStr -> $endStr${notes != null ? " (${notes})" : ""}";
  }
}
