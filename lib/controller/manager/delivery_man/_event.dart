part of '_bloc.dart';

abstract class DeliveryManEvent {}

final class Add extends DeliveryManEvent {}

final class Edit extends DeliveryManEvent {
  final Employee employee;

  Edit({required this.employee});
}

final class Delete extends DeliveryManEvent {
  final Employee employee;

  Delete({required this.employee});
}
