import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/imaging_item.dart';

class ImagingState {
  final List<ImagingItem> items;
  final bool loading;

  ImagingState({required this.items, this.loading = false});

  ImagingState copyWith({List<ImagingItem>? items, bool? loading}) => ImagingState(
        items: items ?? this.items,
        loading: loading ?? this.loading,
      );
}

class ImagingCubit extends Cubit<ImagingState> {
  static const _storageKey = 'imaging_items_v1';
  final SharedPreferences prefs;

  ImagingCubit(this.prefs) : super(ImagingState(items: [])) {
    _load();
  }

  Future<void> _load() async {
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final items = ImagingItem.listFromJson(raw);
        emit(state.copyWith(items: items));
      } catch (_) {}
    }
  }

  Future<String> _saveImageFile(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/images');
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    final id = const Uuid().v4();
    final ext = file.path.split('.').last;
    final dest = File('${imagesDir.path}/$id.$ext');
    final newFile = await file.copy(dest.path);
    return newFile.path;
  }

  Future<void> addItem({required String type, required String doctor, required String where, required String report, required File imageFile}) async {
    emit(state.copyWith(loading: true));
    try {
      final savedPath = await _saveImageFile(imageFile);
      final item = ImagingItem(
        id: const Uuid().v4(),
        type: type,
        doctor: doctor,
        where: where,
        report: report,
        imagePath: savedPath,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      final newItems = List<ImagingItem>.from(state.items)..insert(0, item);
      prefs.setString(_storageKey, ImagingItem.listToJson(newItems));
      emit(state.copyWith(items: newItems, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> removeItem(String id) async {
    final newItems = state.items.where((e) => e.id != id).toList();
    prefs.setString(_storageKey, ImagingItem.listToJson(newItems));
    // delete file if exists
    final toDelete = state.items.firstWhere((e) => e.id == id, orElse: () => ImagingItem(id: '', type: '', doctor: '', where: '', report: '', imagePath: '', createdAt: 0));
    if (toDelete.imagePath.isNotEmpty) {
      try {
        final f = File(toDelete.imagePath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    emit(state.copyWith(items: newItems));
  }
}
