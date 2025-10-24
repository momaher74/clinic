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
  final double? antiDsDna;
  final double? c3;
  final double? c4;
  final double? rf;
  final double? antiCcp;
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
    double? parseNullableDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return double.tryParse(s.replaceAll(',', '.'));
    }

    String? parseNullableString(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return AutoimmuneMarkers(
      id: (map['id'] is int) ? map['id'] as int : (map['id'] is String ? int.tryParse(map['id']) : null),
      patientId: (map['patient_id'] is int) ? map['patient_id'] as int : int.tryParse(map['patient_id']?.toString() ?? '') ?? 0,
      date: map['date']?.toString() ?? '',
      ana: parseNullableString(map['ana']),
      ama: parseNullableString(map['ama']),
      asma: parseNullableString(map['asma']),
      lkm: parseNullableString(map['lkm']),
      sla: parseNullableString(map['sla']),
      totalIgG: parseNullableDouble(map['total_igg']),
      totalIgM: parseNullableDouble(map['total_igm']),
      anca: parseNullableString(map['anca']),
      asca: parseNullableString(map['asca']),
      antiDsDna: parseNullableDouble(map['anti_ds_dna']),
      c3: parseNullableDouble(map['c3']),
      c4: parseNullableDouble(map['c4']),
      rf: parseNullableDouble(map['rf']),
      antiCcp: parseNullableDouble(map['anti_ccp']),
      createdAt: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
