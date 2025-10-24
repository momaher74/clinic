
import 'package:clinic/core/models/stool_tests.dart';

abstract class StoolTestsState {}

class StoolTestsInitial extends StoolTestsState {}

class StoolTestsLoading extends StoolTestsState {}

class StoolTestsLoaded extends StoolTestsState {
  final List<StoolTests> records;
  StoolTestsLoaded(this.records);
}

class StoolTestsError extends StoolTestsState {
  final String message;
  StoolTestsError(this.message);
}
