import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/cbc.dart';
import 'package:clinic/core/services/sql_service.dart';

class CbcState {
  final bool isLoading;
  final String? error;
  final List<Cbc> list;

  CbcState({this.isLoading = false, this.error, this.list = const []});

  CbcState copyWith({bool? isLoading, String? error, List<Cbc>? list}) =>
      CbcState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, list: list ?? this.list);
}

class CbcCubit extends Cubit<CbcState> {
  final DatabaseService _db = DatabaseService();

  CbcCubit() : super(CbcState());

  Future<void> loadForPatient(int pid) async {
    emit(state.copyWith(isLoading: true));
    await _db.createTableWithAttributes('cbc', ['patient_id','date','hb','rbcs','mcv','mch','tlc','neut','lymph','mono','eos','baso','ptt','created_at']);
    final rows = await _db.getAll('cbc');
    final all = rows.map((r) => Cbc.fromMap(r)).where((c) => c.patientId == pid).toList();
    emit(state.copyWith(isLoading: false, list: all));
  }

  Future<void> add(Cbc c) async {
    final id = await _db.insert('cbc', c.toMap());
    c.id = id;
    final newList = [c, ...state.list];
    emit(state.copyWith(list: newList));
  }

  Future<void> delete(int id) async {
    await _db.delete('cbc', id);
    final newList = List<Cbc>.from(state.list)..removeWhere((c) => c.id == id);
    emit(state.copyWith(list: newList));
  }
}
