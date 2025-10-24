class UrineAnalysis {
  final int? id;
  final int patientId;
  final String date;
  final String? note;
  final String createdAt;

  UrineAnalysis({
    this.id,
    required this.patientId,
    required this.date,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId.toString(),
      'date': date,
      'note': note ?? '',
      'created_at': createdAt,
    };
  }

  factory UrineAnalysis.fromMap(Map<String, dynamic> map) {
    return UrineAnalysis(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      patientId: map['patient_id'] is int ? map['patient_id'] : int.parse(map['patient_id'].toString()),
      date: map['date']?.toString() ?? '',
      note: map['note']?.toString().isEmpty ?? true ? null : map['note']?.toString(),
      createdAt: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
