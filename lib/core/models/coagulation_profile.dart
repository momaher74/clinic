class CoagulationProfile {
  final int? id;
  final int patientId;
  final String date;
  final String pt;
  final String ptt;
  final String pc;
  final String inr;
  final String createdAt;

  CoagulationProfile({
    this.id,
    required this.patientId,
    this.date = '',
    this.pt = '',
    this.ptt = '',
    this.pc = '',
    this.inr = '',
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

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
    return CoagulationProfile(
      id: map['id'] as int?,
      patientId: map['patient_id'] as int,
      date: map['date'] as String? ?? '',
      pt: map['pt'] as String? ?? '',
      ptt: map['ptt'] as String? ?? '',
      pc: map['pc'] as String? ?? '',
      inr: map['inr'] as String? ?? '',
      createdAt: map['created_at'] as String?,
    );
  }
}
