part of '_bloc.dart';

abstract final class DeliveryManLocationState {}

final class Loading extends DeliveryManLocationState {}

final class Loaded extends DeliveryManLocationState {
  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;

  Loaded({required this.initialCameraPosition, required this.markers});
}

final class Error extends DeliveryManLocationState {}
