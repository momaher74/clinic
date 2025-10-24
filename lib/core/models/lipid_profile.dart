class LipidProfile {
  final int? id;
  final int patientId;
  final String date;
  final double? cholest;
  final double? tg;
  final double? ldl;
  final double? hdl;
  final double? vldl;
  final String createdAt;

  LipidProfile({
    this.id,
    required this.patientId,
    required this.date,
    this.cholest,
    this.tg,
    this.ldl,
    this.hdl,
    this.vldl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date': date,
      'cholest': cholest,
      'tg': tg,
      'ldl': ldl,
      'hdl': hdl,
      'vldl': vldl,
      'created_at': createdAt,
    };
  }

  factory LipidProfile.fromMap(Map<String, dynamic> map) {
    return LipidProfile(
      id: map['id'],
      patientId: map['patient_id'],
      date: map['date'],
      cholest: map['cholest'] != null ? (map['cholest'] as num).toDouble() : null,
      tg: map['tg'] != null ? (map['tg'] as num).toDouble() : null,
      ldl: map['ldl'] != null ? (map['ldl'] as num).toDouble() : null,
      hdl: map['hdl'] != null ? (map['hdl'] as num).toDouble() : null,
      vldl: map['vldl'] != null ? (map['vldl'] as num).toDouble() : null,
      createdAt: map['created_at'],
    );
  }
}
