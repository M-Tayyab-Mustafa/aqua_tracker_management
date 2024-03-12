// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:developer';
import 'dart:io';
import 'package:aqua_tracker_managements/model/delivery_man.dart';
import 'package:aqua_tracker_managements/utils/widgets/text_field.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import '../../../../model/user.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/widgets/button.dart';
import '../../../../utils/widgets/image_picker.dart';
part '_state.dart';
part '_event.dart';

class AddDeliveryManBloc extends Bloc<AddDeliveryManEvent, AddDeliveryManState> {
  final emailFormKey = GlobalKey<FormState>();
  final formKey = GlobalKey<FormState>();
  final newEmployeeEmailController = TextEditingController();
  final newEmployeeContactController = TextEditingController(text: contactFieldDefaultValue);
  final newEmployeeNameController = TextEditingController();
  final newEmployeePasswordController = TextEditingController();
  final newEmployeeConfirmPasswordController = TextEditingController();
  File? imageFile;
  AddDeliveryManBloc() : super(Loading()) {
    loaded;
    on<Next>((event, emit) {
      if (emailFormKey.currentState!.validate()) {
        loading;
        isEmailAlreadyExists(newEmployeeEmailController.text).then((exists) async {
          loaded;
          if (exists != null && !exists) {
            await showDialog(
              context: event.dialogContext,
              barrierDismissible: false,
              builder: (innerDialogContext) => AlertDialog.adaptive(
                title: const Text('Add Delivery Man'),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                content: Form(
                  key: formKey,
                  child: StatefulBuilder(
                    builder: (context, setState) => SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          NameTextField(hintText: 'Delivery Man Name', controller: newEmployeeNameController),
                          ContactTextField(hintText: 'Delivery Man Contact', controller: newEmployeeContactController),
                          CustomImagePicker(
                              title: 'Select Delivery Man Image', image: (image) async => imageFile = image),
                          PasswordTextField(controller: newEmployeePasswordController),
                          ConfirmPasswordTextField(
                              controller: newEmployeeConfirmPasswordController,
                              passwordController: newEmployeePasswordController),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  CustomButton(onPressed: () => Navigator.pop(innerDialogContext), title: 'Cancel'),
                  CustomButton(
                      onPressed: () {
                        if (imageFile == null) {
                          showErrorToast(msg: 'Please Select Delivery Boy Image');
                        } else if (formKey.currentState!.validate()) {
                          Navigator.pop(innerDialogContext, 'Submitted');
                        }
                      },
                      title: 'Submit',
                      primaryColor: true),
                ],
              ),
            ).then((returnValue) async {
              if (returnValue != null) {
                loading;
                try {
                  await auth.FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: newEmployeeEmailController.text, password: newEmployeePasswordController.text)
                      .then((deliveryManCredentials) async {
                    User user = await localStorage.user;
                    String deliveryManUid = deliveryManCredentials.user!.uid;
                    (await firebaseCompanyDoc)
                        .collection(fBBranchesCollectionKey)
                        .doc(user.branch)
                        .set({deliveryManUid: newEmployeePasswordController.text}, SetOptions(merge: true));
                    await firebaseStorageReference
                        .child(user.companyName)
                        .child(user.branch)
                        .child(newEmployeeEmailController.text)
                        .putFile(imageFile!)
                        .whenComplete(() async {
                      String imageUrl = await firebaseStorageReference
                          .child(user.companyName)
                          .child(user.branch)
                          .child(newEmployeeEmailController.text)
                          .getDownloadURL();
                      (await firebaseCompanyDoc)
                          .collection(fBEmployeesCollectionKey)
                          .doc(deliveryManUid)
                          .set(
                            Employee(
                              uid: deliveryManUid,
                              name: newEmployeeNameController.text,
                              companyName: user.companyName,
                              branch: user.branch,
                              email: newEmployeeEmailController.text,
                              contact: newEmployeeContactController.text,
                              imageUrl: imageUrl,
                              post: deliveryManPost,
                              onVacations: false,
                            ).toMap(),
                          )
                          .whenComplete(() async {
                        await currentLocation().then((position) async {
                          if (position != null) {
                            await firebaseDatabaseReference
                                .child(user.companyName)
                                .child('employees_locations')
                                .child(deliveryManUid)
                                .set({
                              'latitude': position.latitude,
                              'longitude': position.longitude,
                            }).whenComplete(() => Navigator.pop(event.dialogContext, 'delivery_boy_added'));
                          }
                        });
                      });
                    });
                  });
                } catch (e) {
                  log(e.toString());
                  showErrorToast(msg: 'Something went wrong! try again later');
                  error;
                }
              }
            });
          }
        });
      }
    });
  }

  get loading => emit(Loading());
  get loaded => emit(Loaded(emailFormKey: emailFormKey, newEmployeeEmailController: newEmployeeEmailController));
  get error => emit(Error());

  @override
  Future<void> close() {
    newEmployeeNameController.dispose();
    newEmployeeEmailController.dispose();
    newEmployeeContactController.dispose();
    newEmployeePasswordController.dispose();
    newEmployeeConfirmPasswordController.dispose();
    return super.close();
  }
}
