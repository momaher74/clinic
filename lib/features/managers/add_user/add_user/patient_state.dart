import 'package:clinic/core/models/patient.dart';

class PatientState {
	final bool isLoading;
	final String? error;
	final List<Patient> patients;
	final List<Patient> filtered;
	final Set<int> selectedIds;
	final String query;
	  
	const PatientState({
		this.isLoading = false,
		this.error,
		this.patients = const [],
		this.filtered = const [],
		this.selectedIds = const {},
		this.query = '',
	});
	  
	PatientState copyWith({
		bool? isLoading,
		String? error,
		List<Patient>? patients,
		List<Patient>? filtered,
		Set<int>? selectedIds,
		String? query,
	}) {
		return PatientState(
			isLoading: isLoading ?? this.isLoading,
			error: error ?? this.error,
			patients: patients ?? this.patients,
			filtered: filtered ?? this.filtered,
			selectedIds: selectedIds ?? this.selectedIds,
			query: query ?? this.query,
		);
	}
}
