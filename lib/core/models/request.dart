class Req {
  int? id;
  int patientId;
  String description;
  String createdAt;

  Req({this.id, required this.patientId, required this.description, String? createdAt}) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId.toString(),
      'description': description,
      'created_at': createdAt,
    };
  }

  factory Req.fromMap(Map<String, dynamic> m) {
    return Req(
      id: m['id'] is int ? m['id'] as int : int.tryParse('${m['id']}'),
      patientId: m['patient_id'] is int ? m['patient_id'] as int : int.tryParse('${m['patient_id']}') ?? 0,
      description: m['description'] ?? '',
      createdAt: m['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}
