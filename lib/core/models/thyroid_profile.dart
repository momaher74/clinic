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
    return ThyroidProfile(
      id: map['id'],
      patientId: map['patient_id'],
      date: map['date'],
      tsh: map['tsh'] != null ? (map['tsh'] as num).toDouble() : null,
      ft3: map['ft3'] != null ? (map['ft3'] as num).toDouble() : null,
      ft4: map['ft4'] != null ? (map['ft4'] as num).toDouble() : null,
      antiTpoAb: map['anti_tpo_ab'] != null ? (map['anti_tpo_ab'] as num).toDouble() : null,
      antiTgAb: map['anti_tg_ab'] != null ? (map['anti_tg_ab'] as num).toDouble() : null,
      antiTshrAb: map['anti_tshr_ab'] != null ? (map['anti_tshr_ab'] as num).toDouble() : null,
      createdAt: map['created_at'],
    );
  }
}
