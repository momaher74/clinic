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
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString().replaceAll(',', '.'));
    }

    String? parseString(dynamic v) {
      if (v == null) return null;
      return v.toString();
    }

    return CeliacDiseaseLabs(
      id: parseInt(map['id']),
      patientId: parseInt(map['patient_id']) ?? 0,
      date: parseString(map['date']) ?? '',
      agaIgA: parseString(map['aga_iga']),
      agaIgG: parseString(map['aga_igg']),
      emaIgA: parseString(map['ema_iga']),
      ttgIgA: parseString(map['ttg_iga']),
      ttgIgG: parseString(map['ttg_igg']),
      dgpIgA: parseString(map['dgp_iga']),
      dgpIgG: parseString(map['dgp_igg']),
      totalIgA: parseDouble(map['total_iga']),
      createdAt: parseString(map['created_at']) ?? DateTime.now().toIso8601String(),
    );
  }
}
