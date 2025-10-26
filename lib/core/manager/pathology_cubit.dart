import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/pathology_item.dart';

class PathologyState {
  final List<PathologyItem> items;
  final bool loading;

  PathologyState({required this.items, this.loading = false});

  PathologyState copyWith({List<PathologyItem>? items, bool? loading}) =>
      PathologyState(
        items: items ?? this.items,
        loading: loading ?? this.loading,
      );
}

class PathologyCubit extends Cubit<PathologyState> {
  static const _storageKey = 'pathology_items_v1';
  final SharedPreferences prefs;

  PathologyCubit(this.prefs) : super(PathologyState(items: [])) {
    _load();
  }

  Future<void> _load() async {
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final items = PathologyItem.listFromJson(raw);
        emit(state.copyWith(items: items));
      } catch (_) {}
    }
  }

  Future<String> _saveImageFile(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/pathology_images');
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    final id = const Uuid().v4();
    final ext = file.path.split('.').last;
    final dest = File('${imagesDir.path}/$id.$ext');
    final newFile = await file.copy(dest.path);
    return newFile.path;
  }

  Future<void> addItem({
    required String type,
    required String pathLab,
    required String pathologist,
    required String report,
    File? imageFile,
    int? patientId,
  }) async {
    emit(state.copyWith(loading: true));
    try {
      String savedPath = '';
      if (imageFile != null) {
        savedPath = await _saveImageFile(imageFile);
      }
      final item = PathologyItem(
        id: const Uuid().v4(),
        type: type,
        pathLab: pathLab,
        pathologist: pathologist,
        report: report,
        patientId: patientId,
        imagePath: savedPath,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      final newItems = List<PathologyItem>.from(state.items)..insert(0, item);
      prefs.setString(_storageKey, PathologyItem.listToJson(newItems));
      emit(state.copyWith(items: newItems, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> removeItem(String id) async {
    final newItems = state.items.where((e) => e.id != id).toList();
    prefs.setString(_storageKey, PathologyItem.listToJson(newItems));
    final toDelete = state.items.firstWhere(
      (e) => e.id == id,
      orElse: () => PathologyItem(
        id: '',
        type: '',
        pathLab: '',
        pathologist: '',
        report: '',
        imagePath: '',
        createdAt: 0,
      ),
    );
    if (toDelete.imagePath.isNotEmpty) {
      try {
        final f = File(toDelete.imagePath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    emit(state.copyWith(items: newItems));
  }
}
