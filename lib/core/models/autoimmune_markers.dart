class AutoimmuneMarkers {
  final int? id;
  final int patientId;
  final String date;
  final String? ana;
  final String? ama;
  final String? asma;
  final String? lkm;
  final String? sla;
  final double? totalIgG;
  final double? totalIgM;
  final String? anca;
  final String? asca;
  final String? antiDsDna;
  final double? c3;
  final double? c4;
  final String? rf;
  final String? antiCcp;
  final String createdAt;

  AutoimmuneMarkers({
    this.id,
    required this.patientId,
    required this.date,
    this.ana,
    this.ama,
    this.asma,
    this.lkm,
    this.sla,
    this.totalIgG,
    this.totalIgM,
    this.anca,
    this.asca,
    this.antiDsDna,
    this.c3,
    this.c4,
    this.rf,
    this.antiCcp,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date': date,
      'ana': ana,
      'ama': ama,
      'asma': asma,
      'lkm': lkm,
      'sla': sla,
      'total_igg': totalIgG,
      'total_igm': totalIgM,
      'anca': anca,
      'asca': asca,
      'anti_ds_dna': antiDsDna,
      'c3': c3,
      'c4': c4,
      'rf': rf,
      'anti_ccp': antiCcp,
      'created_at': createdAt,
    };
  }

  factory AutoimmuneMarkers.fromMap(Map<String, dynamic> map) {
    return AutoimmuneMarkers(
      id: map['id'],
      patientId: map['patient_id'],
      date: map['date'],
      ana: map['ana'],
      ama: map['ama'],
      asma: map['asma'],
      lkm: map['lkm'],
      sla: map['sla'],
      totalIgG: map['total_igg'] != null ? (map['total_igg'] as num).toDouble() : null,
      totalIgM: map['total_igm'] != null ? (map['total_igm'] as num).toDouble() : null,
      anca: map['anca'],
      asca: map['asca'],
      antiDsDna: map['anti_ds_dna'],
      c3: map['c3'] != null ? (map['c3'] as num).toDouble() : null,
      c4: map['c4'] != null ? (map['c4'] as num).toDouble() : null,
      rf: map['rf'],
      antiCcp: map['anti_ccp'],
      createdAt: map['created_at'],
    );
  }
}
