class Complaint {
  int? id;
  int patientId;
  String date; // ISO
  String type; // 'Check' or 'Recheck'
  String description;

  Complaint({this.id, required this.patientId, required this.date, required this.type, required this.description});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId,
      'date': date,
      'type': type,
      'description': description,
    };
  }

  factory Complaint.fromMap(Map<String, dynamic> m) {
    return Complaint(
      id: m['id'] is int ? m['id'] as int : int.tryParse('${m['id']}'),
      patientId: m['patient_id'] is int ? m['patient_id'] as int : int.tryParse('${m['patient_id']}') ?? 0,
      date: m['date'] ?? '',
      type: m['type'] ?? '',
      description: m['description'] ?? '',
    );
  }
}
