import 'dart:convert';

class PrescriptionItem {
  final String id;
  final String date; // user-specified date (ISO or display string)
  final String drug;
  final String dose;
  final String frequency;
  final String days;
  final int? patientId;
  final String imagePath;
  final int createdAt;

  PrescriptionItem({
    required this.id,
    required this.date,
    required this.drug,
    required this.dose,
    required this.frequency,
    required this.days,
    this.patientId,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'drug': drug,
    'dose': dose,
    'frequency': frequency,
    'days': days,
    'patientId': patientId,
    'imagePath': imagePath,
    'createdAt': createdAt,
  };

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) =>
      PrescriptionItem(
        id: json['id'] as String,
        date: (json['date'] as String?) ?? '',
        drug: (json['drug'] as String?) ?? '',
        dose: (json['dose'] as String?) ?? '',
        frequency: (json['frequency'] as String?) ?? '',
        days: (json['days'] as String?) ?? '',
        patientId: json['patientId'] is int
            ? (json['patientId'] as int)
            : (json['patientId'] is String
                  ? int.tryParse(json['patientId'] as String)
                  : null),
        imagePath: (json['imagePath'] as String?) ?? '',
        createdAt: (json['createdAt'] as num).toInt(),
      );

  static List<PrescriptionItem> listFromJson(String jsonStr) {
    final decoded = json.decode(jsonStr) as List<dynamic>;
    return decoded
        .map((e) => PrescriptionItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<PrescriptionItem> items) =>
      json.encode(items.map((e) => e.toJson()).toList());
}
