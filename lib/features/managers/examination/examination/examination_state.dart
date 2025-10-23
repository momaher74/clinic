import 'package:clinic/core/models/examination.dart';
import 'package:clinic/core/models/request.dart';

class ExaminationState {
	final bool isLoading;
	final String? error;
	final int? patientId;
	final List<Examination> examinations;
	final List<Req> reqs;
	
	const ExaminationState({
		this.isLoading = false,
		this.error,
		this.patientId,
		this.examinations = const [],
		this.reqs = const [],
	});
	
	ExaminationState copyWith({
		bool? isLoading,
		String? error,
		int? patientId,
		List<Examination>? examinations,
		List<Req>? reqs,
	}) {
		return ExaminationState(
			isLoading: isLoading ?? this.isLoading,
			error: error ?? this.error,
			patientId: patientId ?? this.patientId,
			examinations: examinations ?? this.examinations,
			reqs: reqs ?? this.reqs,
		);
	}
}
