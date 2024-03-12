// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/constants.dart';
import '../../utils/widget/button.dart';
part '_event.dart';
part '_state.dart';

class ImagePickerBloc extends Bloc<ImagePickerEvent, ImagePickerState> {
  File? imageFile;
  ImagePickerBloc() : super(Loading()) {
    init();
    on<NewImageSourceDialog>((event, emit) async {
      return await showDialog(
        context: event.context,
        builder: (context) => AlertDialog.adaptive(
          title: Text(event.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Camera'),
                onTap: () async {
                  await ImagePicker.platform.getImageFromSource(source: ImageSource.camera).then((pickedImage) {
                    if (pickedImage != null) {
                      imageFile = File(pickedImage.path);
                      event.image.call(imageFile!);
                      _loaded;
                    } else {
                      showErrorToast(msg: 'You Cancel Image Selection');
                    }
                    Navigator.pop(context);
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_sharp),
                title: const Text('Gallery'),
                onTap: () async {
                  await ImagePicker.platform.getImageFromSource(source: ImageSource.gallery).then((pickedImage) {
                    if (pickedImage != null) {
                      imageFile = File(pickedImage.path);
                      event.image.call(imageFile!);
                      _loaded;
                    } else {
                      showErrorToast(msg: 'You Cancel Image Selection');
                    }
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
          actions: [
            CustomButton(onPressed: () => Navigator.pop(context), title: 'Cancel'),
          ],
        ),
      );
    });
  }

  init() {
    _loaded;
  }

  get loading => emit(Loading());
  get _loaded => emit(Loaded(imageFile: imageFile));
}
