part of '_bloc.dart';

abstract class EditDeliveryBoyState {}

final class Loading extends EditDeliveryBoyState {}

final class Loaded extends EditDeliveryBoyState {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController contactController;

  Loaded({required this.formKey, required this.nameController, required this.contactController});
}

final class Error extends EditDeliveryBoyState {}
