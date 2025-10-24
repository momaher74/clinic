import 'package:clinic/core/models/urine_analysis.dart';
import 'package:clinic/core/services/sql_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'urine_analysis_state.dart';

class UrineAnalysisCubit extends Cubit<UrineAnalysisState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  UrineAnalysisCubit() : super(UrineAnalysisInitial());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    if (!force && _loadedPatientId == pid && state is UrineAnalysisLoaded) return;
    _loadedPatientId = pid;

    try {
      emit(UrineAnalysisLoading());
      if (!_tableCreated) {
        await _db.createTableWithAttributes('urine_analysis', [
          'patient_id', 'date', 'note', 'created_at'
        ]);
        _tableCreated = true;
      }
      final rows = await _db.getAll('urine_analysis');
      final records = rows.map((r) => UrineAnalysis.fromMap(r)).where((c) => c.patientId == pid).toList();
      emit(UrineAnalysisLoaded(records));
    } catch (e) {
      emit(UrineAnalysisError(e.toString()));
    }
  }

  void resetLoaded() {
    _loadedPatientId = null;
  }

  Future<void> add(UrineAnalysis record) async {
    try {
      final id = await _db.insert('urine_analysis', record.toMap());
      if (state is UrineAnalysisLoaded) {
        final current = (state as UrineAnalysisLoaded).records;
        final updatedRecord = UrineAnalysis(
          id: id,
          patientId: record.patientId,
          date: record.date,
          note: record.note,
          createdAt: record.createdAt,
        );
        emit(UrineAnalysisLoaded([updatedRecord, ...current]));
      }
    } catch (e) {
      emit(UrineAnalysisError(e.toString()));
    }
  }

  Future<void> delete(int id) async {
    try {
      await _db.delete('urine_analysis', id);
      if (state is UrineAnalysisLoaded) {
        final current = (state as UrineAnalysisLoaded).records;
        emit(UrineAnalysisLoaded(current.where((r) => r.id != id).toList()));
      }
    } catch (e) {
      emit(UrineAnalysisError(e.toString()));
    }
  }

  void reset() {
    emit(UrineAnalysisInitial());
  }
}
