class Cbc {
  int? id;
  int patientId;
  String date; // ISO or user date
  String hb;
  String rbcs;
  String mcv;
  String mch;
  String tlc;
  String neut;
  String lymph;
  String mono;
  String eos;
  String baso;
  String ptt;
  String createdAt;

  Cbc({this.id, required this.patientId, required this.date, this.hb = '', this.rbcs = '', this.mcv = '', this.mch = '', this.tlc = '', this.neut = '', this.lymph = '', this.mono = '', this.eos = '', this.baso = '', this.ptt = '', String? createdAt})
      : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId.toString(),
      'date': date,
      'hb': hb,
      'rbcs': rbcs,
      'mcv': mcv,
      'mch': mch,
      'tlc': tlc,
      'neut': neut,
      'lymph': lymph,
      'mono': mono,
      'eos': eos,
      'baso': baso,
      'ptt': ptt,
      'created_at': createdAt,
    };
  }

  factory Cbc.fromMap(Map<String, dynamic> m) {
    return Cbc(
      id: m['id'] is int ? m['id'] as int : int.tryParse('${m['id']}'),
      patientId: m['patient_id'] is int ? m['patient_id'] as int : int.tryParse('${m['patient_id']}') ?? 0,
      date: m['date'] ?? '',
      hb: m['hb'] ?? '',
      rbcs: m['rbcs'] ?? '',
      mcv: m['mcv'] ?? '',
      mch: m['mch'] ?? '',
      tlc: m['tlc'] ?? '',
      neut: m['neut'] ?? '',
      lymph: m['lymph'] ?? '',
      mono: m['mono'] ?? '',
      eos: m['eos'] ?? '',
      baso: m['baso'] ?? '',
      ptt: m['ptt'] ?? '',
      createdAt: m['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}
