import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/cu_profile.dart';
import 'package:clinic/core/services/sql_service.dart';

class CuProfileState {
  final bool isLoading;
  final String? error;
  final List<CuProfile> list;

  CuProfileState({this.isLoading = false, this.error, this.list = const []});

  CuProfileState copyWith({bool? isLoading, String? error, List<CuProfile>? list}) =>
      CuProfileState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, list: list ?? this.list);
}

class CuProfileCubit extends Cubit<CuProfileState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  CuProfileCubit() : super(CuProfileState());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    if (!force && _loadedPatientId == pid && state.list.isNotEmpty) return;
    _loadedPatientId = pid;

    emit(state.copyWith(isLoading: true));
    if (!_tableCreated) {
      await _db.createTableWithAttributes('cu_profile', [
        'patient_id', 'date', 's_ceruloplasmin', 'urinary_cu_24hrs', 'created_at'
      ]);
      _tableCreated = true;
    }
    final rows = await _db.getAll('cu_profile');
    final all = rows.map((r) => CuProfile.fromMap(r)).where((c) => c.patientId == pid).toList();
    emit(state.copyWith(isLoading: false, list: all));
  }

  void resetLoaded() {
    _loadedPatientId = null;
  }

  Future<void> add(CuProfile c) async {
    final id = await _db.insert('cu_profile', c.toMap());
    final updatedRecord = CuProfile(
      id: id,
      patientId: c.patientId,
      date: c.date,
      sCeruloplasmin: c.sCeruloplasmin,
      urinaryCu24hrs: c.urinaryCu24hrs,
      createdAt: c.createdAt,
    );
    final newList = [updatedRecord, ...state.list];
    emit(state.copyWith(list: newList));
  }

  Future<void> delete(int id) async {
    await _db.delete('cu_profile', id);
    final newList = List<CuProfile>.from(state.list)..removeWhere((c) => c.id == id);
    emit(state.copyWith(list: newList));
  }
}
