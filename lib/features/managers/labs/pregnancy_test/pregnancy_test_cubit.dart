import 'package:clinic/core/models/pregnancy_test.dart';
import 'package:clinic/core/services/sql_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PregnancyTestState {
  final bool isLoading;
  final String? error;
  final List<PregnancyTest> list;

  PregnancyTestState({this.isLoading = false, this.error, this.list = const []});

  PregnancyTestState copyWith({bool? isLoading, String? error, List<PregnancyTest>? list}) =>
      PregnancyTestState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, list: list ?? this.list);
}

class PregnancyTestCubit extends Cubit<PregnancyTestState> {
  final DatabaseService _db = DatabaseService();
  int? _loadedPatientId;
  bool _tableCreated = false;

  PregnancyTestCubit() : super(PregnancyTestState());

  Future<void> loadForPatient(int pid, {bool force = false}) async {
    if (!force && _loadedPatientId == pid && state.list.isNotEmpty) return;
    _loadedPatientId = pid;

    emit(state.copyWith(isLoading: true));
    if (!_tableCreated) {
      await _db.createTableWithAttributes('pregnancy_test', [
        'patient_id', 'date', 'bhcg', 'created_at'
      ]);
      _tableCreated = true;
    }
    final rows = await _db.getAll('pregnancy_test');
    final all = rows.map((r) => PregnancyTest.fromMap(r)).where((c) => c.patientId == pid).toList();
    emit(state.copyWith(isLoading: false, list: all));
  }

  void resetLoaded() {
    _loadedPatientId = null;
  }

  Future<void> add(PregnancyTest c) async {
    final id = await _db.insert('pregnancy_test', c.toMap());
    final updatedRecord = PregnancyTest(
      id: id,
      patientId: c.patientId,
      date: c.date,
      bhcg: c.bhcg,
      createdAt: c.createdAt,
    );
    final newList = [updatedRecord, ...state.list];
    emit(state.copyWith(list: newList));
  }

  Future<void> delete(int id) async {
    await _db.delete('pregnancy_test', id);
    final newList = List<PregnancyTest>.from(state.list)..removeWhere((c) => c.id == id);
    emit(state.copyWith(list: newList));
  }
}
