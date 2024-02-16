part of '_bloc.dart';

abstract class AddDeliveryManState {}

final class Loading extends AddDeliveryManState {}

final class Loaded extends AddDeliveryManState {
  final GlobalKey<FormState> emailFormKey;
  final TextEditingController emailController;

  Loaded({required this.emailFormKey, required this.emailController});
}

final class Error extends AddDeliveryManState {}
