class LabsState {
	final bool isLoading;
	final String? error;
	  
	const LabsState({
		this.isLoading = false,
		this.error,
	});
	  
	LabsState copyWith({
		bool? isLoading,
		String? error,
	}) {
		return LabsState(
			isLoading: isLoading ?? this.isLoading,
			error: error ?? this.error,
		);
	}
}
