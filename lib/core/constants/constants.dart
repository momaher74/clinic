import 'package:flutter/material.dart';

var defaultGradient = LinearGradient(
  colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

Color primaryColor = Color(0xFF3B82F6);

  String shortDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }


  Widget infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value.isEmpty ? '-' : value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
