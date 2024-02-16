// ignore_for_file: use_build_context_synchronously
import 'package:aqua_tracker_management/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/widget/button.dart';
import '../utils/widget/error_dialog.dart';
import '../utils/widget/loading_dialog.dart';
import '../utils/widget/text_field.dart';
import 'location_picker_dialog/_bloc.dart';

class CustomLocationPicker extends StatelessWidget {
  const CustomLocationPicker(
      {super.key, required this.title, required this.latitudeController, required this.longitudeController});
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
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(largeBorderRadius)),
              child: IconButton(
                focusNode: FocusNode(skipTraversal: true),
                onPressed: () async {
                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => BlocProvider(
                      create: (context) => LocationPickerDialogBloc(),
                      child: BlocBuilder<LocationPickerDialogBloc, LocationPickerDialogState>(
                        builder: (context, state) {
                          switch (state.runtimeType) {
                            case const (Loading):
                              return const LoadingDialog();
                            case const (Loaded):
                              return AlertDialog.adaptive(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Select Location'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: Text('Use current location',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(fontWeight: FontWeight.bold)),
                                      leading: const Icon(Icons.my_location, color: Colors.blueAccent),
                                      onTap: () => BlocProvider.of<LocationPickerDialogBloc>(context)
                                          .add(UseCurrentLocation(dialogContext: dialogContext)),
                                    ),
                                    ListTile(
                                      title: Text('Choose from map',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(fontWeight: FontWeight.bold)),
                                      leading: const Icon(Icons.location_on_rounded, color: Colors.redAccent),
                                      onTap: () => BlocProvider.of<LocationPickerDialogBloc>(context)
                                          .add(ChooseFromMap(dialogContext: dialogContext)),
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
                icon: const FittedBox(child: Icon(CupertinoIcons.location_solid, color: Colors.white)),
              ),
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
