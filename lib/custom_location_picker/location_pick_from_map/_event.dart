part of '_bloc.dart';

@immutable
abstract final class LocationPickFromMapEvent {}

final class AddMarkerEvent extends LocationPickFromMapEvent {
  final LatLng location;

  AddMarkerEvent({required this.location});
}
