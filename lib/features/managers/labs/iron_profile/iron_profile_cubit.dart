import 'package:clinic/core/models/iron_profile.dart';
import 'package:clinic/core/services/sql_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'iron_profile_state.dart';

class IronProfileCubit extends Cubit<IronProfileState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  IronProfileCubit() : super(IronProfileInitial());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    if (!force && _loadedPatientId == pid && state is IronProfileLoaded) return;
    _loadedPatientId = pid;

    try {
      emit(IronProfileLoading());
      if (!_tableCreated) {
        await _db.createTableWithAttributes('iron_profile', [
          'patient_id', 'date', 's_iron', 's_ferritin', 'f_transferrin_sat', 'tibc', 'created_at'
        ]);
        _tableCreated = true;
      }
      final rows = await _db.getAll('iron_profile');
      final records = rows.map((r) => IronProfile.fromMap(r)).where((c) => c.patientId == pid).toList();
      emit(IronProfileLoaded(records));
    } catch (e) {
      emit(IronProfileError(e.toString()));
    }
  }

  void resetLoaded() {
    _loadedPatientId = null;
  }

  Future<void> add(IronProfile record) async {
    try {
      final id = await _db.insert('iron_profile', record.toMap());
      if (state is IronProfileLoaded) {
        final current = (state as IronProfileLoaded).records;
        final updatedRecord = IronProfile(
          id: id,
          patientId: record.patientId,
          date: record.date,
          sIron: record.sIron,
          sFerritin: record.sFerritin,
          fTransferrinSat: record.fTransferrinSat,
          tibc: record.tibc,
          createdAt: record.createdAt,
        );
        emit(IronProfileLoaded([updatedRecord, ...current]));
      }
    } catch (e) {
      emit(IronProfileError(e.toString()));
    }
  }

  Future<void> delete(int id) async {
    try {
      await _db.delete('iron_profile', id);
      if (state is IronProfileLoaded) {
        final current = (state as IronProfileLoaded).records;
        emit(IronProfileLoaded(current.where((r) => r.id != id).toList()));
      }
    } catch (e) {
      emit(IronProfileError(e.toString()));
    }
  }

  void reset() {
    emit(IronProfileInitial());
  }
}
