import 'isim_tarih_model.dart';

/// Normalized category keys used across the app
class EventCategories {
  static const String exams = 'Sınavlar';
  static const String registration = 'Kayıt';
  static const String lectures = 'Dersler';
  static const String applications = 'Başvuru';
  static const String holidays = 'Resmi Tatil';
  static const String summerSchool = 'Yaz Okulu';
  static const String other = 'Diğer';

  static const List<String> all = <String>[
    exams,
    registration,
    lectures,
    applications,
    holidays,
    summerSchool,
    other,
  ];
}

String deriveCategory(AcademicEvent event) {
  final title = event.title.toLowerCase();
  final period = event.period.toLowerCase();

  // Exams
  if (title.contains('sınav') ||
      title.contains('bütünleme') ||
      title.contains('tek ders')) {
    return EventCategories.exams;
  }

  // Registration / enrollment
  if (title.contains('kayıt') ||
      title.contains('ücret') ||
      title.contains('katkı payı')) {
    return EventCategories.registration;
  }

  // Lectures timeframe
  if (title.contains('derslerinin başlama') ||
      title.contains('derslerinin bitiş') ||
      title.contains('ders ekleme') ||
      title.contains('ders silme')) {
    return EventCategories.lectures;
  }

  // Applications and exemptions
  if (title.contains('başvuru') ||
      title.contains('muafiyet') ||
      title.contains('yeterlilik')) {
    return EventCategories.applications;
  }

  // Holidays by period or known holiday keywords
  if (event.period == 'Resmi Tatil' ||
      title.contains('tatil') ||
      title.contains('bayram') ||
      title.contains('günü')) {
    return EventCategories.holidays;
  }

  // Summer school by period or title
  if (event.period == 'Yaz' || title.contains('yaz okulu')) {
    return EventCategories.summerSchool;
  }

  // Fallback
  if (period.contains('diğer') || event.period == 'Diğer') {
    return EventCategories.other;
  }
  return EventCategories.other;
}
