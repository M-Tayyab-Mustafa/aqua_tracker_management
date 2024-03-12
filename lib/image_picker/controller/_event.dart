part of '_bloc.dart';

abstract final class ImagePickerEvent {}

final class NewImageSourceDialog extends ImagePickerEvent {
  final BuildContext context;
  final String title;
  final Future<void> Function(File? image) image;

  NewImageSourceDialog({required this.context, required this.title, required this.image});
}
