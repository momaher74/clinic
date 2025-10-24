import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/pancreatic_enzymes.dart';
import 'package:clinic/core/services/sql_service.dart';

class PancreaticEnzymesState {
  final List<PancreaticEnzymes> list;
  final bool isLoading;

  PancreaticEnzymesState({this.list = const [], this.isLoading = false});

  PancreaticEnzymesState copyWith({List<PancreaticEnzymes>? list, bool? isLoading}) {
    return PancreaticEnzymesState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PancreaticEnzymesCubit extends Cubit<PancreaticEnzymesState> {
  PancreaticEnzymesCubit() : super(PancreaticEnzymesState());

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
        await _db.createTableWithAttributes('pancreatic_enzymes', ['patient_id', 'date', 's_amylase', 's_lipase', 'created_at']);
        _tableCreated = true;
      }
      final db = await _db.database;
      final maps = await db.query(
        'pancreatic_enzymes',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'created_at DESC',
      );
      final items = maps.map((m) => PancreaticEnzymes.fromMap(m)).toList();
      emit(state.copyWith(list: items, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> add(PancreaticEnzymes item) async {
    try {
      final db = await _db.database;
      final id = await db.insert('pancreatic_enzymes', item.toMap());
      final updated = PancreaticEnzymes(
        id: id,
        patientId: item.patientId,
        date: item.date,
        sAmylase: item.sAmylase,
        sLipase: item.sLipase,
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
      await db.delete('pancreatic_enzymes', where: 'id = ?', whereArgs: [id]);
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
