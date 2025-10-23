import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/drug.dart';
import 'package:clinic/core/services/sql_service.dart';

class DrugState {
  final bool isLoading;
  final List<Drug> list;

  DrugState({this.isLoading = false, this.list = const []});

  DrugState copyWith({bool? isLoading, List<Drug>? list}) => DrugState(isLoading: isLoading ?? this.isLoading, list: list ?? this.list);
}

class DrugCubit extends Cubit<DrugState> {
  final DatabaseService _db = DatabaseService();

  DrugCubit() : super(DrugState());

  Future<void> loadForPatient(int patientId) async {
    emit(state.copyWith(isLoading: true));
    await _db.createTableWithAttributes('drugs', ['patient_id','name','dose','frequency','duration_days','created_at']);
    final rows = await _db.getAll('drugs');
    final all = rows.map((r) => Drug.fromMap(r)).where((d) => d.patientId == patientId).toList();
    emit(state.copyWith(isLoading: false, list: all));
  }

  Future<void> add(Drug d) async {
    final id = await _db.insert('drugs', d.toMap());
    d.id = id;
    emit(state.copyWith(list: [d, ...state.list]));
  }

  Future<void> remove(int id) async {
    await _db.delete('drugs', id);
    emit(state.copyWith(list: state.list.where((d) => d.id != id).toList()));
  }
}
