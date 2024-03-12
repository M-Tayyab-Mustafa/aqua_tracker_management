part of '_bloc.dart';

@immutable
abstract class EditClientState {}

final class Loading extends EditClientState {}

final class Loaded extends EditClientState {
  final GlobalKey<FormState> formKey;
  final TextEditingController editNameController;
  final TextEditingController editContactController;
  final List<Location> editClientLocations;
  final List<String> editAddresses;

  Loaded({required this.formKey, required this.editNameController, required this.editContactController, required this.editClientLocations, required this.editAddresses});
}
