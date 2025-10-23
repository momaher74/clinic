class DiseaseStatus {
  int? id;
  int patientId;
  bool dm;
  bool htn;
  String? notes;
  String createdAt;

  DiseaseStatus({
    this.id,
    required this.patientId,
    required this.dm,
    required this.htn,
    this.notes,
    required this.createdAt,
  });

  factory DiseaseStatus.fromMap(Map<String, dynamic> m) => DiseaseStatus(
        id: m['id'] as int?,
        patientId: int.tryParse(m['patient_id']?.toString() ?? '') ?? 0,
        dm: (m['dm']?.toString() ?? '0') == '1',
        htn: (m['htn']?.toString() ?? '0') == '1',
        notes: m['notes']?.toString(),
        createdAt: m['created_at']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'patient_id': patientId.toString(),
        'dm': dm ? '1' : '0',
        'htn': htn ? '1' : '0',
        'notes': notes,
        'created_at': createdAt,
      };
}
