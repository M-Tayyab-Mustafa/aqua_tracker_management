part of '_bloc.dart';

abstract final class EditDeliveryBoyEvent {}

final class Submit extends EditDeliveryBoyEvent {
  final BuildContext dialogContext;
  final Employee employee;

  Submit({required this.dialogContext, required this.employee});
}
