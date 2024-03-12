// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:developer';

import 'package:aqua_tracker_managements/model/client.dart';
import 'package:aqua_tracker_managements/model/location.dart';
import 'package:aqua_tracker_managements/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

import '../../../model/reports.dart';

part '_event.dart';
part '_state.dart';

class AddClientBloc extends Bloc<AddClientEvent, AddClientState> {
  final emailFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  // Client Details
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final contactController = TextEditingController(text: contactFieldDefaultValue);
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  AddClientBloc() : super(Loading()) {
    loaded;
    on<EmailChecking>((event, emit) async {
      if (emailFormKey.currentState!.validate()) {
        loading;
        await isEmailAlreadyExists(emailController.text).then((exists) {
          if (exists != null && !exists) {
            createUserState;
          } else {
            loaded;
          }
        });
      }
    });
    on<SubmitNewClient>((event, emit) async {
      if (formKey.currentState!.validate()) {
        try {
          loading;
          await localStorage.user.then((user) async {
            await auth.FirebaseAuth.instance
                .createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text)
                .then(
              (clientCredentials) async {
                var clientUid = clientCredentials.user!.uid;
                (await firebaseCompanyDoc).collection(fBBranchesCollectionKey).doc(user.branch).set(
                  {
                    clientUid: passwordController.text,
                  },
                  SetOptions(merge: true),
                );
                (await firebaseCompanyDoc)
                    .collection('clients')
                    .doc(clientUid)
                    .set(
                      Client(
                        name: nameController.text,
                        contact: contactController.text,
                        email: emailController.text,
                        branch: user.branch,
                        companyName: user.companyName,
                        uid: clientUid,
                        onVacations: false,
                        token: '',
                        locations: [
                          Location(
                            latitude: latitudeController.text,
                            longitude: longitudeController.text,
                          ),
                        ],
                      ).toMap(),
                    )
                    .whenComplete(
                  () async {
                    (await firebaseCompanyDoc)
                        .collection('clients')
                        .doc(clientUid)
                        .collection('reports')
                        .doc('${latitudeController.text},${longitudeController.text}')
                        .set(
                      {
                        'month_report': MonthReport(
                          totalBottles: 0,
                          details: {},
                        ).toMap(),
                        'yearly_reports': []
                      },
                    ).whenComplete(() {
                      loaded;
                      Navigator.pop(event.dialogContext, 'new_client_added');
                    });
                  },
                );
              },
            );
          });
        } catch (e) {
          log(e.toString());
          error;
        }
      }
    });
  }
  get loading => emit(Loading());
  get loaded => emit(
        Loaded(
          emailFormKey: emailFormKey,
          emailController: emailController,
        ),
      );
  get createUserState => emit(CreateUser(
      formKey: formKey,
      nameController: nameController,
      contactController: contactController,
      passwordController: passwordController,
      confirmPasswordController: confirmPasswordController,
      latitudeController: latitudeController,
      longitudeController: longitudeController));
  get error => emit(Error());

  @override
  Future<void> close() {
    emailController.dispose();
    nameController.dispose();
    contactController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    return super.close();
  }
}
