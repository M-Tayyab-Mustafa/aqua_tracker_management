part of '_bloc.dart';

abstract class AddDeliveryManState {}

final class Loading extends AddDeliveryManState {}

final class Loaded extends AddDeliveryManState {
  final GlobalKey<FormState> emailFormKey;
  final TextEditingController newEmployeeEmailController;

  Loaded({required this.emailFormKey, required this.newEmployeeEmailController});
}

final class Error extends AddDeliveryManState {}
