class TumorMarkers {
  final int? id;
  final int patientId;
  final String date;
  final double? ca19_9;
  final double? ca125;
  final double? ca15_3;
  final double? cea;
  final double? afp;
  final double? psaTotal;
  final double? psaFree;
  final String createdAt;

  TumorMarkers({
    this.id,
    required this.patientId,
    required this.date,
    this.ca19_9,
    this.ca125,
    this.ca15_3,
    this.cea,
    this.afp,
    this.psaTotal,
    this.psaFree,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId.toString(),
      'date': date,
      'ca19_9': ca19_9?.toString() ?? '',
      'ca125': ca125?.toString() ?? '',
      'ca15_3': ca15_3?.toString() ?? '',
      'cea': cea?.toString() ?? '',
      'afp': afp?.toString() ?? '',
      'psa_total': psaTotal?.toString() ?? '',
      'psa_free': psaFree?.toString() ?? '',
      'created_at': createdAt,
    };
  }

  factory TumorMarkers.fromMap(Map<String, dynamic> map) {
    return TumorMarkers(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      patientId: map['patient_id'] is int ? map['patient_id'] : int.parse(map['patient_id'].toString()),
      date: map['date']?.toString() ?? '',
      ca19_9: map['ca19_9'] != null && map['ca19_9'].toString().isNotEmpty ? double.tryParse(map['ca19_9'].toString()) : null,
      ca125: map['ca125'] != null && map['ca125'].toString().isNotEmpty ? double.tryParse(map['ca125'].toString()) : null,
      ca15_3: map['ca15_3'] != null && map['ca15_3'].toString().isNotEmpty ? double.tryParse(map['ca15_3'].toString()) : null,
      cea: map['cea'] != null && map['cea'].toString().isNotEmpty ? double.tryParse(map['cea'].toString()) : null,
      afp: map['afp'] != null && map['afp'].toString().isNotEmpty ? double.tryParse(map['afp'].toString()) : null,
      psaTotal: map['psa_total'] != null && map['psa_total'].toString().isNotEmpty ? double.tryParse(map['psa_total'].toString()) : null,
      psaFree: map['psa_free'] != null && map['psa_free'].toString().isNotEmpty ? double.tryParse(map['psa_free'].toString()) : null,
      createdAt: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
