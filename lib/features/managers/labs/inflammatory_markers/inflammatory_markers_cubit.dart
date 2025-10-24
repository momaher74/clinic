import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/inflammatory_markers.dart';
import 'package:clinic/core/services/sql_service.dart';

class InflammatoryMarkersState {
  final List<InflammatoryMarkers> list;
  final bool isLoading;

  InflammatoryMarkersState({this.list = const [], this.isLoading = false});

  InflammatoryMarkersState copyWith({List<InflammatoryMarkers>? list, bool? isLoading}) {
    return InflammatoryMarkersState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class InflammatoryMarkersCubit extends Cubit<InflammatoryMarkersState> {
  InflammatoryMarkersCubit() : super(InflammatoryMarkersState());

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
        await _db.createTableWithAttributes('inflammatory_markers', ['patient_id', 'date', 'esr', 'crp', 'asot', 'created_at']);
        _tableCreated = true;
      }
      final db = await _db.database;
      final maps = await db.query(
        'inflammatory_markers',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'created_at DESC',
      );
      final items = maps.map((m) => InflammatoryMarkers.fromMap(m)).toList();
      emit(state.copyWith(list: items, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> add(InflammatoryMarkers item) async {
    try {
      final db = await _db.database;
      final id = await db.insert('inflammatory_markers', item.toMap());
      final updated = InflammatoryMarkers(
        id: id,
        patientId: item.patientId,
        date: item.date,
        esr: item.esr,
        crp: item.crp,
        asot: item.asot,
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
      await db.delete('inflammatory_markers', where: 'id = ?', whereArgs: [id]);
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
