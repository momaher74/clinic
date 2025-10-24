import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/urine_analysis.dart';
import 'package:clinic/core/services/sql_service.dart';

class UrineAnalysisState {
  final bool isLoading;
  final String? error;
  final List<UrineAnalysis> list;

  UrineAnalysisState({this.isLoading = false, this.error, this.list = const []});

  UrineAnalysisState copyWith({bool? isLoading, String? error, List<UrineAnalysis>? list}) =>
      UrineAnalysisState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, list: list ?? this.list);
}

class UrineAnalysisCubit extends Cubit<UrineAnalysisState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  UrineAnalysisCubit() : super(UrineAnalysisState());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    if (!force && _loadedPatientId == pid && state.list.isNotEmpty) return;
    _loadedPatientId = pid;

    emit(state.copyWith(isLoading: true));
    if (!_tableCreated) {
      await _db.createTableWithAttributes('urine_analysis', [
        'patient_id', 'date', 'note', 'created_at'
      ]);
      _tableCreated = true;
    }
    final rows = await _db.getAll('urine_analysis');
    final all = rows.map((r) => UrineAnalysis.fromMap(r)).where((c) => c.patientId == pid).toList();
    emit(state.copyWith(isLoading: false, list: all));
  }

  void resetLoaded() {
    _loadedPatientId = null;
  }

  Future<void> add(UrineAnalysis c) async {
    final id = await _db.insert('urine_analysis', c.toMap());
    final updatedRecord = UrineAnalysis(
      id: id,
      patientId: c.patientId,
      date: c.date,
      note: c.note,
      createdAt: c.createdAt,
    );
    final newList = [updatedRecord, ...state.list];
    emit(state.copyWith(list: newList));
  }

  Future<void> delete(int id) async {
    await _db.delete('urine_analysis', id);
    final newList = List<UrineAnalysis>.from(state.list)..removeWhere((c) => c.id == id);
    emit(state.copyWith(list: newList));
  }
}
