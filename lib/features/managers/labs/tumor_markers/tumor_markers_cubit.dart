import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/tumor_markers.dart';
import 'package:clinic/core/services/sql_service.dart';

class TumorMarkersState {
  final bool isLoading;
  final String? error;
  final List<TumorMarkers> list;

  TumorMarkersState({this.isLoading = false, this.error, this.list = const []});

  TumorMarkersState copyWith({bool? isLoading, String? error, List<TumorMarkers>? list}) =>
      TumorMarkersState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, list: list ?? this.list);
}

class TumorMarkersCubit extends Cubit<TumorMarkersState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  TumorMarkersCubit() : super(TumorMarkersState());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    if (!force && _loadedPatientId == pid && state.list.isNotEmpty) return;
    _loadedPatientId = pid;

    emit(state.copyWith(isLoading: true));
    if (!_tableCreated) {
      await _db.createTableWithAttributes('tumor_markers', [
        'patient_id', 'date', 'ca19_9', 'ca125', 'ca15_3', 'cea', 'afp', 'psa_total', 'psa_free', 'created_at'
      ]);
      _tableCreated = true;
    }
    final rows = await _db.getAll('tumor_markers');
    final all = rows.map((r) => TumorMarkers.fromMap(r)).where((c) => c.patientId == pid).toList();
    emit(state.copyWith(isLoading: false, list: all));
  }

  void resetLoaded() {
    _loadedPatientId = null;
  }

  Future<void> add(TumorMarkers c) async {
    final id = await _db.insert('tumor_markers', c.toMap());
    final updatedRecord = TumorMarkers(
      id: id,
      patientId: c.patientId,
      date: c.date,
      ca19_9: c.ca19_9,
      ca125: c.ca125,
      ca15_3: c.ca15_3,
      cea: c.cea,
      afp: c.afp,
      psaTotal: c.psaTotal,
      psaFree: c.psaFree,
      createdAt: c.createdAt,
    );
    final newList = [updatedRecord, ...state.list];
    emit(state.copyWith(list: newList));
  }

  Future<void> delete(int id) async {
    await _db.delete('tumor_markers', id);
    final newList = List<TumorMarkers>.from(state.list)..removeWhere((c) => c.id == id);
    emit(state.copyWith(list: newList));
  }
}
