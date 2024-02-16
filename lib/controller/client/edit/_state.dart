part of '_bloc.dart';

@immutable
abstract class EditClientState {}

final class Loading extends EditClientState {}

final class Loaded extends EditClientState {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController contactController;
  final List<Location> locations;

  Loaded({
    required this.formKey,
    required this.nameController,
    required this.contactController,
    required this.locations,
  });
}
