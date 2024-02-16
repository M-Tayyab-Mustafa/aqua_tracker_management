// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_generator/password_generator.dart';
import '../../../model/client.dart';
import '../../../model/location.dart';
import '../../../model/reports.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage/hive.dart';
part '_event.dart';
part '_state.dart';

class AddClientBloc extends Bloc<AddClientEvent, AddClientState> {
  final firebaseAuth = auth.FirebaseAuth.instance;
  final firebaseFs = FirebaseFirestore.instance;
  final emailFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  // Client Details
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final contactController = TextEditingController(text: contactFieldDefaultValue);
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  AddClientBloc() : super(Loading()) {
    _emailChecking;
    on<SubmitEmail>((event, emit) async {
      if (emailFormKey.currentState!.validate()) {
        _loading;
        await isEmailAlreadyExists(emailController.text).then((exists) {
          if (exists) {
            _emailChecking;
          } else {
            _addClient;
          }
        });
      }
    });
    on<SubmitClient>((event, emit) async {
      if (formKey.currentState!.validate()) {
        try {
          _loading;
          await LocalDatabase.getUser().then((user) async {
            final password = PasswordGenerator(
              length: 8,
              hasCapitalLetters: true,
              hasNumbers: true,
              hasSmallLetters: true,
              hasSymbols: true,
            ).generatePassword();
            await auth.FirebaseAuth.instance
                .createUserWithEmailAndPassword(email: emailController.text, password: password)
                .then((clientCredentials) async {
              final address = await addressFromLatLong(lat: latitudeController.text, long: longitudeController.text);
              await firebaseFs
                  .collection(fBCompanyCollectionKey)
                  .doc(user.companyName)
                  .collection(fBClientsCollectionKey)
                  .doc(clientCredentials.user!.uid)
                  .set(Client(
                    name: nameController.text,
                    contact: contactController.text,
                    email: emailController.text,
                    branch: user.branch,
                    companyName: user.companyName,
                    uid: clientCredentials.user!.uid,
                    token: '',
                    password: password,
                    locations: [
                      Location(
                        latitude: latitudeController.text,
                        longitude: longitudeController.text,
                        address: address,
                      ),
                    ],
                    onVacation: false,
                  ).toMap())
                  .whenComplete(() async {
                await firebaseFs
                    .collection(fBCompanyCollectionKey)
                    .doc(user.companyName)
                    .collection(fBClientsCollectionKey)
                    .doc(clientCredentials.user!.uid)
                    .collection(fBReportsCollectionKey)
                    .doc('${latitudeController.text},${longitudeController.text}')
                    .set({
                  'month_report': MonthReport(
                    totalBottles: 0,
                    details: {},
                  ).toMap(),
                  'yearly_reports': []
                }).whenComplete(
                  () async => await clientCredentials.user!.sendEmailVerification().whenComplete(() async {
                    try {
                      await sendPasswordEmail(
                              clientEmail: emailController.text,
                              ownerEmail: user.email,
                              password: password,
                              clientName: nameController.text)
                          .whenComplete(() => Navigator.pop(event.dialogContext, 'new_client_added'));
                    } catch (exception) {
                      log(exception.toString());
                      _error;
                    }
                  }),
                );
              });
            });
          });
        } catch (e) {
          log(e.toString());
          _error;
        }
      }
    });
  }

  get _loading => emit(Loading());
  get _emailChecking => emit(EmailChecking(emailFormKey: emailFormKey, emailController: emailController));
  get _addClient => emit(AddClient(
        formKey: formKey,
        nameController: nameController,
        contactController: contactController,
        latitudeController: latitudeController,
        longitudeController: longitudeController,
      ));
  get _error => emit(Error());

  @override
  Future<void> close() {
    emailController.dispose();
    nameController.dispose();
    contactController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    return super.close();
  }
}
