// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:developer';
import 'dart:io';

import 'package:aqua_tracker_managements/model/delivery_man.dart';
import 'package:aqua_tracker_managements/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part '_event.dart';
part '_state.dart';

class EditDeliveryBoyBloc extends Bloc<EditDeliveryBoyEvent, EditDeliveryBoyState> {
  File? imageFile;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final contactController = TextEditingController(text: contactFieldDefaultValue);

  EditDeliveryBoyBloc() : super(Loading()) {
    loaded;
    on<Submit>((event, emit) async {
      if (formKey.currentState!.validate()) {
        loading;
        try {
          if (nameController.text != event.employee.name) {
            await (await firebaseCompanyDoc)
                .collection(fBEmployeesCollectionKey)
                .doc(event.employee.uid)
                .update({'name': nameController.text});
          }
          if (contactController.text != event.employee.contact) {
            await (await firebaseCompanyDoc)
                .collection(fBEmployeesCollectionKey)
                .doc(event.employee.uid)
                .update({'contact': contactController.text});
          }
          if (imageFile != null) {
            await firebaseStorageReference
                .child(event.employee.companyName)
                .child(event.employee.branch)
                .child(event.employee.email)
                .delete();
            await firebaseStorageReference
                .child(event.employee.companyName)
                .child(event.employee.branch)
                .child(event.employee.email)
                .putFile(imageFile!);
            String imageUrl = await firebaseStorageReference
                .child(event.employee.companyName)
                .child(event.employee.branch)
                .child(event.employee.email)
                .getDownloadURL();
            await (await firebaseCompanyDoc)
                .collection(fBEmployeesCollectionKey)
                .doc(event.employee.uid)
                .update({'image_url': imageUrl});
          }
          // ignore: use_build_context_synchronously
          Navigator.pop(event.dialogContext, 'updated');
        } catch (e) {
          log(e.toString());
          error;
        }
      }
    });
  }

  get loading => emit(Loading());
  get loaded => emit(Loaded(
        formKey: formKey,
        nameController: nameController,
        contactController: contactController,
      ));
  get error => emit(Error());

  @override
  Future<void> close() {
    nameController.dispose();
    return super.close();
  }
}
