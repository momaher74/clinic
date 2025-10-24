class VitaminLevel {
  final int? id;
  final int patientId;
  final String date;
  final double? vitDLevel;
  final double? vitB12Level;
  final String createdAt;

  VitaminLevel({
    this.id,
    required this.patientId,
    required this.date,
    this.vitDLevel,
    this.vitB12Level,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId.toString(),
      'date': date,
      'vit_d_level': vitDLevel?.toString() ?? '',
      'vit_b12_level': vitB12Level?.toString() ?? '',
      'created_at': createdAt,
    };
  }

  factory VitaminLevel.fromMap(Map<String, dynamic> map) {
    return VitaminLevel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      patientId: map['patient_id'] is int ? map['patient_id'] : int.parse(map['patient_id'].toString()),
      date: map['date']?.toString() ?? '',
      vitDLevel: map['vit_d_level'] != null && map['vit_d_level'].toString().isNotEmpty ? double.tryParse(map['vit_d_level'].toString()) : null,
      vitB12Level: map['vit_b12_level'] != null && map['vit_b12_level'].toString().isNotEmpty ? double.tryParse(map['vit_b12_level'].toString()) : null,
      createdAt: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
