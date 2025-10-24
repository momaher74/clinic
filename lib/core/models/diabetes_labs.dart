class DiabetesLabs {
  final int? id;
  final int patientId;
  final String date;
  final double? fbiGlu;
  final double? hrsPpBiGlu;
  final double? hba1c;
  final double? cPeptide;
  final double? insulinLevel;
  final double? rbs;
  final double? homaIr;
  final String createdAt;

  DiabetesLabs({
    this.id,
    required this.patientId,
    required this.date,
    this.fbiGlu,
    this.hrsPpBiGlu,
    this.hba1c,
    this.cPeptide,
    this.insulinLevel,
    this.rbs,
    this.homaIr,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date': date,
      'fbi_glu': fbiGlu,
      'hrs_pp_bi_glu': hrsPpBiGlu,
      'hba1c': hba1c,
      'c_peptide': cPeptide,
      'insulin_level': insulinLevel,
      'rbs': rbs,
      'homa_ir': homaIr,
      'created_at': createdAt,
    };
  }

  factory DiabetesLabs.fromMap(Map<String, dynamic> map) {
    return DiabetesLabs(
      id: map['id'],
      patientId: map['patient_id'],
      date: map['date'],
      fbiGlu: map['fbi_glu'] != null ? (map['fbi_glu'] as num).toDouble() : null,
      hrsPpBiGlu: map['hrs_pp_bi_glu'] != null ? (map['hrs_pp_bi_glu'] as num).toDouble() : null,
      hba1c: map['hba1c'] != null ? (map['hba1c'] as num).toDouble() : null,
      cPeptide: map['c_peptide'] != null ? (map['c_peptide'] as num).toDouble() : null,
      insulinLevel: map['insulin_level'] != null ? (map['insulin_level'] as num).toDouble() : null,
      rbs: map['rbs'] != null ? (map['rbs'] as num).toDouble() : null,
      homaIr: map['homa_ir'] != null ? (map['homa_ir'] as num).toDouble() : null,
      createdAt: map['created_at'],
    );
  }
}
