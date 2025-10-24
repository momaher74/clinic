class CuProfile {
  final int? id;
  final int patientId;
  final String date;
  final double? sCeruloplasmin;
  final double? urinaryCu24hrs;
  final String createdAt;

  CuProfile({
    this.id,
    required this.patientId,
    required this.date,
    this.sCeruloplasmin,
    this.urinaryCu24hrs,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId.toString(),
      'date': date,
      's_ceruloplasmin': sCeruloplasmin?.toString() ?? '',
      'urinary_cu_24hrs': urinaryCu24hrs?.toString() ?? '',
      'created_at': createdAt,
    };
  }

  factory CuProfile.fromMap(Map<String, dynamic> map) {
    return CuProfile(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      patientId: map['patient_id'] is int ? map['patient_id'] : int.parse(map['patient_id'].toString()),
      date: map['date']?.toString() ?? '',
      sCeruloplasmin: map['s_ceruloplasmin'] != null && map['s_ceruloplasmin'].toString().isNotEmpty ? double.tryParse(map['s_ceruloplasmin'].toString()) : null,
      urinaryCu24hrs: map['urinary_cu_24hrs'] != null && map['urinary_cu_24hrs'].toString().isNotEmpty ? double.tryParse(map['urinary_cu_24hrs'].toString()) : null,
      createdAt: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
