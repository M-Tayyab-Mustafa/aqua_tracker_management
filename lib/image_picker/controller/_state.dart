part of '_bloc.dart';

abstract final class ImagePickerState {}

final class Loading extends ImagePickerState {}

final class Loaded extends ImagePickerState {
  final File? imageFile;

  Loaded({required this.imageFile});
}
