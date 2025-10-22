class AddUserState {
	final bool isLoading;
	final String? error;
	  
	const AddUserState({
		this.isLoading = false,
		this.error,
	});
	  
	AddUserState copyWith({
		bool? isLoading,
		String? error,
	}) {
		return AddUserState(
			isLoading: isLoading ?? this.isLoading,
			error: error ?? this.error,
		);
	}
}
