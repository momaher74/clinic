import 'package:clinic/core/models/tumor_markers.dart';
import 'package:clinic/core/services/sql_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'tumor_markers_state.dart';

class TumorMarkersCubit extends Cubit<TumorMarkersState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  TumorMarkersCubit() : super(TumorMarkersInitial());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    // avoid reloading if we already loaded this patient and not forced
    if (!force && _loadedPatientId == pid && state is TumorMarkersLoaded) return;
    _loadedPatientId = pid;

    try {
      emit(TumorMarkersLoading());
      if (!_tableCreated) {
        await _db.createTableWithAttributes('tumor_markers', [
          'patient_id', 'date', 'ca19_9', 'ca125', 'ca15_3', 'cea', 'afp', 'psa_total', 'psa_free', 'created_at'
        ]);
        _tableCreated = true;
      }
      final rows = await _db.getAll('tumor_markers');
      final records = rows.map((r) => TumorMarkers.fromMap(r)).where((c) => c.patientId == pid).toList();
      emit(TumorMarkersLoaded(records));
    } catch (e) {
      emit(TumorMarkersError(e.toString()));
    }
  }

  void resetLoaded() {
    _loadedPatientId = null;
  }

  Future<void> add(TumorMarkers record) async {
    try {
      final id = await _db.insert('tumor_markers', record.toMap());
      if (state is TumorMarkersLoaded) {
        final current = (state as TumorMarkersLoaded).records;
        final updatedRecord = TumorMarkers(
          id: id,
          patientId: record.patientId,
          date: record.date,
          ca19_9: record.ca19_9,
          ca125: record.ca125,
          ca15_3: record.ca15_3,
          cea: record.cea,
          afp: record.afp,
          psaTotal: record.psaTotal,
          psaFree: record.psaFree,
          createdAt: record.createdAt,
        );
        emit(TumorMarkersLoaded([updatedRecord, ...current]));
      }
    } catch (e) {
      emit(TumorMarkersError(e.toString()));
    }
  }

  Future<void> delete(int id) async {
    try {
      await _db.delete('tumor_markers', id);
      if (state is TumorMarkersLoaded) {
        final current = (state as TumorMarkersLoaded).records;
        emit(TumorMarkersLoaded(current.where((r) => r.id != id).toList()));
      }
    } catch (e) {
      emit(TumorMarkersError(e.toString()));
    }
  }

  void reset() {
    emit(TumorMarkersInitial());
  }
}
