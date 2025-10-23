class Examination {
  int? id;
  int patientId;
  String bp;
  String pulse;
  String temp;
  String spo2;
  String other;
  String examination;
  String createdAt;

  Examination({this.id, required this.patientId, this.bp = '', this.pulse = '', this.temp = '', this.spo2 = '', this.other = '', this.examination = '', String? createdAt}) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId.toString(),
      'bp': bp,
      'pulse': pulse,
      'temp': temp,
      'spo2': spo2,
      'other': other,
      'examination': examination,
      'created_at': createdAt,
    };
  }

  factory Examination.fromMap(Map<String, dynamic> m) {
    return Examination(
      id: m['id'] is int ? m['id'] as int : int.tryParse('${m['id']}'),
      patientId: m['patient_id'] is int ? m['patient_id'] as int : int.tryParse('${m['patient_id']}') ?? 0,
      bp: m['bp'] ?? '',
      pulse: m['pulse'] ?? '',
      temp: m['temp'] ?? '',
      spo2: m['spo2'] ?? '',
      other: m['other'] ?? '',
      examination: m['examination'] ?? '',
      createdAt: m['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}
