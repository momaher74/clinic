class Drug {
  int? id;
  int patientId;
  String name;
  String dose;
  String frequency;
  int durationDays;
  String createdAt;

  Drug({
    this.id,
    required this.patientId,
    required this.name,
    required this.dose,
    required this.frequency,
    required this.durationDays,
    required this.createdAt,
  });

  factory Drug.fromMap(Map<String, dynamic> m) => Drug(
        id: m['id'] as int?,
        patientId: int.tryParse(m['patient_id']?.toString() ?? '') ?? 0,
        name: m['name']?.toString() ?? '',
        dose: m['dose']?.toString() ?? '',
        frequency: m['frequency']?.toString() ?? '',
        durationDays: int.tryParse(m['duration_days']?.toString() ?? '') ?? 0,
        createdAt: m['created_at']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'patient_id': patientId.toString(),
        'name': name,
        'dose': dose,
        'frequency': frequency,
        'duration_days': durationDays.toString(),
        'created_at': createdAt,
      };
}
