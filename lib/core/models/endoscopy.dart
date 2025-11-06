class Endoscopy {
  int? id;
  int patientId;
  String type; // OGD, Colonoscopy, ERCP, EUS
  String date; // ISO or user date
  String ec; // EC number/code
  String endoscopist;
  String followUp;
  String report;
  String? imagePath;
  String createdAt;

  Endoscopy({
    this.id,
    required this.patientId,
    required this.type,
    required this.date,
    this.ec = '',
    this.endoscopist = '',
    this.followUp = '',
    this.report = '',
    this.imagePath,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId.toString(),
      'type': type,
      'date': date,
      'ec': ec,
      'endoscopist': endoscopist,
      'follow_up': followUp,
      'report': report,
      'image_path': imagePath,
      'created_at': createdAt,
    };
  }

  factory Endoscopy.fromMap(Map<String, dynamic> m) {
    return Endoscopy(
      id: m['id'] is int ? m['id'] as int : int.tryParse('${m['id']}'),
      patientId: m['patient_id'] is int
          ? m['patient_id'] as int
          : int.tryParse('${m['patient_id']}') ?? 0,
      type: m['type'] ?? '',
      date: m['date'] ?? '',
      ec: m['ec'] ?? '',
      endoscopist: m['endoscopist'] ?? '',
      followUp: m['follow_up'] ?? '',
      report: m['report'] ?? '',
      createdAt: m['created_at'] ?? DateTime.now().toIso8601String(),
      imagePath: m['image_path'],
    );
  }
}
