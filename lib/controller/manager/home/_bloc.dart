// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../model/user.dart';
import '../../../screen/basic/about_us.dart';
import '../../../screen/client/client.dart';
import '../../../screen/manager/announcements/announcements.dart';
import '../../../screen/manager/delivery_man/delivery_man.dart';
import '../../../screen/manager/delivery_man/delivery_man_location.dart';
import '../../../screen/manager/expenses/expenses.dart';
import '../../../screen/manager/sales/sales.dart';
import '../../../utils/widget/image_preview.dart';
import '../../../screen/sign_in.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage/hive.dart';
import '../../../utils/widget/button.dart';
import '../../../utils/widget/text_field.dart';

part '_event.dart';
part '_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static bool showBackTabDialog = true;
  final firebaseFS = FirebaseFirestore.instance;
  final firebaseAuth = auth.FirebaseAuth.instance;
  late List listOfAds;
  late AnimationController _animation;
  late Animation<double> _heightTween;
  late Animation<double> _widthTween;
  late Animation<double> _rotationTween;
  late Animation<double> _opacityTween;
  late Animation<double> _borderRadiusTween;
  late Animation<double> _boxShadowTween;
  final double _addSize = screenSize.height * 0.33;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final nameFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final contactFormKey = GlobalKey<FormState>();
  final contactController = TextEditingController(text: contactFieldDefaultValue);
  String navigateTo = '';
  late User user;
  HomeBloc() : super(Loading()) {
    on<SignOut>(
      (event, emit) => showDialog(
        context: event.context,
        builder: (context) => AlertDialog.adaptive(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: const Text('Sign Out'),
          content: const Text('Do you want to sign out?'),
          actions: [
            CustomButton(onPressed: () => Navigator.pop(context), title: 'Cancel'),
            CustomButton(
              onPressed: () async {
                Navigator.pop(context);
                await firebaseAuth.signOut();
                LocalDatabase.removeUser().whenComplete(() {
                  scaffoldKey.currentState!.closeDrawer();
                  showBackTabDialog = false;
                  event.context.pushReplacementNamed(SignInScreen.name);
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
    on<AboutUs>((event, emit) {
      event.context.pushNamed(AboutUsScreen.name);
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
    on<ProfileImagePreview>((event, emit) {
      event.context.pushNamed(ImagePreviewScreen.name, extra: {'image_url': event.imageUrl, 'tag': event.imageUrl});
    });
    on<ChangeName>((event, emit) async {
      await showDialog(
        context: event.context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog.adaptive(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: const Text('Change You\'r Name'),
          contentPadding: EdgeInsets.zero,
          content: Form(
            key: nameFormKey,
            child: NameTextField(hintText: 'Name', controller: nameController),
          ),
          actions: [
            CustomButton(onPressed: () => Navigator.pop(dialogContext, false), title: 'Cancel'),
            CustomButton(
              primaryColor: true,
              onPressed: () {
                if (nameFormKey.currentState!.validate() && nameController.text != user.name) {
                  Navigator.pop(dialogContext, true);
                }
              },
              title: 'Confirm',
            ),
          ],
        ),
      ).then((returnValue) async {
        if (returnValue) {
          try {
            _loading;
            scaffoldKey.currentState!.closeEndDrawer();
            await firebaseFS
                .collection(fBCompanyCollectionKey)
                .doc(user.companyName)
                .collection(fBEmployeesCollectionKey)
                .doc(user.uid)
                .update({
              'name': nameController.text,
            }).whenComplete(() async {
              user = user.copyWith(name: nameController.text);
              await LocalDatabase.updateUser(user);
              _loaded;
              scaffoldKey.currentState?.openEndDrawer();
            });
          } catch (e) {
            log(e.toString());
            _error;
          }
        }
      });
    });
    on<ChangeEmail>((event, emit) async {
      await showDialog(
        context: event.context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog.adaptive(
          title: const Text('Change You\'r Email'),
          contentPadding: EdgeInsets.zero,
          actionsAlignment: MainAxisAlignment.spaceBetween,
          content: Form(key: emailFormKey, child: EmailTextField(controller: emailController)),
          actions: [
            CustomButton(onPressed: () => Navigator.pop(dialogContext, false), title: 'Cancel'),
            CustomButton(
              onPressed: () {
                if (emailFormKey.currentState!.validate() && emailController.text != user.email) {
                  Navigator.pop(dialogContext, true);
                }
              },
              title: 'Confirm',
              primaryColor: true,
            ),
          ],
        ),
      ).then((returnValue) async {
        if (returnValue) {
          try {
            _loading;
            scaffoldKey.currentState!.closeEndDrawer();
            await auth.FirebaseAuth.instance.currentUser!
                .verifyBeforeUpdateEmail(emailController.text)
                .whenComplete(() async {
              await firebaseFS
                  .collection(fBCompanyCollectionKey)
                  .doc(user.companyName)
                  .collection(fBEmployeesCollectionKey)
                  .doc(user.uid)
                  .update({'email': emailController.text});
              await LocalDatabase.removeUser();
              await auth.FirebaseAuth.instance.signOut().then((value) {
                showDialog(
                  context: event.context,
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
                          showBackTabDialog = false;
                          context.goNamed(SignInScreen.name);
                        },
                      ),
                    ],
                  ),
                );
              });
            });
          } catch (e) {
            log(e.toString());
            _error;
          }
        }
      });
    });
    on<ChangeContact>((event, emit) async {
      await showDialog(
        context: event.context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog.adaptive(
          title: const Text('Change You\'r Contact'),
          contentPadding: EdgeInsets.zero,
          actionsAlignment: MainAxisAlignment.spaceBetween,
          content:
              Form(key: contactFormKey, child: ContactTextField(hintText: 'Contact', controller: contactController)),
          actions: [
            CustomButton(onPressed: () => Navigator.pop(dialogContext, false), title: 'Cancel'),
            CustomButton(
              onPressed: () {
                if (contactFormKey.currentState!.validate() && contactController.text != user.contact) {
                  Navigator.pop(dialogContext, true);
                }
              },
              title: 'Confirm',
              primaryColor: true,
            ),
          ],
        ),
      ).then((returnValue) async {
        try {
          _loading;
          scaffoldKey.currentState!.closeEndDrawer();
          await firebaseFS
              .collection(fBCompanyCollectionKey)
              .doc(user.companyName)
              .collection(fBEmployeesCollectionKey)
              .doc(user.uid)
              .update({
            'contact': contactController.text,
          }).whenComplete(() async {
            user = user.copyWith(contact: contactController.text);
            await LocalDatabase.updateUser(user);
            _loaded;
            scaffoldKey.currentState?.openEndDrawer();
          });
        } catch (e) {
          log(e.toString());
          _error;
        }
      });
    });
  }

  initial(TickerProvider tickerProvider, {required BuildContext context}) async {
    _animation = AnimationController(vsync: tickerProvider, duration: const Duration(milliseconds: 800));
    _rotationTween =
        Tween<double>(begin: 0, end: 180).animate(CurvedAnimation(parent: _animation, curve: const Interval(0.0, 0.5)));
    _opacityTween =
        Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: _animation, curve: const Interval(0.0, 0.4)));
    _borderRadiusTween = Tween<double>(begin: smallBorderRadius, end: 0)
        .animate(CurvedAnimation(parent: _animation, curve: const Interval(0.5, 1)));
    _boxShadowTween =
        Tween<double>(begin: 2, end: 0).animate(CurvedAnimation(parent: _animation, curve: const Interval(0.5, 1)));
    _heightTween = Tween<double>(begin: screenSize.height * 0.6, end: screenSize.height)
        .animate(CurvedAnimation(parent: _animation, curve: const Interval(0.5, 1)));
    _widthTween = Tween<double>(begin: screenSize.width * 0.95, end: screenSize.width)
        .animate(CurvedAnimation(parent: _animation, curve: const Interval(0.5, 1)));
    _animation.addStatusListener((status) => _statusListener(status, context));
    _animation.addListener(() => _loaded);
    user = await LocalDatabase.getUser();
    await firebaseFS.collection(fBCompanyCollectionKey).doc(user.companyName).get().then((querySnapshot) async {
      listOfAds = (querySnapshot.data()!)['banners'];
      nameController.text = user.name;
      emailController.text = user.email;
      contactController.text = user.contact;
      _loaded;
    }).timeout(const Duration(seconds: 30), onTimeout: () => _error);
  }

  Future<void> _statusListener(AnimationStatus status, BuildContext context) async {
    if (status == AnimationStatus.completed) {
      if (navigateTo == ClientScreen.name) {
        context.pushNamed(ClientScreen.name);
      } else if (navigateTo == DeliveryManLocationScreen.name) {
        context.pushNamed(DeliveryManLocationScreen.name);
      } else if (navigateTo == DeliveryManScreen.name) {
        context.pushNamed(DeliveryManScreen.name);
      } else if (navigateTo == ExpensesScreen.name) {
        context.pushNamed(ExpensesScreen.name);
      } else if (navigateTo == SalesScreen.name) {
        context.pushNamed(SalesScreen.name);
      } else {
        context.pushNamed(AnnouncementsScreen.name);
      }
      _animation.reset();
    }
  }

  get _error => emit(Error());
  get _loading => emit(Loading());
  get _loaded => emit(
        Loaded(
          listOfAds: listOfAds,
          user: user,
          heightTween: _heightTween,
          widthTween: _widthTween,
          rotationTween: _rotationTween,
          opacityTween: _opacityTween,
          borderRadiusTween: _borderRadiusTween,
          boxShadowTween: _boxShadowTween,
          addSize: _addSize,
          nameFormKey: nameFormKey,
          nameController: nameController,
          emailFormKey: emailFormKey,
          emailController: emailController,
          contactFormKey: contactFormKey,
          contactController: contactController,
        ),
      );
}
