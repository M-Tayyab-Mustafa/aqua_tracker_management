part of '_bloc.dart';

abstract class DeliveryManState {}

final class Loading extends DeliveryManState {}

final class Loaded extends DeliveryManState {
  final List<Employee> deliveryMans;

  Loaded({required this.deliveryMans});
}

final class Error extends DeliveryManState {}
