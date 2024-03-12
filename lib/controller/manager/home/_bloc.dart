// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../model/user.dart';
import '../../../utils/constants.dart';
import '../../../utils/firebase_push_notifications.dart';
import '../../../utils/widgets/button.dart';
import '../../../utils/widgets/error_dialog.dart';
import '../../../view/basic_screen/about_us.dart';
import '../../../view/client/client.dart';
import '../../../view/manager/announcements/announcements.dart';
import '../../../view/manager/delivery_man/delivery_man.dart';
import '../../../view/manager/delivery_man_location/delivery_man_location.dart';
import '../../../view/manager/expenses/expenses.dart';
import '../../../view/manager/sales/sales.dart';
import '../../../view/sign_in/sign_in.dart';

part '_state.dart';

part '_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static bool backTabDialogForHomeScreen = true;
  late List listOfAds;
  late AnimationController _animation;
  late Animation<double> _rotationTween;
  late Animation<double> _opacityTween;
  late Animation<double> _heightTween;
  late Animation<double> _addsHeightTween;
  late Animation<double> _widthTween;
  late Animation<double> _borderRadiusTween;
  late Animation<double> _boxShadowTween;
  final double profileAvatarRadius = screenSize.width * 0.065;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final nameFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final contactFormKey = GlobalKey<FormState>();
  final contactController = TextEditingController(text: contactFieldDefaultValue);
  String navigateTo = '';
  late User user;
  bool canPop = false;

  HomeBloc(BuildContext context) : super(Loading()) {
    FirebasePushNotifications.context = context;
    on<SignOut>(
      (event, emit) => showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog.adaptive(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: const Text('Sign Out'),
          content: const Text('Do you want to sign out?'),
          actions: [
            CustomButton(onPressed: () => Navigator.pop(dialogContext), title: 'Cancel'),
            CustomButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await auth.FirebaseAuth.instance.signOut();
                localStorage.removeUser().whenComplete(() {
                  scaffoldKey.currentState!.closeDrawer();
                  context.goNamed(SignInScreen.name);
                });
              },
              primaryColor: true,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout_outlined, color: Colors.white),
                  Text('Sign Out', style: TextStyle(color: Colors.white)),
                ],
              ),
            )
          ],
        ),
      ),
    );
    on<ChangeName>((event, emit) async {
      Navigator.pop(event.dialogContext);
      try {
        if (nameFormKey.currentState!.validate() && nameController.text != user.name) {
          scaffoldKey.currentState!.closeEndDrawer();
          _loading;
          await (await firebaseCompanyDoc).collection(fBEmployeesCollectionKey).doc(user.uid).update({
            'name': nameController.text,
          }).whenComplete(() async {
            await localStorage.updateName(name: nameController.text);
            _loaded;
            scaffoldKey.currentState?.openEndDrawer();
          });
        }
      } catch (e) {
        log(e.toString());
        _error;
      }
    });

    on<ChangeEmail>((event, emit) async {
      Navigator.pop(event.dialogContext);
      try {
        if (emailFormKey.currentState!.validate() && emailController.text != user.email) {
          scaffoldKey.currentState!.closeEndDrawer();
          _loading;
          (await firebaseCompanyDoc).collection(fBBranchesCollectionKey).doc(user.branch).get().then((branchDoc) async {
            await auth.FirebaseAuth.instance
                .signInWithEmailAndPassword(email: user.email, password: branchDoc.data()![user.uid])
                .then((reLoggedInNewUserCredential) async {
              await reLoggedInNewUserCredential.user!.verifyBeforeUpdateEmail(emailController.text).whenComplete(
                    () => showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        title: const Text('You Change You\'r Email'),
                        actionsAlignment: MainAxisAlignment.center,
                        content: const Text(
                            'We send you email To verify your new email after this you will be logged out and you have to sign in after verifying your new email'),
                        actions: [
                          CustomButton(
                            title: 'OK',
                            primaryColor: true,
                            onPressed: () async {
                              (await firebaseCompanyDoc)
                                  .collection(fBEmployeesCollectionKey)
                                  .doc(user.uid)
                                  .update({'email': emailController.text});
                              await auth.FirebaseAuth.instance.signOut();
                              await localStorage.removeUser().whenComplete(() {
                                scaffoldKey.currentState!.closeDrawer();
                                _loaded;
                                context.goNamed(SignInScreen.name);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
            });
          });
        }
      } catch (e) {
        log(e.toString());
        _error;
      }
    });

    on<ChangeContact>((event, emit) async {
      Navigator.pop(event.dialogContext);
      try {
        if (contactFormKey.currentState!.validate() && contactController.text != user.contact) {
          scaffoldKey.currentState!.closeEndDrawer();
          _loading;
          await (await firebaseCompanyDoc).collection(fBEmployeesCollectionKey).doc(user.uid).update({
            'contact': contactController.text,
          }).whenComplete(() async {
            await localStorage.updateContact(contact: contactController.text);
            _loaded;
            scaffoldKey.currentState?.openEndDrawer();
          });
        }
      } catch (e) {
        log(e.toString());
        _error;
      }
    });

    on<AboutUs>((event, emit) {
      context.goNamed(AboutUsScreen.screenName);
    });

    on<Client>((event, emit) {
      _animation.forward();
      navigateTo = ClientScreen.name;
    });
    on<DeliveryManLocation>((event, emit) {
      _animation.forward();
      navigateTo = DeliveryManLocationScreen.name;
    });
    on<DeliveryMan>((event, emit) {
      _animation.forward();
      navigateTo = DeliveryManScreen.name;
    });
    on<Expenses>((event, emit) {
      _animation.forward();
      navigateTo = ExpensesScreen.name;
    });
    on<Sales>((event, emit) {
      _animation.forward();
      navigateTo = SalesScreen.name;
    });
    on<Announcements>((event, emit) {
      _animation.forward();
      navigateTo = AnnouncementsScreen.name;
    });

    on<BackButtonTap>((event, emit) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog.adaptive(
          title: const Text('Exit'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          content: const Text('Are you sure you want to exit'),
          actions: [
            CustomButton(onPressed: () => Navigator.pop(dialogContext), title: 'Cancel'),
            CustomButton(
              primaryColor: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                exit(0);
              },
              title: 'Confirm',
            ),
          ],
        ),
      );
    });
  }

  initial(TickerProvider tickerProvider, {required BuildContext context}) async {
    _animation = AnimationController(vsync: tickerProvider, duration: const Duration(seconds: 1));
    _rotationTween =
        Tween<double>(begin: 0, end: 180).animate(CurvedAnimation(parent: _animation, curve: const Interval(0.0, 0.5)));
    _opacityTween =
        Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: _animation, curve: const Interval(0.0, 0.3)));
    _addsHeightTween = Tween<double>(begin: screenSize.height * 0.35, end: 0)
        .animate(CurvedAnimation(parent: _animation, curve: const Interval(0.4, 0.8)));
    _borderRadiusTween = Tween<double>(begin: smallBorderRadius, end: 0)
        .animate(CurvedAnimation(parent: _animation, curve: const Interval(0.5, 1)));
    _boxShadowTween =
        Tween<double>(begin: 2, end: 0).animate(CurvedAnimation(parent: _animation, curve: const Interval(0.5, 1)));
    _heightTween = Tween<double>(begin: screenSize.height * 0.4, end: screenSize.height - kToolbarHeight)
        .animate(CurvedAnimation(parent: _animation, curve: const Interval(0.5, 1)));
    _widthTween = Tween<double>(begin: screenSize.width * 0.95, end: screenSize.width)
        .animate(CurvedAnimation(parent: _animation, curve: const Interval(0.5, 1)));
    _animation.addStatusListener((status) => _statusListener(status, context));
    _animation.addListener(() => _loaded);
    await firstInitialization;
  }

  _statusListener(AnimationStatus status, BuildContext context) async {
    if (status == AnimationStatus.completed) {
      if (navigateTo == ClientScreen.name) {
        context.goNamed(ClientScreen.name);
      } else if (navigateTo == DeliveryManLocationScreen.name) {
        context.goNamed(DeliveryManLocationScreen.name);
      } else if (navigateTo == DeliveryManScreen.name) {
        context.goNamed(DeliveryManScreen.name);
      } else if (navigateTo == ExpensesScreen.name) {
        context.goNamed(ExpensesScreen.name);
      } else if (navigateTo == SalesScreen.name) {
        context.goNamed(SalesScreen.name);
      } else {
        context.go(AnnouncementsScreen.name);
      }
      _animation.reset();
    }
  }

  get firstInitialization async {
    await FirebaseFirestore.instance.collection('ads').get().then((querySnapshot) async {
      listOfAds = querySnapshot.docs.map((ads) => ads.data()['url']).toList();
      user = await localStorage.user;
      nameController.text = user.name;
      emailController.text = user.email;
      contactController.text = user.contact;
    });
    _loaded;
  }

  get _loading => emit(Loading());

  get _error => const ErrorDialog();

  get _loaded => emit(
        Loaded(
          listOfAds: listOfAds,
          rotationTween: _rotationTween,
          opacityTween: _opacityTween,
          heightTween: _heightTween,
          addsHeightTween: _addsHeightTween,
          widthTween: _widthTween,
          borderRadiusTween: _borderRadiusTween,
          boxShadowTween: _boxShadowTween,
          user: user,
          nameFormKey: nameFormKey,
          nameController: nameController,
          emailFormKey: emailFormKey,
          emailController: emailController,
          contactFormKey: contactFormKey,
          contactController: contactController,
        ),
      );

  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    _animation.dispose();
    return super.close();
  }
}
