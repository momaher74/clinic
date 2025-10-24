import 'package:clinic/core/models/pregnancy_test.dart';
import 'package:clinic/core/services/sql_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'pregnancy_test_state.dart';

class PregnancyTestCubit extends Cubit<PregnancyTestState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  PregnancyTestCubit() : super(PregnancyTestInitial());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    if (!force && _loadedPatientId == pid && state is PregnancyTestLoaded) return;
    _loadedPatientId = pid;

    try {
      emit(PregnancyTestLoading());
      if (!_tableCreated) {
        await _db.createTableWithAttributes('pregnancy_test', [
          'patient_id', 'date', 'bhcg', 'created_at'
        ]);
        _tableCreated = true;
      }
      final rows = await _db.getAll('pregnancy_test');
      final records = rows.map((r) => PregnancyTest.fromMap(r)).where((c) => c.patientId == pid).toList();
      emit(PregnancyTestLoaded(records));
    } catch (e) {
      emit(PregnancyTestError(e.toString()));
    }
  }

  void resetLoaded() {
    _loadedPatientId = null;
  }

  Future<void> add(PregnancyTest record) async {
    try {
      final id = await _db.insert('pregnancy_test', record.toMap());
      if (state is PregnancyTestLoaded) {
        final current = (state as PregnancyTestLoaded).records;
        final updatedRecord = PregnancyTest(
          id: id,
          patientId: record.patientId,
          date: record.date,
          bhcg: record.bhcg,
          createdAt: record.createdAt,
        );
        emit(PregnancyTestLoaded([updatedRecord, ...current]));
      }
    } catch (e) {
      emit(PregnancyTestError(e.toString()));
    }
  }

  Future<void> delete(int id) async {
    try {
      await _db.delete('pregnancy_test', id);
      if (state is PregnancyTestLoaded) {
        final current = (state as PregnancyTestLoaded).records;
        emit(PregnancyTestLoaded(current.where((r) => r.id != id).toList()));
      }
    } catch (e) {
      emit(PregnancyTestError(e.toString()));
    }
  }

  void reset() {
    emit(PregnancyTestInitial());
  }
}
