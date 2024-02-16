// ignore_for_file: invalid_use_of_visible_for_testing_member, use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../custom_location_picker/custom_location_picker.dart';
import '../../../model/client.dart';
import '../../../model/location.dart';
import '../../../model/reports.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage/hive.dart';
import '../../../utils/widget/button.dart';
part '_event.dart';

part '_state.dart';

class EditClientBloc extends Bloc<EditClientEvent, EditClientState> {
  final firebaseFs = FirebaseFirestore.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final contactController = TextEditingController(text: contactFieldDefaultValue);
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  late List<Location> locations;
  final List _toRemoveReports = [];

  EditClientBloc({required String uid}) : super(Loading()) {
    init(uid: uid);

    on<EditConfirm>((event, emit) async {
      _loading;
      if (formKey.currentState!.validate()) {
        var clientDoc = firebaseFs
            .collection(fBCompanyCollectionKey)
            .doc(event.client.companyName)
            .collection(fBClientsCollectionKey)
            .doc(uid);
        if (nameController.text != event.client.name) {
          await clientDoc.update({'name': nameController.text});
        }
        if (contactController.text != event.client.contact) {
          clientDoc.update({'contact': contactController.text});
        }
        if (_toRemoveReports.isNotEmpty) {
          await showDialog(
            context: event.dialogContext,
            barrierDismissible: false,
            builder: (context) => AlertDialog.adaptive(
              actionsAlignment: MainAxisAlignment.spaceBetween,
              title: const Text('Alert'),
              content: const Text(
                'You Delete Some Locations. The Reports Related to that locations would deleted and never restorable if you want to continue then press "OK".',
              ),
              actions: [
                CustomButton(
                  onPressed: () => Navigator.pop(context, false),
                  title: 'Cancel',
                ),
                CustomButton(
                  onPressed: () => Navigator.pop(context, true),
                  title: 'Ok',
                ),
              ],
            ),
          ).then((returnValue) async {
            if (returnValue) {
              for (Location location in _toRemoveReports) {
                clientDoc.collection(fBReportsCollectionKey).doc('${location.latitude},${location.longitude}').delete();
              }
              await _addLocations(clientDoc, event);
            }
          });
        } else {
          await _addLocations(clientDoc, event);
        }
      }
    });

    on<AddLocation>((event, emit) async {
      latitudeController.clear();
      longitudeController.clear();
      await showDialog(
        context: event.dialogContext,
        barrierDismissible: false,
        builder: (context) => AlertDialog.adaptive(
          title: const Text('Add New Location'),
          contentPadding: EdgeInsets.symmetric(vertical: smallPadding),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          content: CustomLocationPicker(
            title: 'Select Client Location',
            latitudeController: latitudeController,
            longitudeController: longitudeController,
          ),
          actions: [
            CustomButton(
              onPressed: () => Navigator.pop(context, false),
              title: 'Cancel',
            ),
            CustomButton(
              title: 'Add',
              primaryColor: true,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ).then((returnValue) async {
        if (returnValue) {
          final address = await addressFromLatLong(lat: latitudeController.text, long: longitudeController.text);
          locations.add(
            Location(
              latitude: latitudeController.text,
              longitude: longitudeController.text,
              address: address,
            ),
          );
          _loaded;
        }
      });
    });
    on<DeleteLocation>((event, emit) async {
      locations.remove(event.location);
      _toRemoveReports.add(event.location);
      _loaded;
    });
  }
  init({required String uid}) async {
    await LocalDatabase.getUser().then((user) async {
      await firebaseFs
          .collection(fBCompanyCollectionKey)
          .doc(user.companyName)
          .collection(fBClientsCollectionKey)
          .doc(uid)
          .get()
          .then((clientDoc) {
        var client = Client.fromMap(clientDoc.data()!);
        nameController.text = client.name;
        contactController.text = client.contact;
        locations = client.locations;
        _loaded;
      });
    });
  }

  _addLocations(clientDoc, event) async {
    for (Location location in locations) {
      var doc = clientDoc.collection(fBReportsCollectionKey).doc('${location.latitude},${location.longitude}');
      doc.get().then((documentSnapshot) async {
        if (!(documentSnapshot.exists)) {
          doc.set({
            'month_report': MonthReport(totalBottles: 0, details: {}).toMap(),
            'yearly_reports': [],
          });
        }
      });
    }
    await clientDoc.update({'locations': locations.map((e) => e.toMap()).toList()}).whenComplete(
        () => Navigator.pop(event.dialogContext, 'edit_completed'));
  }

  get _loading => emit(Loading());

  get _loaded => emit(Loaded(
        formKey: formKey,
        nameController: nameController,
        contactController: contactController,
        locations: locations,
      ));

  @override
  Future<void> close() {
    nameController.dispose();
    contactController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    return super.close();
  }
}
