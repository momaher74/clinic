class PatientHistory {
  int? id;
  int patientId;
  String occupation;
  bool alcohol;
  bool offspring; // changed to boolean
  bool smoking;
  bool maritalStatus; // changed to boolean (married: true/false)
  bool allergy; // boolean
  bool bilharziasis;
  bool hepatitis;
  String createdAt;

  PatientHistory({
    this.id,
    required this.patientId,
    required this.occupation,
    required this.alcohol,
    required this.offspring,
    required this.smoking,
    required this.maritalStatus,
    required this.allergy,
    required this.bilharziasis,
    required this.hepatitis,
    required this.createdAt,
  });

  factory PatientHistory.fromMap(Map<String, dynamic> m) => PatientHistory(
        id: m['id'] as int?,
        patientId: int.tryParse(m['patient_id']?.toString() ?? '') ?? 0,
        occupation: m['occupation']?.toString() ?? '',
        alcohol: (m['alcohol']?.toString() ?? '0') == '1',
        offspring: (m['offspring']?.toString() ?? '0') == '1',
        smoking: (m['smoking']?.toString() ?? '0') == '1',
        maritalStatus: (m['marital_status']?.toString() ?? '0') == '1',
        allergy: (m['allergy']?.toString() ?? '0') == '1',
        bilharziasis: (m['bilharziasis']?.toString() ?? '0') == '1',
        hepatitis: (m['hepatitis']?.toString() ?? '0') == '1',
        createdAt: m['created_at']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'patient_id': patientId.toString(),
        'occupation': occupation,
        'alcohol': alcohol ? '1' : '0',
        'offspring': offspring ? '1' : '0',
        'smoking': smoking ? '1' : '0',
        'marital_status': maritalStatus ? '1' : '0',
        'allergy': allergy ? '1' : '0',
        'bilharziasis': bilharziasis ? '1' : '0',
        'hepatitis': hepatitis ? '1' : '0',
        'created_at': createdAt,
      };
}
