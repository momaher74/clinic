import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/features/managers/complaint/complaint/complaint_state.dart';

class ComplaintCubit extends Cubit<ComplaintState> {
	ComplaintCubit() : super(ComplaintState(isLoading: true));
	
	Future<void> loadInitialData() async {
		final stableState = state;
		try {
		  emit(state.copyWith(isLoading: true));
	
		  // TODO your code here
	
		  emit(state.copyWith(isLoading: false));
		} catch (error) {
		  emit(state.copyWith(error: error.toString()));
		  emit(stableState.copyWith(isLoading: false));
		}
	}
}
