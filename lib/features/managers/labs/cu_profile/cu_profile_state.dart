part of 'cu_profile_cubit.dart';

abstract class CuProfileState {}

class CuProfileInitial extends CuProfileState {}

class CuProfileLoading extends CuProfileState {}

class CuProfileLoaded extends CuProfileState {
  final List<CuProfile> records;
  CuProfileLoaded(this.records);
}

class CuProfileError extends CuProfileState {
  final String message;
  CuProfileError(this.message);
}
