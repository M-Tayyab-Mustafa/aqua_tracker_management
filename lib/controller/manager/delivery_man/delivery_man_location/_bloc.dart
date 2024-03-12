// ignore_for_file: invalid_use_of_visible_for_testing_member, use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:label_marker/label_marker.dart';

import '../../../../model/employee.dart';
import '../../../../model/location.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/local_storage/hive.dart';

part '_state.dart';
part '_event.dart';

class DeliveryManLocationBloc extends Bloc<DeliveryManLocationEvent, DeliveryManLocationState> {
  final firebaseFs = FirebaseFirestore.instance;
  final firebaseDatabase = FirebaseDatabase.instance.ref();
  GoogleMapController? mapController;
  late CameraPosition initialCameraPosition;
  final Set<Marker> markers = {};
  final List<Employee> presentDeliveryMans = [];
  DeliveryManLocationBloc(BuildContext context) : super(Loading()) {
    currentLocation.then((myLocation) async {
      if (myLocation != null) {
        initialCameraPosition = CameraPosition(target: LatLng(myLocation.latitude, myLocation.longitude), zoom: 12);
        await LocalDatabase.getUser().then((user) async {
          await firebaseFs
              .collection(fBCompanyCollectionKey)
              .doc(user.companyName)
              .collection(fBEmployeesCollectionKey)
              .get()
              .then((employeesCollection) async {
            for (var employeeDoc in employeesCollection.docs) {
              Employee employee = Employee.fromMap(employeeDoc.data());
              if (employee.post == 'Delivery boy' && !(employee.onVacation) && employee.branch == user.branch) {
                DataSnapshot dataSnapshot = await firebaseDatabase
                    .child(employee.companyName)
                    .child('employees_locations')
                    .child(employee.uid)
                    .get();
                Location location = Location.fromMap(dataSnapshot.value as Map);
                LatLng latLng = LatLng(double.parse(location.latitude), double.parse(location.longitude));
                await markers.addLabelMarker(LabelMarker(
                    label: 'Name: ${employee.name}\nBranch: ${employee.branch}',
                    markerId: MarkerId(employee.uid),
                    position: latLng,
                    backgroundColor: Theme.of(context).primaryColor));
              }
            }
            _loaded;
          });
        });
      } else {
        error;
      }
    });
  }
  onMapCreate(GoogleMapController controller) {
    mapController = controller;
  }

  addDeliveryManMarker(BuildContext context, {required Employee deliveryMan, required LatLng latLng}) async {}

  get loading => emit(Loading());
  get _loaded => emit(Loaded(initialCameraPosition: initialCameraPosition, markers: markers));
  get error => emit(Error());

  @override
  Future<void> close() {
    mapController?.dispose();
    return super.close();
  }
}
