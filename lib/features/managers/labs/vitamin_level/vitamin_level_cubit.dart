import 'package:clinic/core/models/vitamin_level.dart';
import 'package:clinic/core/services/sql_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'vitamin_level_state.dart';

class VitaminLevelCubit extends Cubit<VitaminLevelState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  VitaminLevelCubit() : super(VitaminLevelInitial());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    if (!force && _loadedPatientId == pid && state is VitaminLevelLoaded) return;
    _loadedPatientId = pid;

    try {
      emit(VitaminLevelLoading());
      if (!_tableCreated) {
        await _db.createTableWithAttributes('vitamin_level', [
          'patient_id', 'date', 'vit_d_level', 'vit_b12_level', 'created_at'
        ]);
        _tableCreated = true;
      }
      final rows = await _db.getAll('vitamin_level');
      final records = rows.map((r) => VitaminLevel.fromMap(r)).where((c) => c.patientId == pid).toList();
      emit(VitaminLevelLoaded(records));
    } catch (e) {
      emit(VitaminLevelError(e.toString()));
    }
  }

  void resetLoaded() {
    _loadedPatientId = null;
  }

  Future<void> add(VitaminLevel record) async {
    try {
      final id = await _db.insert('vitamin_level', record.toMap());
      if (state is VitaminLevelLoaded) {
        final current = (state as VitaminLevelLoaded).records;
        final updatedRecord = VitaminLevel(
          id: id,
          patientId: record.patientId,
          date: record.date,
          vitDLevel: record.vitDLevel,
          vitB12Level: record.vitB12Level,
          createdAt: record.createdAt,
        );
        emit(VitaminLevelLoaded([updatedRecord, ...current]));
      }
    } catch (e) {
      emit(VitaminLevelError(e.toString()));
    }
  }

  Future<void> delete(int id) async {
    try {
      await _db.delete('vitamin_level', id);
      if (state is VitaminLevelLoaded) {
        final current = (state as VitaminLevelLoaded).records;
        emit(VitaminLevelLoaded(current.where((r) => r.id != id).toList()));
      }
    } catch (e) {
      emit(VitaminLevelError(e.toString()));
    }
  }

  void reset() {
    emit(VitaminLevelInitial());
  }
}
