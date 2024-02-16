// ignore_for_file: invalid_use_of_visible_for_testing_member, use_build_context_synchronously
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/constants.dart';
import '../utils/widget/custom_avatars.dart';
import 'controller/_bloc.dart';

class CustomImagePicker extends StatelessWidget {
  const CustomImagePicker({super.key, required this.title, required this.image, this.defaultImageUrl});
  final String title;
  final String? defaultImageUrl;
  final Future<void> Function(File? image) image;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImagePickerBloc(),
      child: Builder(builder: (context) {
        return Column(
          children: [
            ListTile(
              title: Text(title),
              titleTextStyle: Theme.of(context).textTheme.titleMedium,
              trailing: IconButton(
                focusNode: FocusNode(skipTraversal: true),
                onPressed: () => BlocProvider.of<ImagePickerBloc>(context).add(
                  NewImageSourceDialog(
                    title: title,
                    context: context,
                    image: image,
                  ),
                ),
                icon: Icon(
                  Icons.add_a_photo,
                  color: Theme.of(context).primaryColor,
                  size: buttonSize,
                ),
              ),
            ),
            BlocBuilder<ImagePickerBloc, ImagePickerState>(
              builder: (context, state) {
                switch (state.runtimeType) {
                  case const (Loaded):
                    (state as Loaded);
                    return Padding(
                      padding: EdgeInsets.only(bottom: mediumPadding),
                      child: PreviewCircularAvatar(
                        imageFile: state.imageFile,
                        imageUrl: defaultImageUrl,
                      ),
                    );
                  default:
                    return CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      radius: 40,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                }
              },
            ),
          ],
        );
      }),
    );
  }
}
