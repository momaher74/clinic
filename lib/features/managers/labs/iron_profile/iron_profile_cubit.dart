import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/iron_profile.dart';
import 'package:clinic/core/services/sql_service.dart';

class IronProfileState {
  final bool isLoading;
  final String? error;
  final List<IronProfile> list;

  IronProfileState({this.isLoading = false, this.error, this.list = const []});

  IronProfileState copyWith({bool? isLoading, String? error, List<IronProfile>? list}) =>
      IronProfileState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, list: list ?? this.list);
}

class IronProfileCubit extends Cubit<IronProfileState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  IronProfileCubit() : super(IronProfileState());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    if (!force && _loadedPatientId == pid && state.list.isNotEmpty) return;
    _loadedPatientId = pid;

    emit(state.copyWith(isLoading: true));
    if (!_tableCreated) {
      await _db.createTableWithAttributes('iron_profile', [
        'patient_id', 'date', 's_iron', 's_ferritin', 'f_transferrin_sat', 'tibc', 'created_at'
      ]);
      _tableCreated = true;
    }
    final rows = await _db.getAll('iron_profile');
    final all = rows.map((r) => IronProfile.fromMap(r)).where((c) => c.patientId == pid).toList();
    emit(state.copyWith(isLoading: false, list: all));
  }

  void resetLoaded() {
    _loadedPatientId = null;
  }

  Future<void> add(IronProfile c) async {
    final id = await _db.insert('iron_profile', c.toMap());
    final updatedRecord = IronProfile(
      id: id,
      patientId: c.patientId,
      date: c.date,
      sIron: c.sIron,
      sFerritin: c.sFerritin,
      fTransferrinSat: c.fTransferrinSat,
      tibc: c.tibc,
      createdAt: c.createdAt,
    );
    final newList = [updatedRecord, ...state.list];
    emit(state.copyWith(list: newList));
  }

  Future<void> delete(int id) async {
    await _db.delete('iron_profile', id);
    final newList = List<IronProfile>.from(state.list)..removeWhere((c) => c.id == id);
    emit(state.copyWith(list: newList));
  }
}
