part of '_bloc.dart';

@immutable
abstract final class AddClientEvent {}

final class SubmitEmail extends AddClientEvent {
  final BuildContext dialogContext;

  SubmitEmail({required this.dialogContext});
}

final class SubmitClient extends AddClientEvent {
  final BuildContext dialogContext;

  SubmitClient({required this.dialogContext});
}
