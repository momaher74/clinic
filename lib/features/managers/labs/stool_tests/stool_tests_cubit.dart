import 'package:clinic/core/models/stool_tests.dart';
import 'package:clinic/core/services/sql_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'stool_tests_state.dart';

class StoolTestsCubit extends Cubit<StoolTestsState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  StoolTestsCubit() : super(StoolTestsInitial());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    if (!force && _loadedPatientId == pid && state is StoolTestsLoaded) return;
    _loadedPatientId = pid;

    try {
      emit(StoolTestsLoading());
      if (!_tableCreated) {
        await _db.createTableWithAttributes('stool_tests', [
          'patient_id', 'date', 'occult_in_stool', 'h_pylori_ag_in_stool', 'fecal_calprotectin', 'stool_analysis', 'fit_test', 'created_at'
        ]);
        _tableCreated = true;
      }
      final rows = await _db.getAll('stool_tests');
      final records = rows.map((r) => StoolTests.fromMap(r)).where((c) => c.patientId == pid).toList();
      emit(StoolTestsLoaded(records));
    } catch (e) {
      emit(StoolTestsError(e.toString()));
    }
  }

  void resetLoaded() {
    _loadedPatientId = null;
  }

  Future<void> add(StoolTests record) async {
    try {
      final id = await _db.insert('stool_tests', record.toMap());
      if (state is StoolTestsLoaded) {
        final current = (state as StoolTestsLoaded).records;
        final updatedRecord = StoolTests(
          id: id,
          patientId: record.patientId,
          date: record.date,
          occultInStool: record.occultInStool,
          hPyloriAgInStool: record.hPyloriAgInStool,
          fecalCalprotectin: record.fecalCalprotectin,
          stoolAnalysis: record.stoolAnalysis,
          fitTest: record.fitTest,
          createdAt: record.createdAt,
        );
        emit(StoolTestsLoaded([updatedRecord, ...current]));
      }
    } catch (e) {
      emit(StoolTestsError(e.toString()));
    }
  }

  Future<void> delete(int id) async {
    try {
      await _db.delete('stool_tests', id);
      if (state is StoolTestsLoaded) {
        final current = (state as StoolTestsLoaded).records;
        emit(StoolTestsLoaded(current.where((r) => r.id != id).toList()));
      }
    } catch (e) {
      emit(StoolTestsError(e.toString()));
    }
  }

  void reset() {
    emit(StoolTestsInitial());
  }
}
