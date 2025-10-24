import 'package:clinic/core/models/cu_profile.dart';
import 'package:clinic/core/services/sql_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'cu_profile_state.dart';

class CuProfileCubit extends Cubit<CuProfileState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  CuProfileCubit() : super(CuProfileInitial());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    if (!force && _loadedPatientId == pid && state is CuProfileLoaded) return;
    _loadedPatientId = pid;

    try {
      emit(CuProfileLoading());
      if (!_tableCreated) {
        await _db.createTableWithAttributes('cu_profile', [
          'patient_id', 'date', 's_ceruloplasmin', 'urinary_cu_24hrs', 'created_at'
        ]);
        _tableCreated = true;
      }
      final rows = await _db.getAll('cu_profile');
      final records = rows.map((r) => CuProfile.fromMap(r)).where((c) => c.patientId == pid).toList();
      emit(CuProfileLoaded(records));
    } catch (e) {
      emit(CuProfileError(e.toString()));
    }
  }

  void resetLoaded() {
    _loadedPatientId = null;
  }

  Future<void> add(CuProfile record) async {
    try {
      final id = await _db.insert('cu_profile', record.toMap());
      if (state is CuProfileLoaded) {
        final current = (state as CuProfileLoaded).records;
        final updatedRecord = CuProfile(
          id: id,
          patientId: record.patientId,
          date: record.date,
          sCeruloplasmin: record.sCeruloplasmin,
          urinaryCu24hrs: record.urinaryCu24hrs,
          createdAt: record.createdAt,
        );
        emit(CuProfileLoaded([updatedRecord, ...current]));
      }
    } catch (e) {
      emit(CuProfileError(e.toString()));
    }
  }

  Future<void> delete(int id) async {
    try {
      await _db.delete('cu_profile', id);
      if (state is CuProfileLoaded) {
        final current = (state as CuProfileLoaded).records;
        emit(CuProfileLoaded(current.where((r) => r.id != id).toList()));
      }
    } catch (e) {
      emit(CuProfileError(e.toString()));
    }
  }

  void reset() {
    emit(CuProfileInitial());
  }
}
