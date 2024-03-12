part of '_bloc.dart';

@immutable
abstract class EditClientEvent {}

final class AddClientLocation extends EditClientEvent {
  final BuildContext dialogContext;
  final Client client;

  AddClientLocation({required this.dialogContext, required this.client});
}

final class DeleteClientLocation extends EditClientEvent {
  final int index;

  DeleteClientLocation({required this.index});
}

final class EditConfirm extends EditClientEvent {
  final BuildContext dialogContext;

  EditConfirm({required this.dialogContext});
}
