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
    return InflammatoryMarkers(
      id: map['id'],
      patientId: map['patient_id'],
      date: map['date'],
      esr: map['esr'] != null ? (map['esr'] as num).toDouble() : null,
      crp: map['crp'] != null ? (map['crp'] as num).toDouble() : null,
      asot: map['asot'] != null ? (map['asot'] as num).toDouble() : null,
      createdAt: map['created_at'],
    );
  }
}
