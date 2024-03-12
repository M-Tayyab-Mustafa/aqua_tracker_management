// ignore_for_file: use_build_context_synchronously
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controller/location_picker_dialog/_bloc.dart';
import 'button.dart';
import '../constants.dart';
import 'error_dialog.dart';
import 'loading_dialog.dart';
import 'text_field.dart';

class CustomLocationPicker extends StatelessWidget {
  const CustomLocationPicker(
      {super.key,
      required this.title,
      required this.latitudeController,
      required this.longitudeController});
  final String title;
  final TextEditingController longitudeController;
  final TextEditingController latitudeController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          trailing: FittedBox(
            child: IconButton(
              focusNode: FocusNode(skipTraversal: true),
              onPressed: () async {
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) => BlocProvider(
                    create: (context) => LocationPickerDialogBloc(),
                    child: BlocBuilder<LocationPickerDialogBloc,
                        LocationPickerDialogState>(
                      builder: (context, state) {
                        switch (state.runtimeType) {
                          case const (Loading):
                            return const LoadingDialog();
                          case const (Loaded):
                            return AlertDialog.adaptive(
                              title: const Text('Select Location'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: const Text('Use current location'),
                                    leading: const Icon(Icons.my_location),
                                    onTap: () => BlocProvider.of<
                                            LocationPickerDialogBloc>(context)
                                        .add(UseCurrentLocation(
                                            dialogContext: dialogContext)),
                                  ),
                                  ListTile(
                                    title: const Text('Choose from map'),
                                    leading:
                                        const Icon(Icons.location_on_rounded),
                                    onTap: () => BlocProvider.of<
                                            LocationPickerDialogBloc>(context)
                                        .add(ChooseFromMap(
                                            dialogContext: dialogContext)),
                                  ),
                                ],
                              ),
                              actions: [
                                CustomButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  title: 'Cancel',
                                ),
                              ],
                            );
                          default:
                            return const ErrorDialog();
                        }
                      },
                    ),
                  ),
                ).then((location) {
                  if (location != null) {
                    latitudeController.text = location.latitude.toString();
                    longitudeController.text = location.longitude.toString();
                  }
                });
              },
              icon: Icon(CupertinoIcons.location_solid,
                  color: Theme.of(context).primaryColor,
                  size: buttonSize.height * 0.65),
            ),
          ),
        ),
        LocationTextField(
          latitudeController: latitudeController,
          longitudeController: longitudeController,
        ),
      ],
    );
  }
}
