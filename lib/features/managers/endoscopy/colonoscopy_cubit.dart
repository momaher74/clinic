import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/endoscopy.dart';
import 'package:clinic/core/services/image_service.dart';
import 'package:clinic/core/services/sql_service.dart';

class ColonoscopyState {
  final bool isLoading;
  final String? error;
  final List<Endoscopy> list;

  ColonoscopyState({this.isLoading = false, this.error, this.list = const []});

  ColonoscopyState copyWith({
    bool? isLoading,
    String? error,
    List<Endoscopy>? list,
  }) => ColonoscopyState(
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
    list: list ?? this.list,
  );
}

class ColonoscopyC extends Cubit<ColonoscopyState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  ColonoscopyC() : super(ColonoscopyState());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    if (!force && _loadedPatientId == pid && state.list.isNotEmpty) return;
    _loadedPatientId = pid;

    emit(state.copyWith(isLoading: true));
    if (!_tableCreated) {
      await _db.createTableWithAttributes('endoscopy', [
        'patient_id',
        'type',
        'date',
        'ec',
        'endoscopist',
        'follow_up',
        'report',
        'image_path',
        'created_at',
      ]);
      _tableCreated = true;
    }
    final rows = await _db.getAll('endoscopy');
    final all = rows
        .map((r) => Endoscopy.fromMap(r))
        .where((e) => e.patientId == pid && e.type == 'Colonoscopy')
        .toList();
    emit(state.copyWith(isLoading: false, list: all));
  }

  void resetLoaded() {
    _loadedPatientId = null;
  }

  Future<void> add(Endoscopy e) async {
    final id = await _db.insert('endoscopy', e.toMap());
    e.id = id;
    final newList = [e, ...state.list];
    emit(state.copyWith(list: newList));
  }

  Future<void> delete(int id) async {
    final item = state.list.firstWhere(
      (e) => e.id == id,
      orElse: () => Endoscopy(patientId: 0, type: '', date: ''),
    );
    final imagePath = item.imagePath;
    await _db.delete('endoscopy', id);
    final newList = List<Endoscopy>.from(state.list)
      ..removeWhere((e) => e.id == id);
    emit(state.copyWith(list: newList));
    if (imagePath != null && imagePath.isNotEmpty) {
      await ImageService.deleteStoredImage(imagePath);
    }
  }
}
