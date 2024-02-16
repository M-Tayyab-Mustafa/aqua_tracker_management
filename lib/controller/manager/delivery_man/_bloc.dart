// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/manager/delivery_man/edit/_bloc.dart' as edit;
import '../../../image_picker/image_picker.dart';
import '../../../model/employee.dart';
import '../../../model/user.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage/hive.dart';
import '../../../utils/widget/button.dart';
import '../../../utils/widget/error_dialog.dart';
import '../../../utils/widget/loading_dialog.dart';
import '../../../utils/widget/text_field.dart';
import 'add/_bloc.dart' as add_bloc;

part '_state.dart';
part '_event.dart';

class DeliveryManBloc extends Bloc<DeliveryManEvent, DeliveryManState> {
  final firebaseFs = FirebaseFirestore.instance;
  final firebaseStorage = FirebaseStorage.instance;
  List<Employee> deliveryMans = [];
  late User user;
  DeliveryManBloc(BuildContext context) : super(Loading()) {
    LocalDatabase.getUser().then((user) async {
      this.user = user;
      try {
        await firebaseFs
            .collection(fBCompanyCollectionKey)
            .doc(user.companyName)
            .collection(fBEmployeesCollectionKey)
            .get()
            .then((employeesCollection) async {
          for (var employeeDoc in employeesCollection.docs) {
            Employee employee = Employee.fromMap(employeeDoc.data());
            if (employee.post == deliveryManPost && !(employee.onVacation) && employee.branch == user.branch) {
              deliveryMans.add(employee);
            }
          }
          loaded;
        });
      } catch (e) {
        log(e.toString());
        error;
      }
    });

    on<Add>((event, emit) async {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => BlocProvider(
          create: (context) => add_bloc.AddDeliveryManBloc(),
          child: BlocBuilder<add_bloc.AddDeliveryManBloc, add_bloc.AddDeliveryManState>(
            builder: (context, state) {
              switch (state.runtimeType) {
                case const (add_bloc.Loading):
                  return const LoadingDialog();
                case const (add_bloc.Loaded):
                  (state as add_bloc.Loaded);
                  return AlertDialog.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Add Delivery Man'),
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                    content: Form(key: state.emailFormKey, child: EmailTextField(controller: state.emailController)),
                    actions: [
                      CustomButton(onPressed: () => Navigator.pop(dialogContext), title: 'Cancel'),
                      CustomButton(
                        onPressed: () => BlocProvider.of<add_bloc.AddDeliveryManBloc>(context)
                            .add(add_bloc.Next(dialogContext: dialogContext)),
                        title: 'Next',
                        primaryColor: true,
                      ),
                    ],
                  );
                default:
                  return const ErrorDialog();
              }
            },
          ),
        ),
      ).then((returnValue) {
        if (returnValue != null && returnValue == 'delivery_boy_added') {
          _reInit;
        }
      });
    });
    on<Edit>((event, emit) async {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => BlocProvider(
          create: (context) => edit.EditDeliveryBoyBloc(),
          child: BlocBuilder<edit.EditDeliveryBoyBloc, edit.EditDeliveryBoyState>(
            builder: (context, state) {
              switch (state.runtimeType) {
                case const (edit.Loading):
                  return const LoadingDialog();
                case const (edit.Loaded):
                  (state as edit.Loaded);
                  state.nameController.text = event.employee.name;
                  state.contactController.text = event.employee.contact;
                  return AlertDialog.adaptive(
                    title: const Text('Edit Delivery Man'),
                    contentPadding: EdgeInsets.zero,
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                    content: SingleChildScrollView(
                      child: Form(
                        key: state.formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            NameTextField(controller: state.nameController),
                            ContactTextField(hintText: 'Contact', controller: state.contactController),
                            CustomImagePicker(
                              defaultImageUrl: event.employee.imageUrl,
                              title: 'Select Delivery Man Image',
                              image: (image) async =>
                                  BlocProvider.of<edit.EditDeliveryBoyBloc>(context).imageFile = image,
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      CustomButton(onPressed: () => Navigator.pop(dialogContext), title: 'Cancel'),
                      CustomButton(
                        onPressed: () => BlocProvider.of<edit.EditDeliveryBoyBloc>(context).add(
                          edit.Submit(dialogContext: dialogContext, employee: event.employee),
                        ),
                        title: 'Confirm',
                        primaryColor: true,
                      ),
                    ],
                  );
                default:
                  return const ErrorDialog();
              }
            },
          ),
        ),
      ).then((returnValue) {
        if (returnValue != null && returnValue == 'updated') {
          _reInit;
        }
      });
    });
    on<Delete>((event, emit) async {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog.adaptive(
          title: const Text('Delete'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          content: Text(
              'Are you sure? You want to delete ${event.employee.name}, if you delete user you wont be able to recover its data.'),
          actions: [
            CustomButton(onPressed: () => Navigator.pop(dialogContext), title: 'Cancel'),
            CustomButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                loading;
                try {
                  await auth.FirebaseAuth.instance
                      .signInWithEmailAndPassword(email: event.employee.email, password: event.employee.password)
                      .then((userCredential) async {
                    await userCredential.user!.delete();
                    await firebaseStorage.refFromURL(event.employee.imageUrl).delete();
                    await firebaseFs
                        .collection(fBCompanyCollectionKey)
                        .doc(event.employee.companyName)
                        .collection(fBEmployeesCollectionKey)
                        .doc(event.employee.uid)
                        .delete();
                    _reInit;
                  });
                } catch (exception) {
                  log(exception.toString());
                  error;
                }
              },
              title: 'Confirm',
              primaryColor: true,
            ),
          ],
        ),
      );
    });
  }

  get _reInit async {
    loading;
    deliveryMans.clear();
    try {
      await firebaseFs
          .collection(fBCompanyCollectionKey)
          .doc(user.companyName)
          .collection(fBEmployeesCollectionKey)
          .get()
          .then((employeesCollection) async {
        for (var employeeDoc in employeesCollection.docs) {
          Employee employee = Employee.fromMap(employeeDoc.data());
          if (employee.post == deliveryManPost && !(employee.onVacation) && employee.branch == user.branch) {
            deliveryMans.add(employee);
          }
        }
        loaded;
      });
    } catch (e) {
      log(e.toString());
      error;
    }
  }

  get loading => emit(Loading());
  get loaded => emit(Loaded(deliveryMans: deliveryMans));
  get error => emit(Error());
}
