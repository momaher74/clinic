import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/features/managers/add_user/add_user/patient_state.dart';
import 'package:clinic/core/services/sql_service.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientCubit extends Cubit<PatientState> {
	final DatabaseService _db = DatabaseService();

	PatientCubit() : super(PatientState());

	Future<void> loadPatients() async {
		emit(state.copyWith(isLoading: true, error: null));
		try {
			await _db.createTableWithAttributes('patients', ['name','birthdate','age','sex','residency','mobile','note']);
			final rows = await _db.getAll('patients');
			final list = rows.map((r) => Patient.fromMap(r)).toList();
			await loadSelectedIds();
			emit(state.copyWith(isLoading: false, patients: list, filtered: list));
		} catch (e) {
			emit(state.copyWith(isLoading: false, error: e.toString()));
		}
	}

	Future<void> addPatient(Patient p) async {
		emit(state.copyWith(isLoading: true));
		try {
			final id = await _db.insert('patients', p.toMap());
			p.id = id;
			final newList = [p, ...state.patients];
			emit(state.copyWith(isLoading: false, patients: newList, filtered: _applyQuery(newList, state.query)));
		} catch (e) {
			emit(state.copyWith(isLoading: false, error: e.toString()));
		}
	}

	Future<void> deletePatient(int id) async {
		emit(state.copyWith(isLoading: true));
		try {
			await _db.delete('patients', id);
			final newList = List<Patient>.from(state.patients)..removeWhere((p) => p.id == id);
			emit(state.copyWith(isLoading: false, patients: newList, filtered: _applyQuery(newList, state.query)));
		} catch (e) {
			emit(state.copyWith(isLoading: false, error: e.toString()));
		}
	}

	void toggleSelection(int id) async {
		// Enforce single-selection: select the id or deselect if already selected
		final newSelected = <int>{};
		if (!state.selectedIds.contains(id)) {
			newSelected.add(id);
		}
		emit(state.copyWith(selectedIds: newSelected));
		final prefs = await SharedPreferences.getInstance();
		await prefs.setStringList('selected_patient_ids', newSelected.map((i) => i.toString()).toList());
	}

	void search(String q) {
		emit(state.copyWith(query: q, filtered: _applyQuery(state.patients, q)));
	}

	List<Patient> _applyQuery(List<Patient> list, String q) {
		final query = q.toLowerCase().trim();
		if (query.isEmpty) return List.of(list);
		return list.where((p) {
			return p.name.toLowerCase().contains(query) || p.mobile.toLowerCase().contains(query) || p.residency.toLowerCase().contains(query);
		}).toList();
	}

	Future<void> loadSelectedIds() async {
		final prefs = await SharedPreferences.getInstance();
		final selected = prefs.getStringList('selected_patient_ids') ?? [];
		final ids = selected.map((s) => int.tryParse(s)).whereType<int>().toSet();
		emit(state.copyWith(selectedIds: ids));
	}
}
