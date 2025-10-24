import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/celiac_disease_labs.dart';
import 'package:clinic/core/services/sql_service.dart';

class CeliacDiseaseLabsState {
  final List<CeliacDiseaseLabs> list;
  final bool isLoading;

  CeliacDiseaseLabsState({this.list = const [], this.isLoading = false});

  CeliacDiseaseLabsState copyWith({List<CeliacDiseaseLabs>? list, bool? isLoading}) {
    return CeliacDiseaseLabsState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CeliacDiseaseLabsCubit extends Cubit<CeliacDiseaseLabsState> {
  CeliacDiseaseLabsCubit() : super(CeliacDiseaseLabsState());

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
        await _db.createTableWithAttributes('celiac_disease_labs', ['patient_id', 'date', 'aga_iga', 'aga_igg', 'ema_iga', 'ttg_iga', 'ttg_igg', 'dgp_iga', 'dgp_igg', 'total_iga', 'created_at']);
        _tableCreated = true;
      }
      final db = await _db.database;
      final maps = await db.query(
        'celiac_disease_labs',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'created_at DESC',
      );
      final items = maps.map((m) => CeliacDiseaseLabs.fromMap(m)).toList();
      emit(state.copyWith(list: items, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> add(CeliacDiseaseLabs item) async {
    try {
      final db = await _db.database;
      final id = await db.insert('celiac_disease_labs', item.toMap());
      final updated = CeliacDiseaseLabs(
        id: id,
        patientId: item.patientId,
        date: item.date,
        agaIgA: item.agaIgA,
        agaIgG: item.agaIgG,
        emaIgA: item.emaIgA,
        ttgIgA: item.ttgIgA,
        ttgIgG: item.ttgIgG,
        dgpIgA: item.dgpIgA,
        dgpIgG: item.dgpIgG,
        totalIgA: item.totalIgA,
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
      await db.delete('celiac_disease_labs', where: 'id = ?', whereArgs: [id]);
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
