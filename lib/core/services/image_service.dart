import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageService {
  /// Opens an image picker, copies the picked file into the app documents
  /// directory and returns the stored path, or null on cancel/failure.
  static Future<String?> pickAndStoreImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      final path = result?.files.first.path;
      if (path == null) return null;
      return await storeImageFile(path);
    } catch (e) {
      // Don't use BuildContext for UI here (avoids async context issues).
      // Let callers show UI feedback; log for debugging.
      debugPrint('Failed to pick image: $e');
      return null;
    }
  }

  /// Copies a file at [originalPath] into the app documents folder under
  /// `clinic_images` and returns the new path, or null on failure.
  static Future<String?> storeImageFile(String originalPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(appDir.path, 'clinic_images'));
      if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
      final filename =
          '${DateTime.now().millisecondsSinceEpoch}${p.extension(originalPath)}';
      final destPath = p.join(imagesDir.path, filename);
      await File(originalPath).copy(destPath);
      return destPath;
    } catch (e) {
      // Don't show SnackBars from a service. Log and return null so callers
      // can handle user-facing feedback in the correct BuildContext.
      debugPrint('Failed to store image: $e');
      return null;
    }
  }

  /// Best-effort delete of a stored image file. Returns true if file deleted.
  static Future<bool> deleteStoredImage(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) {
        await f.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
