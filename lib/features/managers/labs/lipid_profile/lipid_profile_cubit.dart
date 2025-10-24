import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/lipid_profile.dart';
import 'package:clinic/core/services/sql_service.dart';

class LipidProfileState {
  final List<LipidProfile> list;
  final bool isLoading;

  LipidProfileState({this.list = const [], this.isLoading = false});

  LipidProfileState copyWith({List<LipidProfile>? list, bool? isLoading}) {
    return LipidProfileState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LipidProfileCubit extends Cubit<LipidProfileState> {
  LipidProfileCubit() : super(LipidProfileState());

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
        await _db.createTableWithAttributes('lipid_profile', ['patient_id', 'date', 'cholest', 'tg', 'ldl', 'hdl', 'vldl', 'created_at']);
        _tableCreated = true;
      }
      final db = await _db.database;
      final maps = await db.query(
        'lipid_profile',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'created_at DESC',
      );
      final items = maps.map((m) => LipidProfile.fromMap(m)).toList();
      emit(state.copyWith(list: items, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> add(LipidProfile item) async {
    try {
      final db = await _db.database;
      final id = await db.insert('lipid_profile', item.toMap());
      final updated = LipidProfile(
        id: id,
        patientId: item.patientId,
        date: item.date,
        cholest: item.cholest,
        tg: item.tg,
        ldl: item.ldl,
        hdl: item.hdl,
        vldl: item.vldl,
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
      await db.delete('lipid_profile', where: 'id = ?', whereArgs: [id]);
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
