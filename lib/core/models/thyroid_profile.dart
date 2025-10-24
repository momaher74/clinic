class ThyroidProfile {
  final int? id;
  final int patientId;
  final String date;
  final double? tsh;
  final double? ft3;
  final double? ft4;
  final double? antiTpoAb;
  final double? antiTgAb;
  final double? antiTshrAb;
  final String createdAt;

  ThyroidProfile({
    this.id,
    required this.patientId,
    required this.date,
    this.tsh,
    this.ft3,
    this.ft4,
    this.antiTpoAb,
    this.antiTgAb,
    this.antiTshrAb,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date': date,
      'tsh': tsh,
      'ft3': ft3,
      'ft4': ft4,
      'anti_tpo_ab': antiTpoAb,
      'anti_tg_ab': antiTgAb,
      'anti_tshr_ab': antiTshrAb,
      'created_at': createdAt,
    };
  }

  factory ThyroidProfile.fromMap(Map<String, dynamic> map) {
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

    return ThyroidProfile(
      id: id,
      patientId: patientId,
      date: map['date'] as String? ?? '',
      tsh: parseDouble(map['tsh']),
      ft3: parseDouble(map['ft3']),
      ft4: parseDouble(map['ft4']),
      antiTpoAb: parseDouble(map['anti_tpo_ab']),
      antiTgAb: parseDouble(map['anti_tg_ab']),
      antiTshrAb: parseDouble(map['anti_tshr_ab']),
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
