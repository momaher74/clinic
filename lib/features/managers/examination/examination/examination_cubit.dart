import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/features/managers/examination/examination/examination_state.dart';
import 'package:clinic/core/services/sql_service.dart';
import 'package:clinic/core/models/examination.dart';
import 'package:clinic/core/models/request.dart';

class ExaminationCubit extends Cubit<ExaminationState> {
	final DatabaseService _db = DatabaseService();

	ExaminationCubit() : super(ExaminationState(isLoading: true));
	
	Future<void> loadForPatient(int patientId) async {
		final stable = state;
		try {
			emit(state.copyWith(isLoading: true, patientId: patientId));

			await _db.createTableWithAttributes('examinations', ['patient_id','bp','pulse','temp','spo2','other','examination','created_at']);
			await _db.createTableWithAttributes('reqs', ['patient_id','description','created_at']);

			final exRows = await _db.getAll('examinations');
			final rqRows = await _db.getAll('reqs');

			final exList = exRows.map((r) => Examination.fromMap(r)).where((e) => e.patientId == patientId).toList();
			final rqList = rqRows.map((r) => Req.fromMap(r)).where((q) => q.patientId == patientId).toList();

			emit(state.copyWith(isLoading: false, examinations: exList, reqs: rqList, patientId: patientId));
		} catch (e) {
			emit(state.copyWith(error: e.toString()));
			emit(stable.copyWith(isLoading: false));
		}
	}

	Future<void> addExamination(Examination e) async {
		final list = List<Examination>.from(state.examinations);
		final id = await _db.insert('examinations', e.toMap());
		e.id = id;
		list.insert(0, e);
		emit(state.copyWith(examinations: list));
	}

	Future<void> deleteExamination(int id) async {
		await _db.delete('examinations', id);
		final newList = List<Examination>.from(state.examinations)..removeWhere((x) => x.id == id);
		emit(state.copyWith(examinations: newList));
	}

	Future<void> addReq(Req r) async {
		final list = List<Req>.from(state.reqs);
		final id = await _db.insert('reqs', r.toMap());
		r.id = id;
		list.insert(0, r);
		emit(state.copyWith(reqs: list));
	}

	Future<void> deleteReq(int id) async {
		await _db.delete('reqs', id);
		final newList = List<Req>.from(state.reqs)..removeWhere((r) => r.id == id);
		emit(state.copyWith(reqs: newList));
	}
}
