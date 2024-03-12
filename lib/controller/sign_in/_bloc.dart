// ignore_for_file: invalid_use_of_visible_for_testing_member, use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'package:aqua_tracker_management/screen/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../model/company.dart';
import '../../model/user.dart';
import '../../screen/basic/not_verified.dart';
import '../../utils/constants.dart';
import '../../utils/firebase_push_notifications.dart';
import '../../utils/local_storage/hive.dart';
import '../../utils/widget/button.dart';
import '../../utils/widget/error_dialog.dart';
import '../../utils/widget/text_field.dart';

import '../../screen/manager/home/home.dart' as manager;
import '../../screen/deliveryman/home/home.dart' as deliveryman;

part '_event.dart';
part '_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final firebasePushNotifications = FirebasePushNotifications.instance;
  final firebaseAuth = auth.FirebaseAuth.instance;
  final firebaseFS = FirebaseFirestore.instance;
  final firebaseMessaging = FirebaseMessaging.instance;
  static bool showBackTabDialog = true;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  List<Company> companies = [];
  List<String> branches = [];
  String? selectedCompany;
  String? selectedPost;
  String? selectedBranch;
  late StreamSubscription iNCStreamSubscription;
  final BuildContext context;

  SignInBloc({required this.context}) : super(Splashed()) {
    _initialization();

    on<ForgetPassword>((event, emit) async {
      final fpFormKey = GlobalKey<FormState>();
      final fpController = TextEditingController();
      await showDialog(
        barrierDismissible: false,
        context: event.context,
        builder: (dialogContext) => AlertDialog.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Forget Password'),
          content: Form(
            key: fpFormKey,
            child: EmailTextField(textInputAction: TextInputAction.done, controller: fpController),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            CustomButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              title: 'Cancel',
            ),
            CustomButton(
              primaryColor: true,
              onPressed: () {
                if (fpFormKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              title: 'Confirm',
            ),
          ],
        ),
      ).then((returnValue) async {
        if (returnValue) {
          _loading;
          try {
            await firebaseAuth.sendPasswordResetEmail(email: fpController.text).whenComplete(() {
              fpController.dispose();
              _loaded;
              showDialog(
                context: context,
                builder: (context) => AlertDialog.adaptive(
                  actionsAlignment: MainAxisAlignment.center,
                  content: const Text(
                    'We send you an Email to change you password please check you inbox.',
                  ),
                  actions: [
                    CustomButton(onPressed: () => Navigator.pop(context), title: 'OK', primaryColor: true),
                  ],
                ),
              );
            });
          } on auth.FirebaseAuthException catch (exception) {
            if (exception.code == 'user-not-found') {
              showErrorToast(msg: 'User Not Found! Please check you email!');
            } else {
              showErrorToast(msg: 'Something went wrong try again later!');
            }
            _loaded;
            add(ForgetPassword(context: context));
          } catch (exception) {
            showDialog(context: context, builder: (context) => const ErrorDialog());
            log(exception.toString());
            showErrorToast(msg: 'Something went wrong try again later!');
            _loaded;
          }
        }
      });
    });

    on<CompanyChange>((event, emit) async {
      selectedCompany = event.company;
      try {
        _loading;
        await firebaseFS
            .collection(fBCompanyCollectionKey)
            .doc(event.company)
            .collection(fBBranchesCollectionKey)
            .get()
            .then((branchesCollection) {
          branches = branchesCollection.docs.map((branch) => branch.id).toList();
          _loaded;
        });
      } catch (e) {
        log(e.toString());
        _error;
      }
    });

    on<PostChange>((event, emit) {
      selectedPost = event.post;
      _loaded;
    });

    on<BranchChange>((event, emit) {
      selectedBranch = event.branch;
      _loaded;
    });

    on<SignIn>((event, emit) async {
      if (formKey.currentState!.validate()) {
        try {
          _loading;
          await firebaseAuth
              .signInWithEmailAndPassword(email: emailController.text, password: passwordController.text)
              .then((userCredential) async {
            await firebaseFS
                .collection(fBCompanyCollectionKey)
                .doc(selectedCompany)
                .collection(fBEmployeesCollectionKey)
                .doc(userCredential.user!.uid)
                .get()
                .then((documentSnapshot) async {
              if (documentSnapshot.exists) {
                User user = User.fromMap(documentSnapshot.data()!);
                if (user.branch == selectedBranch && user.post == selectedPost) {
                  if (userCredential.user!.emailVerified) {
                    if (userCredential.user!.email != user.email) {
                      await firebaseFS
                          .collection(fBCompanyCollectionKey)
                          .doc(user.companyName)
                          .collection(fBEmployeesCollectionKey)
                          .doc(user.uid)
                          .update({'email': userCredential.user!.email});
                      user = user.copyWith(email: userCredential.user!.email);
                    }
                    if (passwordController.text != user.password) {
                      await firebaseFS
                          .collection(fBCompanyCollectionKey)
                          .doc(user.companyName)
                          .collection(fBEmployeesCollectionKey)
                          .doc(user.uid)
                          .update({'password': passwordController.text});
                      user = user.copyWith(password: passwordController.text);
                    }
                    await _sign(user);
                  } else {
                    await firebaseAuth.currentUser!.sendEmailVerification().whenComplete(() {
                      context.pushNamed(NotVerifiedScreen.name).whenComplete(() => _loaded);
                    });
                  }
                } else {
                  await firebaseAuth.signOut();
                  showErrorToast(msg: 'Please provide correct Post and Branch');
                  _loaded;
                }
              } else {
                await firebaseAuth.signOut();
                showErrorToast(msg: 'Please provide correct company.');
                _loaded;
              }
            });
          });
        } on auth.FirebaseAuthException catch (exception) {
          if (exception.code == 'invalid-credential') {
            showErrorToast(msg: 'Please check your Email or Password');
          } else {
            showErrorToast(msg: 'Something went wrong. Try again later!');
          }
          _loaded;
        } catch (e) {
          log(e.toString());
          _error;
        }
      }
    });
  }

  Future<void> _initialization() async {
    firebasePushNotifications.requestPermission().whenComplete(() {
      iNCStreamSubscription = internetConnectionChecker.onStatusChange.listen(_onConnectionStatusChange);
      FirebaseMessaging.onMessage.listen(_handleNotification);
    });
  }

  Future<void> _onConnectionStatusChange(InternetConnectionStatus status) async {
    if (status == InternetConnectionStatus.connected) {
      await LocalDatabase.openBox.then((box) async {
        if (box.isNotEmpty) {
          await LocalDatabase.getUser().then((user) async {
            try {
              await firebaseAuth
                  .signInWithEmailAndPassword(email: user.email, password: user.password)
                  .whenComplete(() async => await _sign(user));
            } on auth.FirebaseAuthException catch (exception) {
              if (exception.code == 'invalid-credential') {
                showErrorToast(msg: 'Please check your Email or Password');
              } else {
                showErrorToast(msg: 'Something went wrong. Try again later!');
              }
              _getCompanies;
            } catch (e) {
              log(e.toString());
              _error;
            }
          });
        } else {
          _getCompanies;
        }
      });
    } else {
      _disconnected;
    }
  }

  Future<void> _handleNotification(RemoteMessage remoteMessage) async {
    RemoteNotification remoteNotification = FirebasePushNotifications.remoteMessageToRemoteNotification(remoteMessage);
    if (remoteNotification.android!.channelId == 'Sign Out') {
      await auth.FirebaseAuth.instance.signOut();
      await LocalDatabase.removeUser().whenComplete(() => context.pushReplacementNamed(SignInScreen.name));
    }
  }

  Future<void> _sign(User user) async {
    await firebaseMessaging.getToken().then((token) async {
      if (user.token.isNotEmpty && token != user.token) {
        bool canChangeToken = await showDialog(
          context: context,
          builder: (context) => AlertDialog.adaptive(
            actionsAlignment: MainAxisAlignment.spaceBetween,
            title: const Text('Notice'),
            content: const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                      text:
                          'Your Aqua-Tracker account already signed in from other device if you want to signed in from this device you will be signed out from other device. Please Click'),
                  TextSpan(
                    text: '"Ok"',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'If you want to continue',
                  )
                ],
              ),
            ),
            actions: [
              CustomButton(
                onPressed: () => Navigator.pop(context, false),
                title: 'Cancel',
              ),
              CustomButton(
                primaryColor: true,
                onPressed: () async => Navigator.pop(context, true),
                title: 'Ok',
              )
            ],
          ),
        );
        if (canChangeToken) {
          await firebasePushNotifications.sendSignOutNotification(token: user.token);
          await firebaseFS
              .collection(fBCompanyCollectionKey)
              .doc(user.companyName)
              .collection(fBEmployeesCollectionKey)
              .doc(user.uid)
              .update({'token': token}).whenComplete(() {
            user = user.copyWith(token: token);
            _afterSignInNavigation(user, context: context);
          });
        }
      } else {
        if (user.token.isEmpty) {
          await firebaseFS
              .collection(fBCompanyCollectionKey)
              .doc(user.companyName)
              .collection(fBEmployeesCollectionKey)
              .doc(user.uid)
              .update({'token': token});
          user = user.copyWith(token: token);
        }
        _afterSignInNavigation(user, context: context);
      }
    });
  }

  Future<void> _afterSignInNavigation(User user, {required BuildContext context}) async {
    showBackTabDialog = false;
    await LocalDatabase.putUser(user).whenComplete(() {
      if (user.post == managerPost) {
        context.pushReplacementNamed(manager.HomeScreen.name);
      } else {
        context.pushReplacementNamed(deliveryman.HomeScreen.name);
      }
    });
  }

  get _getCompanies async {
    try {
      await firebaseFS.collection(fBCompanyCollectionKey).get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          companies = querySnapshot.docs.map<Company>((company) => Company.fromMap(company.data())).toList();
        }
        _loaded;
      });
    } catch (e) {
      log(e.toString());
      _error;
    }
  }

  get _loading => emit(Loading());
  get _disconnected => emit(Disconnected());
  get _error => emit(Error());
  get _loaded => emit(
        Loaded(
          formKey: formKey,
          emailController: emailController,
          passwordController: passwordController,
          companies: companies,
          branches: branches,
        ),
      );

  @override
  Future<void> close() {
    passwordController.dispose();
    emailController.dispose();
    iNCStreamSubscription.cancel();
    return super.close();
  }
}
