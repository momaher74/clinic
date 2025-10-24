import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/vitamin_level.dart';
import 'package:clinic/core/services/sql_service.dart';

class VitaminLevelState {
  final bool isLoading;
  final String? error;
  final List<VitaminLevel> list;

  VitaminLevelState({this.isLoading = false, this.error, this.list = const []});

  VitaminLevelState copyWith({bool? isLoading, String? error, List<VitaminLevel>? list}) =>
      VitaminLevelState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, list: list ?? this.list);
}

class VitaminLevelCubit extends Cubit<VitaminLevelState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  VitaminLevelCubit() : super(VitaminLevelState());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    if (!force && _loadedPatientId == pid && state.list.isNotEmpty) return;
    _loadedPatientId = pid;

    emit(state.copyWith(isLoading: true));
    if (!_tableCreated) {
      await _db.createTableWithAttributes('vitamin_level', [
        'patient_id', 'date', 'vit_d_level', 'vit_b12_level', 'created_at'
      ]);
      _tableCreated = true;
    }
    final rows = await _db.getAll('vitamin_level');
    final all = rows.map((r) => VitaminLevel.fromMap(r)).where((c) => c.patientId == pid).toList();
    emit(state.copyWith(isLoading: false, list: all));
  }

  void resetLoaded() {
    _loadedPatientId = null;
  }

  Future<void> add(VitaminLevel c) async {
    final id = await _db.insert('vitamin_level', c.toMap());
    final updatedRecord = VitaminLevel(
      id: id,
      patientId: c.patientId,
      date: c.date,
      vitDLevel: c.vitDLevel,
      vitB12Level: c.vitB12Level,
      createdAt: c.createdAt,
    );
    final newList = [updatedRecord, ...state.list];
    emit(state.copyWith(list: newList));
  }

  Future<void> delete(int id) async {
    await _db.delete('vitamin_level', id);
    final newList = List<VitaminLevel>.from(state.list)..removeWhere((c) => c.id == id);
    emit(state.copyWith(list: newList));
  }
}
