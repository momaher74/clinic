import 'package:bloc/bloc.dart';
import 'package:clinic/core/models/patient_history.dart';
import 'package:clinic/core/services/sql_service.dart';

class PatientHistoryState {
  final bool isLoading;
  final PatientHistory? history;
  final List<PatientHistory> list;

  PatientHistoryState({this.isLoading = false, this.history, this.list = const []});

  PatientHistoryState copyWith({bool? isLoading, PatientHistory? history, List<PatientHistory>? list}) =>
      PatientHistoryState(isLoading: isLoading ?? this.isLoading, history: history ?? this.history, list: list ?? this.list);
}

class PatientHistoryCubit extends Cubit<PatientHistoryState> {
  final DatabaseService _db = DatabaseService();

  PatientHistoryCubit() : super(PatientHistoryState());

  Future<void> loadForPatient(int patientId) async {
    emit(state.copyWith(isLoading: true));
    await _db.createTableWithAttributes('patient_history', ['patient_id','occupation','alcohol','offspring','smoking','marital_status','allergy','bilharziasis','hepatitis','created_at']);
    final rows = await _db.getAll('patient_history');
    final all = rows.map((r) => PatientHistory.fromMap(r)).where((h) => h.patientId == patientId).toList();
    emit(state.copyWith(isLoading: false, list: all, history: all.isNotEmpty ? all.first : null));
  }

  Future<void> add(PatientHistory h) async {
    final id = await _db.insert('patient_history', h.toMap());
    h.id = id;
    final newList = [h, ...state.list];
    emit(state.copyWith(list: newList, history: h));
  }
}
