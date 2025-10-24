import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/coagulation_profile.dart';
import 'package:clinic/core/services/sql_service.dart';

class CoagulationProfileState {
  final List<CoagulationProfile> list;
  final bool isLoading;

  CoagulationProfileState({this.list = const [], this.isLoading = false});

  CoagulationProfileState copyWith({List<CoagulationProfile>? list, bool? isLoading}) {
    return CoagulationProfileState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CoagulationProfileCubit extends Cubit<CoagulationProfileState> {
  CoagulationProfileCubit() : super(CoagulationProfileState());

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
        await _db.createTableWithAttributes('coagulation_profile', ['patient_id', 'date', 'pt', 'ptt', 'pc', 'inr', 'created_at']);
        _tableCreated = true;
      }
      final db = await _db.database;
      final maps = await db.query(
        'coagulation_profile',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'created_at DESC',
      );
      final items = maps.map((m) => CoagulationProfile.fromMap(m)).toList();
      emit(state.copyWith(list: items, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> add(CoagulationProfile item) async {
    try {
      log('CoagulationProfileCubit: add called with ${item.toMap()}');
      final db = await _db.database;
      final id = await db.insert('coagulation_profile', item.toMap());
      log('CoagulationProfileCubit: inserted id=$id');
      final updated = CoagulationProfile(
        id: id,
        patientId: item.patientId,
        date: item.date,
        pt: item.pt,
        ptt: item.ptt,
        pc: item.pc,
        inr: item.inr,
        createdAt: item.createdAt,
      );
      emit(state.copyWith(list: [updated, ...state.list]));
    } catch (e, st) {
      log('CoagulationProfileCubit: add error $e');
      log(st.toString());
    }
  }

  Future<void> delete(int id) async {
    try {
      log('CoagulationProfileCubit: delete called for id=$id');
      final db = await _db.database;
      final rows = await db.delete('coagulation_profile', where: 'id = ?', whereArgs: [id]);
      log('CoagulationProfileCubit: rows deleted=$rows');
      emit(state.copyWith(list: state.list.where((c) => c.id != id).toList()));
    } catch (e, st) {
      log('CoagulationProfileCubit: delete error $e');
      log(st.toString());
    }
  }

  void resetLoaded() {
    _loaded = false;
    _currentPatientId = null;
    emit(state.copyWith(list: [], isLoading: false));
  }
}
