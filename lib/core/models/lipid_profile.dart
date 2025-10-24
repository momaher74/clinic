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
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse('$v');
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse('$v');
    }

    final id = parseInt(map['id']);
    final patientId = parseInt(map['patient_id']) ?? 0;

    return LipidProfile(
      id: id,
      patientId: patientId,
      date: map['date'] as String? ?? '',
      cholest: parseDouble(map['cholest']),
      tg: parseDouble(map['tg']),
      ldl: parseDouble(map['ldl']),
      hdl: parseDouble(map['hdl']),
      vldl: parseDouble(map['vldl']),
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
