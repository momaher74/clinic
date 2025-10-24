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
    double? parseNullableDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return double.tryParse(s.replaceAll(',', '.'));
    }

    int? parseNullableInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return PancreaticEnzymes(
      id: parseNullableInt(map['id']),
      patientId: parseNullableInt(map['patient_id']) ?? 0,
      date: map['date']?.toString() ?? '',
      sAmylase: parseNullableDouble(map['s_amylase']),
      sLipase: parseNullableDouble(map['s_lipase']),
      createdAt: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
