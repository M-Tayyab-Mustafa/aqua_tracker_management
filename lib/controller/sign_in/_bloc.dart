// ignore_for_file: invalid_use_of_visible_for_testing_member, use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'package:aqua_tracker_managements/utils/widgets/button.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../model/company.dart';
import '../../model/user.dart';
import '../../utils/constants.dart';
import '../../utils/firebase_push_notifications.dart';
import '../../view/delivery_man/home/home.dart' as deliveryman;
import '../../view/manager/home/home.dart' as manager;
part '_event.dart';
part '_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  static bool backTabDialogForSignInScreen = true;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Forget Password Form
  final fpFormKey = GlobalKey<FormState>();
  final fpController = TextEditingController();

  final firebasePushNotifications = FirebasePushNotifications.instance;
  final firebaseAuth = auth.FirebaseAuth.instance;
  final firebaseFS = FirebaseFirestore.instance;
  late StreamSubscription internetConnectionCheckerStreamSubscription;
  final BuildContext context;
  late List<Company> companies;
  List<String>? branches;

  String? selectedCompany;
  String? selectedPost;
  String? selectedBranch;
  String? cloudEmail;

  SignInBloc(this.context) : super(Splash()) {
    firebasePushNotifications.requestPermission().whenComplete(() {
      internetConnectionCheckerStreamSubscription =
          internetConnectionChecker.onStatusChange.listen(_onConnectionStatusChange);
    });

    on<OnCompanyChange>((event, emit) async {
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

    on<OnPostChange>((event, emit) {
      selectedPost = event.post;
      _loaded;
    });

    on<OnBranchChange>((event, emit) {
      selectedBranch = event.branch;
      _loaded;
    });

    on<ForgetPassword>((event, emit) async {
      if (fpFormKey.currentState!.validate()) {
        try {
          await firebaseAuth.sendPasswordResetEmail(email: fpController.text).whenComplete(() {
            fpController.clear();
            showDialog(
              context: context,
              builder: (context) => const AlertDialog.adaptive(
                content: Text(
                  'We send you an Email to change you password please check you inbox.',
                ),
              ),
            );
          });
        } on auth.FirebaseAuthException catch (exception) {
          if (exception.code == 'user-not-found') {
            showErrorToast(msg: 'User Not Found! Please check you email!');
          } else {
            showErrorToast(msg: 'Something went wrong try again later!');
          }
        } catch (exception) {
          log(exception.toString());
          showErrorToast(msg: 'Something went wrong try again later!');
        }
      }
    });

    on<SignIn>((event, emit) async {
      if (formKey.currentState!.validate()) {
        try {
          _loading;
          if (cloudEmail == null && emailController.text != cloudEmail) {
            await firebaseAuth
                .signInWithEmailAndPassword(
                  email: emailController.text,
                  password: passwordController.text,
                )
                .then(_afterSignedIn);
          } else {
            showErrorToast(msg: 'You change your email then verify your email before login.');
          }
        } on auth.FirebaseAuthException catch (exception) {
          if (exception.code == 'invalid-credential') {
            showErrorToast(
                msg:
                    'Please check your Email or Password. If you change your email then verify your email before login.');
          } else {
            showErrorToast(msg: 'Something went wrong. Try again later!');
          }
          _loaded;
        } catch (exception) {
          log(exception.toString());
          showErrorToast(msg: 'Some thing went wrong try again later');
          _error;
        }
      }
    });
  }

  Future<void> _afterSignedIn(auth.UserCredential userCredential) async {
    if (userCredential.user!.emailVerified) {
      try {
        await firebaseFS
            .collection(fBCompanyCollectionKey)
            .doc(selectedCompany)
            .collection(fBEmployeesCollectionKey)
            .doc(userCredential.user!.uid)
            .get()
            .then((userDS) async {
          User cloudUser = User.fromMap(userDS.data()!);
          if (cloudUser.companyName == selectedCompany &&
              cloudUser.branch == selectedBranch &&
              cloudUser.post == selectedPost) {
            await FirebaseMessaging.instance.getToken().then((deviceToken) async {
              if (cloudUser.deviceToken.isNotEmpty && deviceToken != cloudUser.deviceToken) {
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
                  await firebasePushNotifications.sendSignOutNotification(token: cloudUser.deviceToken);
                  await firebaseFS
                      .collection(fBEmployeesCollectionKey)
                      .doc(cloudUser.uid)
                      .update({'token': deviceToken});
                  var user = cloudUser.copyWith(deviceToken: deviceToken);
                  _signIn(user: user);
                } else {
                  _loaded;
                }
              } else {
                if (cloudUser.deviceToken.isEmpty) {
                  await firebaseFS
                      .collection(fBEmployeesCollectionKey)
                      .doc(cloudUser.uid)
                      .update({'token': deviceToken});
                }
                var user = cloudUser.copyWith(deviceToken: deviceToken);
                _signIn(user: user);
              }
            });
          } else {
            await firebaseAuth.signOut();
            showErrorToast(msg: 'Please Provide Correct Company And Post And Branch');
            _loaded;
          }
        });
      } catch (e) {
        log(e.toString());
        _error;
      }
    } else {
      await userCredential.user!.sendEmailVerification();
      _notVerified;
    }
  }

  Future<void> _signIn({required User user}) async {
    SignInBloc.backTabDialogForSignInScreen = false;
    await localStorage.saveUser(user).whenComplete(() {
      if (user.post == managerPost) {
        context.go(manager.HomeScreen.name);
      } else {
        context.go(deliveryman.HomeScreen.screenName);
      }
    });
  }

  _onConnectionStatusChange(InternetConnectionStatus status) async {
    if (status == InternetConnectionStatus.connected) {
      await _isAlreadySignIn();
    } else {
      _disconnected;
    }
  }

  Future<bool> _isAlreadySignIn() async {
    var user = await localStorage.hasUser;

    if (user != null) {
      cloudEmail = (await firebaseFS
              .collection(fBCompanyCollectionKey)
              .doc(user.companyName)
              .collection(fBEmployeesCollectionKey)
              .doc(user.uid)
              .get())
          .data()!['email'];

      if (user.email != cloudEmail) {
        _getCompanies;
      } else {
        String password = (await firebaseFS
                .collection(fBCompanyCollectionKey)
                .doc(user.companyName)
                .collection(fBBranchesCollectionKey)
                .doc(user.branch)
                .get())
            .data()![user.uid];
        selectedCompany = user.companyName;
        selectedBranch = user.branch;
        selectedPost = user.post;
        await firebaseAuth
            .signInWithEmailAndPassword(
              email: user.email,
              password: password,
            )
            .then(_afterSignedIn);
      }
    } else {
      _getCompanies;
    }
    return false;
  }

  get _getCompanies async {
    try {
      await firebaseFS.collection(fBCompanyCollectionKey).get().then((querySnapshot) {
        companies = querySnapshot.docs.map<Company>((company) => Company.fromMap(company.data())).toList();
        _loaded;
      });
    } catch (e) {
      log(e.toString());
      _error;
    }
  }

  get _loading => emit(Loading());
  get _loaded => emit(
        Loaded(
          formKey: formKey,
          emailController: emailController,
          passwordController: passwordController,
          fpFormKey: fpFormKey,
          fpController: fpController,
          companies: companies,
          branches: branches,
        ),
      );
  get _error => emit(Error());
  get _disconnected => emit(Disconnected());
  get _notVerified => emit(NotVerified());

  @override
  Future<void> close() {
    internetConnectionCheckerStreamSubscription.cancel();
    return super.close();
  }
}
