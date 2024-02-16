// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:developer';
import 'dart:io';
import 'package:aqua_tracker_management/model/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_generator/password_generator.dart';
import '../../../../image_picker/image_picker.dart';
import '../../../../model/employee.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/local_storage/hive.dart';
import '../../../../utils/widget/button.dart';
import '../../../../utils/widget/text_field.dart';
part '_state.dart';
part '_event.dart';

class AddDeliveryManBloc extends Bloc<AddDeliveryManEvent, AddDeliveryManState> {
  final firebaseFs = FirebaseFirestore.instance;
  final firebaseStorage = FirebaseStorage.instance.ref();
  final firebaseDatabase = FirebaseDatabase.instance.ref();
  final emailFormKey = GlobalKey<FormState>();
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final contactController = TextEditingController(text: contactFieldDefaultValue);
  final nameController = TextEditingController();
  File? imageFile;
  AddDeliveryManBloc() : super(Loading()) {
    loaded;
    on<Next>((event, emit) {
      if (emailFormKey.currentState!.validate()) {
        loading;
        isEmailAlreadyExists(emailController.text).then((exists) async {
          loaded;
          if (!exists) {
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
                          NameTextField(hintText: 'Delivery Man Name', controller: nameController),
                          ContactTextField(
                            hintText: 'Delivery Man Contact',
                            controller: contactController,
                          ),
                          CustomImagePicker(
                            title: 'Select Delivery Man Image',
                            image: (image) async => imageFile = image,
                          ),
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
                  final password = PasswordGenerator(
                    length: 8,
                    hasCapitalLetters: true,
                    hasNumbers: true,
                    hasSmallLetters: true,
                    hasSymbols: true,
                  ).generatePassword();
                  await auth.FirebaseAuth.instance
                      .createUserWithEmailAndPassword(email: emailController.text, password: password)
                      .then((deliveryManCredentials) async {
                    await LocalDatabase.getUser().then((user) async {
                      String uid = deliveryManCredentials.user!.uid;
                      await firebaseStorage
                          .child(user.companyName)
                          .child(user.branch)
                          .child(emailController.text)
                          .putFile(imageFile!)
                          .whenComplete(() async {
                        String imageUrl = await firebaseStorage
                            .child(user.companyName)
                            .child(user.branch)
                            .child(emailController.text)
                            .getDownloadURL();
                        await firebaseFs
                            .collection(fBCompanyCollectionKey)
                            .doc(user.companyName)
                            .collection(fBEmployeesCollectionKey)
                            .doc(uid)
                            .set(Employee(
                              uid: uid,
                              name: nameController.text,
                              companyName: user.companyName,
                              branch: user.branch,
                              email: emailController.text,
                              contact: contactController.text,
                              imageUrl: imageUrl,
                              post: deliveryManPost,
                              onVacation: false,
                              password: password,
                              token: '',
                            ).toMap())
                            .whenComplete(() async {
                          await currentLocation.then((position) async {
                            if (position != null) {
                              final address = await addressFromLatLong(
                                  lat: position.latitude.toString(), long: position.longitude.toString());
                              await firebaseDatabase
                                  .child(user.companyName)
                                  .child('employees_locations')
                                  .child(uid)
                                  .set(Location(
                                    latitude: position.latitude.toString(),
                                    longitude: position.longitude.toString(),
                                    address: address,
                                  ).toMap())
                                  .whenComplete(() => Navigator.pop(event.dialogContext, 'delivery_boy_added'));
                            }
                          });
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
  get loaded => emit(Loaded(emailFormKey: emailFormKey, emailController: emailController));
  get error => emit(Error());

  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    return super.close();
  }
}
