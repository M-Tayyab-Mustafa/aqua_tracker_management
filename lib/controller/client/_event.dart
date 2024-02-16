part of '_bloc.dart';

@immutable
abstract class ClientEvent {}

final class Add extends ClientEvent {}

final class LocationSelected extends ClientEvent {
  final String clientUid;
  final location.Location clientLocation;

  LocationSelected({required this.clientUid, required this.clientLocation});
}

final class Edit extends ClientEvent {
  final Client client;

  Edit({required this.client});
}

final class Delete extends ClientEvent {
  final Client client;

  Delete({required this.client});
}
