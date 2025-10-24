import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/diabetes_labs.dart';
import 'package:clinic/core/services/sql_service.dart';

class DiabetesLabsState {
  final List<DiabetesLabs> list;
  final bool isLoading;

  DiabetesLabsState({this.list = const [], this.isLoading = false});

  DiabetesLabsState copyWith({List<DiabetesLabs>? list, bool? isLoading}) {
    return DiabetesLabsState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DiabetesLabsCubit extends Cubit<DiabetesLabsState> {
  DiabetesLabsCubit() : super(DiabetesLabsState());

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
        await _db.createTableWithAttributes('diabetes_labs', ['patient_id', 'date', 'fbi_glu', 'hrs_pp_bi_glu', 'hba1c', 'c_peptide', 'insulin_level', 'rbs', 'homa_ir', 'created_at']);
        _tableCreated = true;
      }
      final db = await _db.database;
      final maps = await db.query(
        'diabetes_labs',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'created_at DESC',
      );
      final items = maps.map((m) => DiabetesLabs.fromMap(m)).toList();
      emit(state.copyWith(list: items, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> add(DiabetesLabs item) async {
    try {
      final db = await _db.database;
      final id = await db.insert('diabetes_labs', item.toMap());
      final updated = DiabetesLabs(
        id: id,
        patientId: item.patientId,
        date: item.date,
        fbiGlu: item.fbiGlu,
        hrsPpBiGlu: item.hrsPpBiGlu,
        hba1c: item.hba1c,
        cPeptide: item.cPeptide,
        insulinLevel: item.insulinLevel,
        rbs: item.rbs,
        homaIr: item.homaIr,
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
      await db.delete('diabetes_labs', where: 'id = ?', whereArgs: [id]);
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
