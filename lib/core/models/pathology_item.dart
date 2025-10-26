import 'dart:convert';

class PathologyItem {
  final String id;
  final String type;
  final String pathLab;
  final String pathologist;
  final String report;
  final int? patientId;
  final String imagePath;
  final int createdAt;

  PathologyItem({
    required this.id,
    required this.type,
    required this.pathLab,
    required this.pathologist,
    required this.report,
    this.patientId,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'pathLab': pathLab,
    'pathologist': pathologist,
    'report': report,
    'patientId': patientId,
    'imagePath': imagePath,
    'createdAt': createdAt,
  };

  factory PathologyItem.fromJson(Map<String, dynamic> json) => PathologyItem(
    id: json['id'] as String,
    type: json['type'] as String,
    pathLab: (json['pathLab'] as String?) ?? '',
    pathologist: (json['pathologist'] as String?) ?? '',
    report: (json['report'] as String?) ?? '',
    patientId: json['patientId'] is int
        ? (json['patientId'] as int)
        : (json['patientId'] is String
              ? int.tryParse(json['patientId'] as String)
              : null),
    imagePath: (json['imagePath'] as String?) ?? '',
    createdAt: (json['createdAt'] as num).toInt(),
  );

  static List<PathologyItem> listFromJson(String jsonStr) {
    final decoded = json.decode(jsonStr) as List<dynamic>;
    return decoded
        .map((e) => PathologyItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<PathologyItem> items) =>
      json.encode(items.map((e) => e.toJson()).toList());
}
