part of '_bloc.dart';

abstract class LocationPickerDialogEvent {}

final class UseCurrentLocation extends LocationPickerDialogEvent {
  final BuildContext dialogContext;

  UseCurrentLocation({required this.dialogContext});
}

final class ChooseFromMap extends LocationPickerDialogEvent {
  final BuildContext dialogContext;

  ChooseFromMap({required this.dialogContext});
}
