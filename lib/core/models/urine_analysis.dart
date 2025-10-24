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
      'id': id,
      'patient_id': patientId,
      'date': date,
      'note': note,
      'created_at': createdAt,
    };
  }

  factory UrineAnalysis.fromMap(Map<String, dynamic> map) {
    return UrineAnalysis(
      id: map['id'],
      patientId: map['patient_id'],
      date: map['date'],
      note: map['note'],
      createdAt: map['created_at'],
    );
  }
}
