class ComplaintState {
	final bool isLoading;
	final String? error;
	  
	const ComplaintState({
		this.isLoading = false,
		this.error,
	});
	  
	ComplaintState copyWith({
		bool? isLoading,
		String? error,
	}) {
		return ComplaintState(
			isLoading: isLoading ?? this.isLoading,
			error: error ?? this.error,
		);
	}
}
