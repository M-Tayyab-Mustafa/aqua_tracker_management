part of '_bloc.dart';

@immutable
abstract class AddClientState {}

final class Loading extends AddClientState {}

final class EmailChecking extends AddClientState {
  final GlobalKey<FormState> emailFormKey;
  final TextEditingController emailController;

  EmailChecking({required this.emailFormKey, required this.emailController});
}

final class AddClient extends AddClientState {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController contactController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;

  AddClient(
      {required this.formKey,
      required this.nameController,
      required this.contactController,
      required this.latitudeController,
      required this.longitudeController});
}

final class Error extends AddClientState {}
