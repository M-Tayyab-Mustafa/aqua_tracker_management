// ignore_for_file: invalid_use_of_visible_for_testing_member, use_build_context_synchronously
import 'package:aqua_tracker_managements/model/delivery_man.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:label_marker/label_marker.dart';
import '../../../model/location.dart';
import '../../../utils/constants.dart';

part '_state.dart';
part '_event.dart';

class DeliveryManLocationBloc extends Bloc<DeliveryManLocationEvent, DeliveryManLocationState> {
  GoogleMapController? mapController;
  late CameraPosition initialCameraPosition;
  final Set<Marker> markers = {};
  final List<Employee> presentDeliveryMans = [];
  DeliveryManLocationBloc(BuildContext context) : super(Loading()) {
    _firstInitialization(context);
  }
  onMapCreate(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _firstInitialization(BuildContext context) async {
    await currentLocation().then((myLocation) async {
      if (myLocation != null) {
        initialCameraPosition = CameraPosition(target: LatLng(myLocation.latitude, myLocation.longitude), zoom: 12);
        await localStorage.user.then((user) async {
          (await firebaseCompanyDoc).collection(fBEmployeesCollectionKey).get().then((employeesCollection) async {
            for (var employeeDoc in employeesCollection.docs) {
              Employee employee = Employee.fromMap(employeeDoc.data());
              if (employee.post == 'Delivery boy' && !(employee.onVacations) && employee.branch == user.branch) {
                DataSnapshot dataSnapshot = await firebaseDatabaseReference
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
            loaded;
          });
        });
      } else {
        error;
      }
    });
  }

  addDeliveryManMarker(BuildContext context, {required Employee deliveryMan, required LatLng latLng}) async {}

  get loading => emit(Loading());
  get loaded => emit(Loaded(initialCameraPosition: initialCameraPosition, markers: markers));
  get error => emit(Error());

  @override
  Future<void> close() {
    mapController?.dispose();
    return super.close();
  }
}
