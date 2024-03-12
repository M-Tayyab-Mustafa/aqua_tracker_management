part of '_bloc.dart';

@immutable
abstract class AddClientEvent {}

final class EmailChecking extends AddClientEvent {
  final BuildContext dialogContext;

  EmailChecking({required this.dialogContext});
}

final class SubmitNewClient extends AddClientEvent {
  final BuildContext dialogContext;

  SubmitNewClient({required this.dialogContext});
}
