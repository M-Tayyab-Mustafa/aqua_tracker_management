// ignore_for_file: invalid_use_of_visible_for_testing_member
import '../../../utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part '_event.dart';
part '_state.dart';

class LocationPickFromMapBloc extends Bloc<LocationPickFromMapEvent, LocationPickFromMapState> {
  GoogleMapController? mapController;
  late LatLng currentUserLocation;

  final Set<Marker> markers = <Marker>{};
  LocationPickFromMapBloc() : super(Loading()) {
    currentLocation().then((value) {
      if (value != null) {
        currentUserLocation = LatLng(value.latitude, value.longitude);
      }
      loaded;
    });
    on<AddMarkerEvent>((event, emit) async {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('pickedLocation'),
          infoWindow: InfoWindow(
            title: '${event.location.latitude}, ${event.location.longitude}',
          ),
          position: event.location,
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
      loaded;
    });
  }

  onMapCreated(GoogleMapController? controller) {
    mapController = controller;
  }

  get loaded => emit(Loaded(markers: markers));

  @override
  Future<void> close() {
    mapController?.dispose();
    return super.close();
  }
}
