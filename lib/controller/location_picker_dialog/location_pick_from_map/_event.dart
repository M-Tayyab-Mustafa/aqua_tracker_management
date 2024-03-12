part of '_bloc.dart';

@immutable
abstract class LocationPickFromMapEvent {}

final class AddMarkerEvent extends LocationPickFromMapEvent {
  final LatLng location;

  AddMarkerEvent({required this.location});
}