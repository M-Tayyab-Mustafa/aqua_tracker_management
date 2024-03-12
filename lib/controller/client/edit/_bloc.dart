// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'package:aqua_tracker_managements/model/reports.dart';
import 'package:aqua_tracker_managements/utils/widgets/button.dart';
import 'package:aqua_tracker_managements/utils/widgets/custom_location_picker.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/client.dart';
import '../../../model/location.dart';
import '../../../utils/constants.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

part '_event.dart';

part '_state.dart';

class EditClientBloc extends Bloc<EditClientEvent, EditClientState> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final editNameController = TextEditingController();
  final editContactController = TextEditingController(text: contactFieldDefaultValue);
  final editLatitudeController = TextEditingController();
  final editLongitudeController = TextEditingController();
  late List<Location> editClientLocations;
  List<String> editAddresses = [];
  late Client client;
  final List<String> _toRemoveLocationReport = [];

  EditClientBloc(BuildContext context, {required String uid}) : super(Loading()) {
    init(uid: uid);
    on<EditConfirm>((event, emit) async {
      loading;
      if (formKey.currentState!.validate() && editNameController.text != client.name ||
          editContactController.text != client.contact) {
        await firebaseCompanyDoc.then((doc) async {
          await doc
              .collection('clients')
              .doc(client.uid)
              .update({'name': editNameController.text, 'contact': editContactController.text});
        });
      }
      await firebaseCompanyDoc.then((doc) async {
        for (Location location in editClientLocations) {
          await doc
              .collection('clients')
              .doc(client.uid)
              .collection('reports')
              .doc('${location.latitude},${location.longitude}')
              .get()
              .then((documentSnapshot) async {
            if (!(documentSnapshot.exists)) {
              await doc
                  .collection('clients')
                  .doc(client.uid)
                  .collection('reports')
                  .doc('${location.latitude},${location.longitude}')
                  .set({
                'month_report': MonthReport(totalBottles: 0, details: {}).toMap(),
                'yearly_reports': [],
              });
            }
          });
        }
        for (var element in _toRemoveLocationReport) {
          await doc.collection('clients').doc(client.uid).collection('reports').doc(element).delete();
        }
        await doc
            .collection('clients')
            .doc(client.uid)
            .update({'locations': editClientLocations.map((e) => e.toMap()).toList()});
      }).whenComplete(() => Navigator.pop(event.dialogContext, 'edit_confirmed'));
    });

    on<AddClientLocation>((event, emit) {
      editLatitudeController.clear();
      editLongitudeController.clear();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (innerDialogContext) => AlertDialog.adaptive(
          title: const Text('Add New Location'),
          contentPadding: const EdgeInsets.symmetric(vertical: smallPadding),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          content: CustomLocationPicker(
            title: 'Select Client Location',
            latitudeController: editLatitudeController,
            longitudeController: editLongitudeController,
          ),
          actions: [
            CustomButton(onPressed: () => Navigator.pop(innerDialogContext), title: 'Cancel'),
            CustomButton(
              title: 'Add',
              primaryColor: true,
              onPressed: () async {
                Navigator.pop(innerDialogContext);
                loading;
                editClientLocations.add(
                  Location(
                    latitude: editLatitudeController.text,
                    longitude: editLongitudeController.text,
                  ),
                );
                editLatitudeController.clear();
                editLongitudeController.clear();
                _addresses().whenComplete(() => loaded);
              },
            ),
          ],
        ),
      );
    });
    on<DeleteClientLocation>((event, emit) async {
      if (editClientLocations.length == 1) {
        showErrorToast(msg: 'User must have one location.');
      } else {
        loading;
        _toRemoveLocationReport.add(
          '${editClientLocations[event.index].latitude},${editClientLocations[event.index].longitude}',
        );
        editClientLocations.removeAt(event.index);
        await _addresses();
        loaded;
      }
    });
  }

  init({required String uid}) async {
    await firebaseCompanyDoc.then(
      (doc) => doc.collection('clients').doc(uid).get().then(
            (clientDoc) async => client = Client.fromMap(clientDoc.data()!),
          ),
    );
    editNameController.text = client.name;
    editContactController.text = client.contact;
    editClientLocations = client.locations;
    await _addresses();
    loaded;
  }

  Future<void> _addresses() async {
    editAddresses.clear();
    for (Location clientLocation in editClientLocations) {
      var placeMarker = await geocoding.placemarkFromCoordinates(
          double.parse(clientLocation.latitude), double.parse(clientLocation.longitude));
      editAddresses.add('${placeMarker.first.street}, ${placeMarker.first.subLocality}, ${placeMarker.first.locality}');
    }
  }

  get loading => emit(Loading());

  get loaded => emit(Loaded(
      formKey: formKey,
      editNameController: editNameController,
      editContactController: editContactController,
      editClientLocations: editClientLocations,
      editAddresses: editAddresses));
  @override
  Future<void> close() {
    editNameController.dispose();
    editContactController.dispose();
    editLatitudeController.dispose();
    editLongitudeController.dispose();
    return super.close();
  }
}
