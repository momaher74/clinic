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
      'id': id,
      'patient_id': patientId,
      'date': date,
      'occult_in_stool': occultInStool,
      'h_pylori_ag_in_stool': hPyloriAgInStool,
      'fecal_calprotectin': fecalCalprotectin,
      'stool_analysis': stoolAnalysis,
      'fit_test': fitTest,
      'created_at': createdAt,
    };
  }

  factory StoolTests.fromMap(Map<String, dynamic> map) {
    return StoolTests(
      id: map['id'],
      patientId: map['patient_id'],
      date: map['date'],
      occultInStool: map['occult_in_stool'],
      hPyloriAgInStool: map['h_pylori_ag_in_stool'],
      fecalCalprotectin: map['fecal_calprotectin'],
      stoolAnalysis: map['stool_analysis'],
      fitTest: map['fit_test'],
      createdAt: map['created_at'],
    );
  }
}
