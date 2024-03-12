part of '_bloc.dart';

@immutable
abstract final class ClientState {}

final class Loading extends ClientState {}

final class Loaded extends ClientState {
  final List<Client> clients;

  Loaded({required this.clients});
}

final class Error extends ClientState {}
