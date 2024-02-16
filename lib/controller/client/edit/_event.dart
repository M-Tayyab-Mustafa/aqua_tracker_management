part of '_bloc.dart';

@immutable
abstract class EditClientEvent {}

final class AddLocation extends EditClientEvent {
  final BuildContext dialogContext;
  final Client client;

  AddLocation({required this.dialogContext, required this.client});
}

final class DeleteLocation extends EditClientEvent {
  final Location location;

  DeleteLocation({required this.location});
}

final class EditConfirm extends EditClientEvent {
  final BuildContext dialogContext;
  final Client client;

  EditConfirm({required this.dialogContext, required this.client});
}
