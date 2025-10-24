import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/virology.dart';
import 'package:clinic/core/services/sql_service.dart';

class VirologyState {
  final List<Virology> list;
  final bool isLoading;

  VirologyState({this.list = const [], this.isLoading = false});

  VirologyState copyWith({List<Virology>? list, bool? isLoading}) {
    return VirologyState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class VirologyCubit extends Cubit<VirologyState> {
  VirologyCubit() : super(VirologyState());

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
        await _db.createTableWithAttributes('virology', ['patient_id', 'date', 'hav_igm', 'hav_igg', 'hbs_ag', 'hbs_ab', 'hbc_igm', 'hbc_igg', 'hbe_ag', 'hbe_ab', 'hcv_ab', 'hiv_ab_i_ii', 'hbv_dna_pcr', 'hcv_rna_pcr', 'created_at']);
        _tableCreated = true;
      }
      final db = await _db.database;
      final maps = await db.query(
        'virology',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'created_at DESC',
      );

      final items = maps.map((m) => Virology.fromMap(m)).toList();
      emit(state.copyWith(list: items, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> add(Virology item) async {
    try {
      final db = await _db.database;
      final id = await db.insert('virology', item.toMap());
      final updated = Virology(
        id: id,
        patientId: item.patientId,
        date: item.date,
        havIgm: item.havIgm,
        havIgG: item.havIgG,
        hbsAg: item.hbsAg,
        hbsAb: item.hbsAb,
        hbcIgM: item.hbcIgM,
        hbcIgG: item.hbcIgG,
        hbeAg: item.hbeAg,
        hbeAb: item.hbeAb,
        hcvAb: item.hcvAb,
        hivAbI_II: item.hivAbI_II,
        hbvDnaPcr: item.hbvDnaPcr,
        hcvRnaPcr: item.hcvRnaPcr,
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
      await db.delete('virology', where: 'id = ?', whereArgs: [id]);
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
