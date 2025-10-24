part of 'vitamin_level_cubit.dart';

abstract class VitaminLevelState {}

class VitaminLevelInitial extends VitaminLevelState {}

class VitaminLevelLoading extends VitaminLevelState {}

class VitaminLevelLoaded extends VitaminLevelState {
  final List<VitaminLevel> records;
  VitaminLevelLoaded(this.records);
}

class VitaminLevelError extends VitaminLevelState {
  final String message;
  VitaminLevelError(this.message);
}
