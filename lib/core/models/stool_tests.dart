class StoolTests {
  final int? id;
  final int patientId;
  final String date;
  final String? occultInStool;
  final String? hPyloriAgInStool;
  final String? fecalCalprotectin;
  final String? stoolAnalysis;
  final String? fitTest;
  final String createdAt;

  StoolTests({
    this.id,
    required this.patientId,
    required this.date,
    this.occultInStool,
    this.hPyloriAgInStool,
    this.fecalCalprotectin,
    this.stoolAnalysis,
    this.fitTest,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId.toString(),
      'date': date,
      'occult_in_stool': occultInStool ?? '',
      'h_pylori_ag_in_stool': hPyloriAgInStool ?? '',
      'fecal_calprotectin': fecalCalprotectin ?? '',
      'stool_analysis': stoolAnalysis ?? '',
      'fit_test': fitTest ?? '',
      'created_at': createdAt,
    };
  }

  factory StoolTests.fromMap(Map<String, dynamic> map) {
    return StoolTests(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      patientId: map['patient_id'] is int ? map['patient_id'] : int.parse(map['patient_id'].toString()),
      date: map['date']?.toString() ?? '',
      occultInStool: map['occult_in_stool']?.toString().isEmpty ?? true ? null : map['occult_in_stool']?.toString(),
      hPyloriAgInStool: map['h_pylori_ag_in_stool']?.toString().isEmpty ?? true ? null : map['h_pylori_ag_in_stool']?.toString(),
      fecalCalprotectin: map['fecal_calprotectin']?.toString().isEmpty ?? true ? null : map['fecal_calprotectin']?.toString(),
      stoolAnalysis: map['stool_analysis']?.toString().isEmpty ?? true ? null : map['stool_analysis']?.toString(),
      fitTest: map['fit_test']?.toString().isEmpty ?? true ? null : map['fit_test']?.toString(),
      createdAt: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
