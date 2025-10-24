class IronProfile {
  final int? id;
  final int patientId;
  final String date;
  final double? sIron;
  final double? sFerritin;
  final double? fTransferrinSat;
  final double? tibc;
  final String createdAt;

  IronProfile({
    this.id,
    required this.patientId,
    required this.date,
    this.sIron,
    this.sFerritin,
    this.fTransferrinSat,
    this.tibc,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId.toString(),
      'date': date,
      's_iron': sIron?.toString() ?? '',
      's_ferritin': sFerritin?.toString() ?? '',
      'f_transferrin_sat': fTransferrinSat?.toString() ?? '',
      'tibc': tibc?.toString() ?? '',
      'created_at': createdAt,
    };
  }

  factory IronProfile.fromMap(Map<String, dynamic> map) {
    return IronProfile(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      patientId: map['patient_id'] is int ? map['patient_id'] : int.parse(map['patient_id'].toString()),
      date: map['date']?.toString() ?? '',
      sIron: map['s_iron'] != null && map['s_iron'].toString().isNotEmpty ? double.tryParse(map['s_iron'].toString()) : null,
      sFerritin: map['s_ferritin'] != null && map['s_ferritin'].toString().isNotEmpty ? double.tryParse(map['s_ferritin'].toString()) : null,
      fTransferrinSat: map['f_transferrin_sat'] != null && map['f_transferrin_sat'].toString().isNotEmpty ? double.tryParse(map['f_transferrin_sat'].toString()) : null,
      tibc: map['tibc'] != null && map['tibc'].toString().isNotEmpty ? double.tryParse(map['tibc'].toString()) : null,
      createdAt: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
