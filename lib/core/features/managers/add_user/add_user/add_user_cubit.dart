import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/features/managers/add_user/add_user/add_user_state.dart';

class AddUserCubit extends Cubit<AddUserState> {
	AddUserCubit() : super(AddUserState(isLoading: true));
	
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
