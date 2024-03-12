// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/manager/delivery_man/edit/_bloc.dart' as edit;
import '../../../utils/widgets/error_dialog.dart';
import '../../../utils/widgets/loading_dialog.dart';
import '../../../model/delivery_man.dart';
import '../../../utils/constants.dart';
import '../../../utils/widgets/button.dart';
import '../../../utils/widgets/image_picker.dart';
import '../../../utils/widgets/text_field.dart';
import 'add/_bloc.dart' as add_bloc;

part '_state.dart';
part '_event.dart';

class DeliveryManBloc extends Bloc<DeliveryManEvent, DeliveryManState> {
  late List<Employee> deliveryMans;
  DeliveryManBloc(BuildContext context) : super(Loading()) {
    _init();

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
                    content: Form(
                        key: state.emailFormKey, child: EmailTextField(controller: state.newEmployeeEmailController)),
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
                Map<String, dynamic> toDeleteField = {event.employee.uid: FieldValue.delete()};
                loading;
                try {
                  await firebaseCompanyDoc.then((doc) {
                    doc
                        .collection(fBBranchesCollectionKey)
                        .doc(event.employee.branch)
                        .get()
                        .then((branchSnapshot) async {
                      await auth.FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: event.employee.email, password: branchSnapshot.data()![event.employee.uid])
                          .then((userCredential) async {
                        await userCredential.user!.delete();
                        await firebaseStorageReference
                            .child(event.employee.companyName)
                            .child(event.employee.branch)
                            .child(event.employee.email)
                            .delete();
                        await doc.collection(fBBranchesCollectionKey).doc(event.employee.branch).update(toDeleteField);
                        await doc.collection(fBEmployeesCollectionKey).doc(event.employee.uid).delete();
                        _reInit;
                      });
                    });
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

  Future<void> _init() async {
    deliveryMans = [];
    try {
      await localStorage.user.then((user) async {
        (await firebaseCompanyDoc).collection(fBEmployeesCollectionKey).get().then((employeesCollection) async {
          for (var employeeDoc in employeesCollection.docs) {
            Employee employee = Employee.fromMap(employeeDoc.data());
            if (employee.post == deliveryManPost && !(employee.onVacations) && employee.branch == user.branch) {
              deliveryMans.add(employee);
            }
          }
          loaded;
        });
      });
    } catch (e) {
      log(e.toString());
      error;
    }
  }

  get _reInit {
    loading;
    _init();
  }

  get loading => emit(Loading());
  get loaded => emit(Loaded(deliveryMans: deliveryMans));
  get error => emit(Error());
}
