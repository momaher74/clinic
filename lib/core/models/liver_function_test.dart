class LiverFunctionTest {
  final int? id;
  final int patientId;
  final String date;
  final String tbill;
  final String dbill;
  final String tp;
  final String salb;
  final String alt;
  final String ast;
  final String alp;
  final String ggt;
  final String createdAt;

  LiverFunctionTest({
    this.id,
    required this.patientId,
    this.date = '',
    this.tbill = '',
    this.dbill = '',
    this.tp = '',
    this.salb = '',
    this.alt = '',
    this.ast = '',
    this.alp = '',
    this.ggt = '',
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date': date,
      'tbill': tbill,
      'dbill': dbill,
      'tp': tp,
      'salb': salb,
      'alt': alt,
      'ast': ast,
      'alp': alp,
      'ggt': ggt,
      'created_at': createdAt,
    };
  }

  factory LiverFunctionTest.fromMap(Map<String, dynamic> map) {
    final id = map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}');
    final patientId = map['patient_id'] is int
        ? map['patient_id'] as int
        : int.tryParse('${map['patient_id']}') ?? 0;

    return LiverFunctionTest(
      id: id,
      patientId: patientId,
      date: map['date'] as String? ?? '',
      tbill: map['tbill'] as String? ?? '',
      dbill: map['dbill'] as String? ?? '',
      tp: map['tp'] as String? ?? '',
      salb: map['salb'] as String? ?? '',
      alt: map['alt'] as String? ?? '',
      ast: map['ast'] as String? ?? '',
      alp: map['alp'] as String? ?? '',
      ggt: map['ggt'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
