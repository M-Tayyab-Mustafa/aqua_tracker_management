part of '_bloc.dart';

abstract class AddDeliveryManEvent {}

final class Next extends AddDeliveryManEvent {
  final BuildContext dialogContext;

  Next({required this.dialogContext});
}
