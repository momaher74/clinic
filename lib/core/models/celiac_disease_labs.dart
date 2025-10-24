class CeliacDiseaseLabs {
  final int? id;
  final int patientId;
  final String date;
  final String? agaIgA;
  final String? agaIgG;
  final String? emaIgA;
  final String? ttgIgA;
  final String? ttgIgG;
  final String? dgpIgA;
  final String? dgpIgG;
  final double? totalIgA;
  final String createdAt;

  CeliacDiseaseLabs({
    this.id,
    required this.patientId,
    required this.date,
    this.agaIgA,
    this.agaIgG,
    this.emaIgA,
    this.ttgIgA,
    this.ttgIgG,
    this.dgpIgA,
    this.dgpIgG,
    this.totalIgA,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date': date,
      'aga_iga': agaIgA,
      'aga_igg': agaIgG,
      'ema_iga': emaIgA,
      'ttg_iga': ttgIgA,
      'ttg_igg': ttgIgG,
      'dgp_iga': dgpIgA,
      'dgp_igg': dgpIgG,
      'total_iga': totalIgA,
      'created_at': createdAt,
    };
  }

  factory CeliacDiseaseLabs.fromMap(Map<String, dynamic> map) {
    return CeliacDiseaseLabs(
      id: map['id'],
      patientId: map['patient_id'],
      date: map['date'],
      agaIgA: map['aga_iga'],
      agaIgG: map['aga_igg'],
      emaIgA: map['ema_iga'],
      ttgIgA: map['ttg_iga'],
      ttgIgG: map['ttg_igg'],
      dgpIgA: map['dgp_iga'],
      dgpIgG: map['dgp_igg'],
      totalIgA: map['total_iga'] != null ? (map['total_iga'] as num).toDouble() : null,
      createdAt: map['created_at'],
    );
  }
}
