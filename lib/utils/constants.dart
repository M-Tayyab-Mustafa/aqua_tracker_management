import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;

//* Asset font Family Name
const String customFontFamily = 'AmazonBT';

//* Firebase Collections Keys
String fBCompanyCollectionKey = 'companies';
String fBEmployeesCollectionKey = 'employees';
String fBBranchesCollectionKey = 'branches';
String fBClientsCollectionKey = 'clients';
String fBReportsCollectionKey = 'reports';

//* Current Device Size
late Size screenSize;

//* Custom Paddings
double get smallestPadding => 5;
double get smallPadding => 10;
double get mediumPadding => 20;
double get largePadding => 30;

//* Custom Border Radius's
double get smallestBorderRadius => 4;
double get smallBorderRadius => 20;
double get mediumBoardRadius => 30;
double get largeBorderRadius => 50;

final InternetConnectionChecker internetConnectionChecker = InternetConnectionChecker.createInstance(
  checkInterval: const Duration(seconds: 1),
);

//* Employees Post Key
String deliveryManPost = 'Delivery boy';
String managerPost = 'Manager';

//* Error Flutter Toast
Future<bool?> showErrorToast({required String msg}) =>
    Fluttertoast.showToast(msg: msg, backgroundColor: Colors.redAccent, textColor: Colors.white);

//* Prefixed Value for Contact
String get contactFieldDefaultValue => '+92 ';

//* Degree to rad.
double angle({required double angle}) => angle * (pi / 180);

//* Button Sized
double buttonSize = 35;

//* Get Address From Given Latitude and Longitude
Future<String> addressFromLatLong({required String lat, required String long}) async {
  var placeMarker = await geocoding.placemarkFromCoordinates(double.parse(lat), double.parse(long));
  return '${placeMarker.first.street}, ${placeMarker.first.subLocality}, ${placeMarker.first.locality}';
}

//! Check Email Exists in The Firebase or user Already Register with provided Email
Future<bool> isEmailAlreadyExists(String email) async {
  var firebaseAuth = auth.FirebaseAuth.instance;
  try {
    await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: 'email-already-in-use')
        .then((credentials) => credentials.user!.delete());
    return false;
  } on auth.FirebaseAuthException catch (exception) {
    if (exception.code == 'email-already-in-use') {
      showErrorToast(msg: 'User Already Exists With This Email.');
    }
    return true;
  } catch (exception) {
    showErrorToast(msg: 'Something went wrong! try again later');
    return true;
  }
}

//! Send Password Through Email
Future sendPasswordEmail({
  required String clientEmail,
  required String ownerEmail,
  required String password,
  required String clientName,
}) async {
  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  await http.post(
    headers: {'origin': 'http://localhost', 'Content-Type': 'application/json'},
    url,
    body: jsonEncode({
      'service_id': 'service_2qn0kbl',
      'template_id': 'template_zrktqqg',
      'user_id': 'dipRaBY6t-q4FK293',
      'template_params': {
        'owner_email': ownerEmail,
        'to_name': clientName,
        'to_email': clientEmail,
        'user_password': password,
      }
    }),
  );
}

//! Table
const TextAlign tableTextAlign = TextAlign.center;
const TableCellVerticalAlignment tableCellVerticalAlignment = TableCellVerticalAlignment.middle;
//* Table Heading Text Style
TextStyle tableHeadingTextStyle(BuildContext context) {
  return Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold);
}

//! Get Current Location of The user
Future<Position?> get currentLocation => _currentLocation();

Future<Position?> _currentLocation() async {
  LocationPermission locationPermission = await GeolocatorPlatform.instance.requestPermission();
  if (locationPermission == LocationPermission.always || locationPermission == LocationPermission.whileInUse) {
    return await GeolocatorPlatform.instance.getCurrentPosition();
  } else {
    showErrorToast(msg: 'Location Permission is required to process further please allow location permission');
    await GeolocatorPlatform.instance.openAppSettings().whenComplete(() {
      _currentLocation();
    });
  }
  return null;
}
