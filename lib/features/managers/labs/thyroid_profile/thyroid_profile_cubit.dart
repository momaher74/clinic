import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/thyroid_profile.dart';
import 'package:clinic/core/services/sql_service.dart';

class ThyroidProfileState {
  final List<ThyroidProfile> list;
  final bool isLoading;

  ThyroidProfileState({this.list = const [], this.isLoading = false});

  ThyroidProfileState copyWith({List<ThyroidProfile>? list, bool? isLoading}) {
    return ThyroidProfileState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ThyroidProfileCubit extends Cubit<ThyroidProfileState> {
  ThyroidProfileCubit() : super(ThyroidProfileState());

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
        await _db.createTableWithAttributes('thyroid_profile', ['patient_id', 'date', 'tsh', 'ft3', 'ft4', 'anti_tpo_ab', 'anti_tg_ab', 'anti_tshr_ab', 'created_at']);
        _tableCreated = true;
      }
      final db = await _db.database;
      final maps = await db.query(
        'thyroid_profile',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'created_at DESC',
      );
      final items = maps.map((m) => ThyroidProfile.fromMap(m)).toList();
      emit(state.copyWith(list: items, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> add(ThyroidProfile item) async {
    try {
      final db = await _db.database;
      final id = await db.insert('thyroid_profile', item.toMap());
      final updated = ThyroidProfile(
        id: id,
        patientId: item.patientId,
        date: item.date,
        tsh: item.tsh,
        ft3: item.ft3,
        ft4: item.ft4,
        antiTpoAb: item.antiTpoAb,
        antiTgAb: item.antiTgAb,
        antiTshrAb: item.antiTshrAb,
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
      await db.delete('thyroid_profile', where: 'id = ?', whereArgs: [id]);
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
