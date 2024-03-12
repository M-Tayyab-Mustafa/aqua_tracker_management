part of '_bloc.dart';

@immutable
abstract class AddClientState {}

final class Loading extends AddClientState {}

final class Loaded extends AddClientState {
  final GlobalKey<FormState> emailFormKey;
  final TextEditingController emailController;

  Loaded({required this.emailFormKey, required this.emailController});
}

final class CreateUser extends AddClientState {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController contactController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;

  CreateUser({required this.formKey, required this.nameController, required this.contactController, required this.passwordController, required this.confirmPasswordController, required this.latitudeController, required this.longitudeController});
}

final class Error extends AddClientState {}
