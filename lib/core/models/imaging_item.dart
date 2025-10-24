import 'dart:convert';

class ImagingItem {
  final String id;
  final String type;
  final String doctor;
  final String where;
  final String report;
  final String imagePath;
  final int createdAt;

  ImagingItem({
    required this.id,
    required this.type,
    required this.doctor,
    required this.where,
    required this.report,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'doctor': doctor,
        'where': where,
        'report': report,
        'imagePath': imagePath,
        'createdAt': createdAt,
      };

  factory ImagingItem.fromJson(Map<String, dynamic> json) => ImagingItem(
        id: json['id'] as String,
        type: json['type'] as String,
        doctor: (json['doctor'] as String?) ?? '',
        where: (json['where'] as String?) ?? '',
        report: (json['report'] as String?) ?? '',
        imagePath: json['imagePath'] as String,
        createdAt: (json['createdAt'] as num).toInt(),
      );

  static List<ImagingItem> listFromJson(String jsonStr) {
    final decoded = json.decode(jsonStr) as List<dynamic>;
    return decoded.map((e) => ImagingItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<ImagingItem> items) => json.encode(items.map((e) => e.toJson()).toList());
}
