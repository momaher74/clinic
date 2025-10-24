part of 'pregnancy_test_cubit.dart';

abstract class PregnancyTestState {}

class PregnancyTestInitial extends PregnancyTestState {}

class PregnancyTestLoading extends PregnancyTestState {}

class PregnancyTestLoaded extends PregnancyTestState {
  final List<PregnancyTest> records;
  PregnancyTestLoaded(this.records);
}

class PregnancyTestError extends PregnancyTestState {
  final String message;
  PregnancyTestError(this.message);
}
