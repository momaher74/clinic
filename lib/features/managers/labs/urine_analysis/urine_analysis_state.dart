part of 'urine_analysis_cubit.dart';

abstract class UrineAnalysisState {}

class UrineAnalysisInitial extends UrineAnalysisState {}

class UrineAnalysisLoading extends UrineAnalysisState {}

class UrineAnalysisLoaded extends UrineAnalysisState {
  final List<UrineAnalysis> records;
  UrineAnalysisLoaded(this.records);
}

class UrineAnalysisError extends UrineAnalysisState {
  final String message;
  UrineAnalysisError(this.message);
}
