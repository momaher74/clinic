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
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse('$v');
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse('$v');
    }

    final id = parseInt(map['id']);
    final patientId = parseInt(map['patient_id']) ?? 0;

    return DiabetesLabs(
      id: id,
      patientId: patientId,
      date: map['date'] as String? ?? '',
      fbiGlu: parseDouble(map['fbi_glu']),
      hrsPpBiGlu: parseDouble(map['hrs_pp_bi_glu']),
      hba1c: parseDouble(map['hba1c']),
      cPeptide: parseDouble(map['c_peptide']),
      insulinLevel: parseDouble(map['insulin_level']),
      rbs: parseDouble(map['rbs']),
      homaIr: parseDouble(map['homa_ir']),
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
