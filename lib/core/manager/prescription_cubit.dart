import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/prescription_item.dart';

class PrescriptionState {
  final List<PrescriptionItem> items;
  final bool loading;

  PrescriptionState({required this.items, this.loading = false});

  PrescriptionState copyWith({List<PrescriptionItem>? items, bool? loading}) =>
      PrescriptionState(
        items: items ?? this.items,
        loading: loading ?? this.loading,
      );
}

class PrescriptionCubit extends Cubit<PrescriptionState> {
  static const _storageKey = 'prescription_items_v1';
  final SharedPreferences prefs;

  PrescriptionCubit(this.prefs) : super(PrescriptionState(items: [])) {
    _load();
  }

  Future<void> _load() async {
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final items = PrescriptionItem.listFromJson(raw);
        emit(state.copyWith(items: items));
      } catch (_) {}
    }
  }

  Future<String> _saveImageFile(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/prescription_images');
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    final id = const Uuid().v4();
    final ext = file.path.split('.').last;
    final dest = File('${imagesDir.path}/$id.$ext');
    final newFile = await file.copy(dest.path);
    return newFile.path;
  }

  Future<void> addItem({
    required String date,
    required String drug,
    required String dose,
    required String frequency,
    required String days,
    File? imageFile,
    int? patientId,
  }) async {
    emit(state.copyWith(loading: true));
    try {
      String savedPath = '';
      if (imageFile != null) savedPath = await _saveImageFile(imageFile);
      final item = PrescriptionItem(
        id: const Uuid().v4(),
        date: date,
        drug: drug,
        dose: dose,
        frequency: frequency,
        days: days,
        patientId: patientId,
        imagePath: savedPath,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      final newItems = List<PrescriptionItem>.from(state.items)
        ..insert(0, item);
      prefs.setString(_storageKey, PrescriptionItem.listToJson(newItems));
      emit(state.copyWith(items: newItems, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> removeItem(String id) async {
    final newItems = state.items.where((e) => e.id != id).toList();
    prefs.setString(_storageKey, PrescriptionItem.listToJson(newItems));
    final toDelete = state.items.firstWhere(
      (e) => e.id == id,
      orElse: () => PrescriptionItem(
        id: '',
        date: '',
        drug: '',
        dose: '',
        frequency: '',
        days: '',
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
