// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../utils/constants.dart';

part '_event.dart';
part '_state.dart';

class PickLocationFromMapBloc extends Bloc<LocationPickFromMapEvent, LocationPickFromMapState> {
  GoogleMapController? mapController;
  late LatLng currentUserLocation;

  final Set<Marker> markers = <Marker>{};
  PickLocationFromMapBloc() : super(Loading()) {
    currentLocation.then((position) {
      if (position != null) {
        currentUserLocation = LatLng(position.latitude, position.longitude);
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
