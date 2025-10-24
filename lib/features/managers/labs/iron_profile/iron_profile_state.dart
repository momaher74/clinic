part of 'iron_profile_cubit.dart';

abstract class IronProfileState {}

class IronProfileInitial extends IronProfileState {}

class IronProfileLoading extends IronProfileState {}

class IronProfileLoaded extends IronProfileState {
  final List<IronProfile> records;
  IronProfileLoaded(this.records);
}

class IronProfileError extends IronProfileState {
  final String message;
  IronProfileError(this.message);
}
