import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/stool_tests.dart';
import 'package:clinic/core/services/sql_service.dart';

class StoolTestsState {
  final bool isLoading;
  final String? error;
  final List<StoolTests> list;

  StoolTestsState({this.isLoading = false, this.error, this.list = const []});

  StoolTestsState copyWith({bool? isLoading, String? error, List<StoolTests>? list}) =>
      StoolTestsState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, list: list ?? this.list);
}

class StoolTestsCubit extends Cubit<StoolTestsState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  StoolTestsCubit() : super(StoolTestsState());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    if (!force && _loadedPatientId == pid && state.list.isNotEmpty) return;
    _loadedPatientId = pid;

    emit(state.copyWith(isLoading: true));
    if (!_tableCreated) {
      await _db.createTableWithAttributes('stool_tests', [
        'patient_id', 'date', 'occult_in_stool', 'h_pylori_ag_in_stool', 'fecal_calprotectin', 'stool_analysis', 'fit_test', 'created_at'
      ]);
      _tableCreated = true;
    }
    final rows = await _db.getAll('stool_tests');
    final all = rows.map((r) => StoolTests.fromMap(r)).where((c) => c.patientId == pid).toList();
    emit(state.copyWith(isLoading: false, list: all));
  }

  void resetLoaded() {
    _loadedPatientId = null;
  }

  Future<void> add(StoolTests c) async {
    final id = await _db.insert('stool_tests', c.toMap());
    final updatedRecord = StoolTests(
      id: id,
      patientId: c.patientId,
      date: c.date,
      occultInStool: c.occultInStool,
      hPyloriAgInStool: c.hPyloriAgInStool,
      fecalCalprotectin: c.fecalCalprotectin,
      stoolAnalysis: c.stoolAnalysis,
      fitTest: c.fitTest,
      createdAt: c.createdAt,
    );
    final newList = [updatedRecord, ...state.list];
    emit(state.copyWith(list: newList));
  }

  Future<void> delete(int id) async {
    await _db.delete('stool_tests', id);
    final newList = List<StoolTests>.from(state.list)..removeWhere((c) => c.id == id);
    emit(state.copyWith(list: newList));
  }
}
