import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/disease.dart';
import 'package:clinic/core/services/sql_service.dart';

class DiseaseState {
  final bool isLoading;
  final List<DiseaseStatus> list;

  DiseaseState({this.isLoading = false, this.list = const []});

  DiseaseState copyWith({bool? isLoading, List<DiseaseStatus>? list}) => DiseaseState(isLoading: isLoading ?? this.isLoading, list: list ?? this.list);
}

class DiseaseCubit extends Cubit<DiseaseState> {
  final DatabaseService _db = DatabaseService();

  DiseaseCubit() : super(DiseaseState());

  Future<void> loadForPatient(int patientId) async {
    emit(state.copyWith(isLoading: true));
    await _db.createTableWithAttributes('diseases', ['patient_id','dm','htn','notes','created_at']);
    final rows = await _db.getAll('diseases');
    final all = rows.map((r) => DiseaseStatus.fromMap(r)).where((d) => d.patientId == patientId).toList();
    emit(state.copyWith(isLoading: false, list: all));
  }

  Future<void> add(DiseaseStatus d) async {
    final id = await _db.insert('diseases', d.toMap());
    d.id = id;
    emit(state.copyWith(list: [d, ...state.list]));
  }

  Future<void> remove(int id) async {
    await _db.delete('diseases', id);
    emit(state.copyWith(list: state.list.where((d) => d.id != id).toList()));
  }
}
