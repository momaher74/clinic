import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/endoscopy.dart';
import 'package:clinic/core/services/sql_service.dart';

class OgdState {
  final bool isLoading;
  final String? error;
  final List<Endoscopy> list;

  OgdState({this.isLoading = false, this.error, this.list = const []});

  OgdState copyWith({bool? isLoading, String? error, List<Endoscopy>? list}) =>
      OgdState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, list: list ?? this.list);
}

class OgdCubit extends Cubit<OgdState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  OgdCubit() : super(OgdState());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    if (!force && _loadedPatientId == pid && state.list.isNotEmpty) return;
    _loadedPatientId = pid;

    emit(state.copyWith(isLoading: true));
    if (!_tableCreated) {
      await _db.createTableWithAttributes('endoscopy', ['patient_id', 'type', 'date', 'ec', 'endoscopist', 'follow_up', 'report', 'created_at']);
      _tableCreated = true;
    }
    final rows = await _db.getAll('endoscopy');
    final all = rows.map((r) => Endoscopy.fromMap(r)).where((e) => e.patientId == pid && e.type == 'OGD').toList();
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
    await _db.delete('endoscopy', id);
    final newList = List<Endoscopy>.from(state.list)..removeWhere((e) => e.id == id);
    emit(state.copyWith(list: newList));
  }
}
