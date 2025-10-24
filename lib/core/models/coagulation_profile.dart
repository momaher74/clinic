class CoagulationProfile {
  final int? id;
  final int patientId;
  final String date;
  final double? pt;
  final double? ptt;
  final double? pc;
  final double? inr;
  final String createdAt;

  CoagulationProfile({
    this.id,
    required this.patientId,
    required this.date,
    this.pt,
    this.ptt,
    this.pc,
    this.inr,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date': date,
      'pt': pt,
      'ptt': ptt,
      'pc': pc,
      'inr': inr,
      'created_at': createdAt,
    };
  }

  factory CoagulationProfile.fromMap(Map<String, dynamic> map) {
    double? parseNullableDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return double.tryParse(s.replaceAll(',', '.'));
    }

    return CoagulationProfile(
      id: (map['id'] is int) ? map['id'] as int : (map['id'] is String ? int.tryParse(map['id']) : null),
      patientId: (map['patient_id'] is int) ? map['patient_id'] as int : int.tryParse(map['patient_id']?.toString() ?? '') ?? 0,
      date: map['date']?.toString() ?? '',
      pt: parseNullableDouble(map['pt']),
      ptt: parseNullableDouble(map['ptt']),
      pc: parseNullableDouble(map['pc']),
      inr: parseNullableDouble(map['inr']),
      createdAt: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
