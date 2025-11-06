import 'dart:io';

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
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Widget sharedDivider() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 12),
    height: 2,
    width: double.infinity,
    decoration: BoxDecoration(color: Colors.grey),
  );
}

TextStyle whiteStyle = const TextStyle(
  color: Colors.white,
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

void sharedOpenImage(BuildContext context, String path) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            child: InteractiveViewer(
              child: Image.file(
                File(path),
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, st) => const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('Unable to load image')),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    ),
  );
}
