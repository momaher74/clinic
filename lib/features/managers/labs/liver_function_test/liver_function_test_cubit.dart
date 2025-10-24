import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/liver_function_test.dart';
import 'package:clinic/core/services/sql_service.dart';

class LiverFunctionTestState {
  final List<LiverFunctionTest> list;
  final bool isLoading;

  LiverFunctionTestState({this.list = const [], this.isLoading = false});

  LiverFunctionTestState copyWith({List<LiverFunctionTest>? list, bool? isLoading}) {
    return LiverFunctionTestState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LiverFunctionTestCubit extends Cubit<LiverFunctionTestState> {
  LiverFunctionTestCubit() : super(LiverFunctionTestState());

  final DatabaseService _db = DatabaseService();
  int? _currentPatientId;
  bool _loaded = false;
  bool _tableCreated = false;

  Future<void> loadForPatient(int patientId, {bool force = false}) async {
    if (_currentPatientId == patientId && _loaded && !force) return;
    _currentPatientId = patientId;
    _loaded = true;

    emit(state.copyWith(isLoading: true));
    try {
      if (!_tableCreated) {
        await _db.createTableWithAttributes('liver_function_test', ['patient_id', 'date', 'tbill', 'dbill', 'tp', 'salb', 'alt', 'ast', 'alp', 'ggt', 'created_at']);
        _tableCreated = true;
      }
      final db = await _db.database;
      final maps = await db.query(
        'liver_function_test',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'created_at DESC',
      );
      final items = maps.map((m) => LiverFunctionTest.fromMap(m)).toList();
      emit(state.copyWith(list: items, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> add(LiverFunctionTest item) async {
    try {
      final db = await _db.database;
      final id = await db.insert('liver_function_test', item.toMap());
      final updated = LiverFunctionTest(
        id: id,
        patientId: item.patientId,
        date: item.date,
        tbill: item.tbill,
        dbill: item.dbill,
        tp: item.tp,
        salb: item.salb,
        alt: item.alt,
        ast: item.ast,
        alp: item.alp,
        ggt: item.ggt,
        createdAt: item.createdAt,
      );
      emit(state.copyWith(list: [updated, ...state.list]));
    } catch (e) {
      // handle error
    }
  }

  Future<void> delete(int id) async {
    try {
      final db = await _db.database;
      await db.delete('liver_function_test', where: 'id = ?', whereArgs: [id]);
      emit(state.copyWith(list: state.list.where((c) => c.id != id).toList()));
    } catch (e) {
      // handle error
    }
  }

  void resetLoaded() {
    _loaded = false;
    _currentPatientId = null;
    emit(state.copyWith(list: [], isLoading: false));
  }
}
