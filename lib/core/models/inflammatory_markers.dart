class InflammatoryMarkers {
  final int? id;
  final int patientId;
  final String date;
  final double? esr;
  final double? crp;
  final double? asot;
  final String createdAt;

  InflammatoryMarkers({
    this.id,
    required this.patientId,
    required this.date,
    this.esr,
    this.crp,
    this.asot,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date': date,
      'esr': esr,
      'crp': crp,
      'asot': asot,
      'created_at': createdAt,
    };
  }

  factory InflammatoryMarkers.fromMap(Map<String, dynamic> map) {
    double? parseNullableDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return double.tryParse(s.replaceAll(',', '.'));
    }

    String parseString(dynamic v) => v == null ? '' : v.toString();

    return InflammatoryMarkers(
      id: (map['id'] is int) ? map['id'] as int : (map['id'] is String ? int.tryParse(map['id']) : null),
      patientId: (map['patient_id'] is int) ? map['patient_id'] as int : int.tryParse(map['patient_id']?.toString() ?? '') ?? 0,
      date: parseString(map['date']),
      esr: parseNullableDouble(map['esr']),
      crp: parseNullableDouble(map['crp']),
      asot: parseNullableDouble(map['asot']),
      createdAt: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
