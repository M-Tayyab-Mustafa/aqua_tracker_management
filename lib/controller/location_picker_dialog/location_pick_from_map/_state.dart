part of '_bloc.dart';

@immutable
abstract class LocationPickFromMapState {}

final class Loading extends LocationPickFromMapState {}

final class Loaded extends LocationPickFromMapState {
  final Set<Marker> markers;

  Loaded({required this.markers});
}

final class Error extends LocationPickFromMapState {}
