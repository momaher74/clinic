import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/kidney_function_test.dart';
import 'package:clinic/core/services/sql_service.dart';

class KidneyFunctionTestState {
  final List<KidneyFunctionTest> list;
  final bool isLoading;

  KidneyFunctionTestState({this.list = const [], this.isLoading = false});

  KidneyFunctionTestState copyWith({List<KidneyFunctionTest>? list, bool? isLoading}) {
    return KidneyFunctionTestState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class KidneyFunctionTestCubit extends Cubit<KidneyFunctionTestState> {
  KidneyFunctionTestCubit() : super(KidneyFunctionTestState());

  final DatabaseService _db = DatabaseService();
  int? _currentPatientId;
  bool _loaded = false;
  bool _tableCreated = false;

  Future<void> loadForPatient(int patientId, {bool force = false}) async {
    log("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
    if (_currentPatientId == patientId && _loaded && !force) return;
    _currentPatientId = patientId;
    _loaded = true;

    emit(state.copyWith(isLoading: true));
    try {
      if (!_tableCreated) {
        await _db.createTableWithAttributes('kidney_function_test', ['patient_id', 'date', 's_creatinine', 'urea', 'ua', 'na', 'k', 'ca', 'mg', 'po4', 'pth', 'created_at']);
        _tableCreated = true;
      }
      final db = await _db.database;
      final maps = await db.query(
        'kidney_function_test',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'created_at DESC',
      );
      final items = maps.map((m) => KidneyFunctionTest.fromMap(m)).toList();
      log('Loaded ${items.length} kidney function tests for patient $patientId');
      log(items.toString());
      emit(state.copyWith(list: items, isLoading: false));
    } catch (e, st) {
      log('Error loading kidney function tests for patient $patientId: $e');
      log(st.toString());
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> add(KidneyFunctionTest item) async {
    try {
      final db = await _db.database;
      final id = await db.insert('kidney_function_test', item.toMap());
      final updated = KidneyFunctionTest(
        id: id,
        patientId: item.patientId,
        date: item.date,
        sCreatinine: item.sCreatinine,
        urea: item.urea,
        ua: item.ua,
        na: item.na,
        k: item.k,
        ca: item.ca,
        mg: item.mg,
        po4: item.po4,
        pth: item.pth,
        createdAt: item.createdAt,
      );
      emit(state.copyWith(list: [updated, ...state.list]));
    } catch (e, st) {
      log('Error adding kidney function test: $e');
      log(st.toString());
    }
  }

  Future<void> delete(int id) async {
    try {
      final db = await _db.database;
      await db.delete('kidney_function_test', where: 'id = ?', whereArgs: [id]);
      emit(state.copyWith(list: state.list.where((c) => c.id != id).toList()));
    } catch (e, st) {
      log('Error deleting kidney function test id $id: $e');
      log(st.toString());
    }
  }

  void resetLoaded() {
    _loaded = false;
    _currentPatientId = null;
    emit(state.copyWith(list: [], isLoading: false));
  }
}
