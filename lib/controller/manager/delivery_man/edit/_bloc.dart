// ignore_for_file: invalid_use_of_visible_for_testing_member, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../model/employee.dart';
import '../../../../utils/constants.dart';

part '_event.dart';
part '_state.dart';

class EditDeliveryBoyBloc extends Bloc<EditDeliveryBoyEvent, EditDeliveryBoyState> {
  final firebaseFs = FirebaseFirestore.instance;
  File? imageFile;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final contactController = TextEditingController(text: contactFieldDefaultValue);

  EditDeliveryBoyBloc() : super(Loading()) {
    _loaded;
    on<Submit>((event, emit) async {
      if (formKey.currentState!.validate()) {
        loading;
        try {
          if (nameController.text != event.employee.name) {
            await firebaseFs
                .collection(fBCompanyCollectionKey)
                .doc(event.employee.companyName)
                .collection(fBEmployeesCollectionKey)
                .doc(event.employee.uid)
                .update({'name': nameController.text});
          }
          if (contactController.text != event.employee.contact) {
            await firebaseFs
                .collection(fBCompanyCollectionKey)
                .doc(event.employee.companyName)
                .collection(fBEmployeesCollectionKey)
                .doc(event.employee.uid)
                .update({'contact': contactController.text});
          }
          if (imageFile != null) {
            final firebaseStorage = FirebaseStorage.instance.refFromURL(event.employee.imageUrl);
            await firebaseStorage.putFile(imageFile!);
            String imageUrl = await firebaseStorage.getDownloadURL();

            await firebaseFs
                .collection(fBCompanyCollectionKey)
                .doc(event.employee.companyName)
                .collection(fBEmployeesCollectionKey)
                .doc(event.employee.uid)
                .update({'image_url': imageUrl});
          }
          Navigator.pop(event.dialogContext, 'updated');
        } catch (e) {
          log(e.toString());
          error;
        }
      }
    });
  }

  get loading => emit(Loading());
  get _loaded => emit(Loaded(
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
