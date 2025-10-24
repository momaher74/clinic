class PancreaticEnzymes {
  final int? id;
  final int patientId;
  final String date;
  final double? sAmylase;
  final double? sLipase;
  final String createdAt;

  PancreaticEnzymes({
    this.id,
    required this.patientId,
    required this.date,
    this.sAmylase,
    this.sLipase,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date': date,
      's_amylase': sAmylase,
      's_lipase': sLipase,
      'created_at': createdAt,
    };
  }

  factory PancreaticEnzymes.fromMap(Map<String, dynamic> map) {
    return PancreaticEnzymes(
      id: map['id'],
      patientId: map['patient_id'],
      date: map['date'],
      sAmylase: map['s_amylase'] != null ? (map['s_amylase'] as num).toDouble() : null,
      sLipase: map['s_lipase'] != null ? (map['s_lipase'] as num).toDouble() : null,
      createdAt: map['created_at'],
    );
  }
}
