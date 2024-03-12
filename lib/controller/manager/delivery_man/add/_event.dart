part of '_bloc.dart';

abstract final class AddDeliveryManEvent {}

final class Next extends AddDeliveryManEvent {
  final BuildContext dialogContext;

  Next({required this.dialogContext});
}
