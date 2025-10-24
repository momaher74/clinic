import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/autoimmune_markers.dart';
import 'package:clinic/core/services/sql_service.dart';

class AutoimmuneMarkersState {
  final List<AutoimmuneMarkers> list;
  final bool isLoading;

  AutoimmuneMarkersState({this.list = const [], this.isLoading = false});

  AutoimmuneMarkersState copyWith({List<AutoimmuneMarkers>? list, bool? isLoading}) {
    return AutoimmuneMarkersState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AutoimmuneMarkersCubit extends Cubit<AutoimmuneMarkersState> {
  AutoimmuneMarkersCubit() : super(AutoimmuneMarkersState());

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
        await _db.createTableWithAttributes('autoimmune_markers', ['patient_id', 'date', 'ana', 'ama', 'asma', 'lkm', 'sla', 'total_igg', 'total_igm', 'anca', 'asca', 'anti_ds_dna', 'c3', 'c4', 'rf', 'anti_ccp', 'created_at']);
        _tableCreated = true;
      }
      final db = await _db.database;
      final maps = await db.query(
        'autoimmune_markers',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'created_at DESC',
      );
      final items = maps.map((m) => AutoimmuneMarkers.fromMap(m)).toList();
      emit(state.copyWith(list: items, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> add(AutoimmuneMarkers item) async {
    try {
      final db = await _db.database;
      final id = await db.insert('autoimmune_markers', item.toMap());
      final updated = AutoimmuneMarkers(
        id: id,
        patientId: item.patientId,
        date: item.date,
        ana: item.ana,
        ama: item.ama,
        asma: item.asma,
        lkm: item.lkm,
        sla: item.sla,
        totalIgG: item.totalIgG,
        totalIgM: item.totalIgM,
        anca: item.anca,
        asca: item.asca,
        antiDsDna: item.antiDsDna,
        c3: item.c3,
        c4: item.c4,
        rf: item.rf,
        antiCcp: item.antiCcp,
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
      await db.delete('autoimmune_markers', where: 'id = ?', whereArgs: [id]);
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
