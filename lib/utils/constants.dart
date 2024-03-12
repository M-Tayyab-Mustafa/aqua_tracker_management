import 'dart:math';
import 'package:aqua_tracker_managements/utils/local_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'dart:developer' as developer;

//? Firebase Collections Keys
String fBCompanyCollectionKey = 'companies';
String fBEmployeesCollectionKey = 'employees';
String fBBranchesCollectionKey = 'branches';

//? Firebase Company Doc
Future<DocumentReference> get firebaseCompanyDoc async {
  return FirebaseFirestore.instance.collection(fBCompanyCollectionKey).doc(
        (await localStorage.user).companyName,
      );
}

//? Full Screen Size
late Size screenSize;

//? Border Radius's
const double smallestBorderRadius = 4;
const double smallBorderRadius = 20;
const double mediumBoardRadius = 30;
const double largeBorderRadius = 50;

//?
late Color _buttonColors;

set buttonColors(Color color) => _buttonColors = color;
Color get buttonColors => _buttonColors;

//? Table
const TextAlign tableTextAlign = TextAlign.center;
const TableCellVerticalAlignment tableCellVerticalAlignment = TableCellVerticalAlignment.middle;

//? Table Heading Text Style
TextStyle tableHeadingTextStyle(BuildContext context) {
  return Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold);
}

//? Local Storage Reference variable
LocalStorage localStorage = LocalStorage();

//? Paddings
const double smallestPadding = 5;
const double smallPadding = 10;
const double mediumPadding = 20;
const double largePadding = 30;

//? Buttons Size
const Size buttonSize = Size(50, 50);
const customButtonTextPadding = MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: mediumPadding));

//? Request Time Out Duration
const Duration timeOutDuration = Duration(seconds: 30);

//? Firebase Storage Instances
final firebaseStorageReference = FirebaseStorage.instance.ref();

//? Firebase RealTime Database Reference
final firebaseDatabaseReference = FirebaseDatabase.instance.ref();

//? Error Flutter Toast
Future<bool?> showErrorToast({required String msg}) =>
    Fluttertoast.showToast(msg: msg, backgroundColor: Colors.redAccent, textColor: Colors.white);

//? Prefixed Value for Contact
String get contactFieldDefaultValue => '+92 ';

//? Branch Name That is selected by default
String defaultBranchName = 'All';

//* Pages Navigation Transition Duration
const Duration transitionDuration = Duration(milliseconds: 600);

//* Image Slider Auto Play Interval Duration in milliseconds
const int autoTimeInterval = 40000;

//? Key For Fetching Head Quarter
const String headQuarterKey = 'Head Quarter';

//? Degree to rad.
double angle({required double angle}) => angle * (pi / 180);

//? Font Style Name
const String customFontFamily = 'AmazonBT';

//? Check Email Exists in The Firebase or user Already Register with provided Email
Future<bool?> isEmailAlreadyExists(String email) async {
  try {
    await auth.FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: 'somePassword')
        .then((credentials) => credentials.user!.delete());
    return false;
  } on auth.FirebaseAuthException catch (e) {
    developer.log(e.code.toString());
    showErrorToast(msg: 'User Already Exists With This Email.');
    return true;
  } catch (exception) {
    developer.log(exception.toString());
    showErrorToast(msg: 'Something went wrong! try again later');
    return null;
  }
}

//? Employees Post Key
String deliveryManPost = 'Delivery boy';
String managerPost = 'Manager';

final InternetConnectionChecker internetConnectionChecker = InternetConnectionChecker.createInstance(
  checkInterval: const Duration(seconds: 1),
);

Future<Position?> currentLocation() async {
  LocationPermission locationPermission = await GeolocatorPlatform.instance.requestPermission();
  if (locationPermission == LocationPermission.always || locationPermission == LocationPermission.whileInUse) {
    return await GeolocatorPlatform.instance.getCurrentPosition();
  } else {
    Fluttertoast.showToast(msg: 'Location Permission is required to process further please allow location permission');
    await GeolocatorPlatform.instance.openAppSettings().whenComplete(() {
      currentLocation();
    });
  }
  return null;
}
