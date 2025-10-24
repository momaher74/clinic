class KidneyFunctionTest {
  final int? id;
  final int patientId;
  final String date;
  final String sCreatinine;
  final String urea;
  final String ua;
  final String na;
  final String k;
  final String ca;
  final String mg;
  final String po4;
  final String pth;
  final String createdAt;

  KidneyFunctionTest({
    this.id,
    required this.patientId,
    this.date = '',
    this.sCreatinine = '',
    this.urea = '',
    this.ua = '',
    this.na = '',
    this.k = '',
    this.ca = '',
    this.mg = '',
    this.po4 = '',
    this.pth = '',
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date': date,
      's_creatinine': sCreatinine,
      'urea': urea,
      'ua': ua,
      'na': na,
      'k': k,
      'ca': ca,
      'mg': mg,
      'po4': po4,
      'pth': pth,
      'created_at': createdAt,
    };
  }

  factory KidneyFunctionTest.fromMap(Map<String, dynamic> map) {
    // Accept both int and string representations (defensive parsing)
    final id = map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}');
    final patientId = map['patient_id'] is int
        ? map['patient_id'] as int
        : int.tryParse('${map['patient_id']}') ?? 0;

    return KidneyFunctionTest(
      id: id,
      patientId: patientId,
      date: map['date'] as String? ?? '',
      sCreatinine: map['s_creatinine'] as String? ?? '',
      urea: map['urea'] as String? ?? '',
      ua: map['ua'] as String? ?? '',
      na: map['na'] as String? ?? '',
      k: map['k'] as String? ?? '',
      ca: map['ca'] as String? ?? '',
      mg: map['mg'] as String? ?? '',
      po4: map['po4'] as String? ?? '',
      pth: map['pth'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
