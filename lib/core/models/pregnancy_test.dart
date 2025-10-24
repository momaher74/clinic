class PregnancyTest {
  final int? id;
  final int patientId;
  final String date;
  final double? bhcg;
  final String createdAt;

  PregnancyTest({
    this.id,
    required this.patientId,
    required this.date,
    this.bhcg,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId.toString(),
      'date': date,
      'bhcg': bhcg?.toString() ?? '',
      'created_at': createdAt,
    };
  }

  factory PregnancyTest.fromMap(Map<String, dynamic> map) {
    return PregnancyTest(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      patientId: map['patient_id'] is int ? map['patient_id'] : int.parse(map['patient_id'].toString()),
      date: map['date']?.toString() ?? '',
      bhcg: map['bhcg'] != null && map['bhcg'].toString().isNotEmpty ? double.tryParse(map['bhcg'].toString()) : null,
      createdAt: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
