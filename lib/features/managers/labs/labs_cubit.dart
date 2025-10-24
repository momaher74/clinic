import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/features/managers/labs/labs_state.dart';

class LabsCubit extends Cubit<LabsState> {
	LabsCubit() : super(LabsState(isLoading: true));
	
	Future<void> loadInitialData() async {
		final stableState = state;
		try {
		  emit(state.copyWith(isLoading: true));
	
	
		  emit(state.copyWith(isLoading: false));
		} catch (error) {
		  emit(state.copyWith(error: error.toString()));
		  emit(stableState.copyWith(isLoading: false));
		}
	}
}
