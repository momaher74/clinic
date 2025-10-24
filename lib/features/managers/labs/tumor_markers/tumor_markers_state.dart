part of 'tumor_markers_cubit.dart';

abstract class TumorMarkersState {}

class TumorMarkersInitial extends TumorMarkersState {}

class TumorMarkersLoading extends TumorMarkersState {}

class TumorMarkersLoaded extends TumorMarkersState {
  final List<TumorMarkers> records;
  TumorMarkersLoaded(this.records);
}

class TumorMarkersError extends TumorMarkersState {
  final String message;
  TumorMarkersError(this.message);
}
