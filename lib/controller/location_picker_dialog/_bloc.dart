// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../utils/constants.dart';
import '../../view/basic_screen/location_pick_from_map.dart';

part '_event.dart';
part '_state.dart';

class LocationPickerDialogBloc extends Bloc<LocationPickerDialogEvent, LocationPickerDialogState> {
  LocationPickerDialogBloc() : super(Loading()) {
    loaded;
    on<UseCurrentLocation>((event, emit) async {
      loading;
      await GeolocatorPlatform.instance.requestPermission().then((locationPermission) async {
        if (locationPermission == LocationPermission.always || locationPermission == LocationPermission.whileInUse) {
          await GeolocatorPlatform.instance.getCurrentPosition().then((position) async {
            loaded;
            Navigator.pop(event.dialogContext, LatLng(position.latitude, position.longitude));
          }).timeout(timeOutDuration, onTimeout: () {
            error;
          });
        } else {
          showErrorToast(msg: 'Location Permission is required to process further please allow location permission');
          await GeolocatorPlatform.instance.openAppSettings();
        }
      }).timeout(timeOutDuration, onTimeout: () {
        error;
      });
    });

    on<ChooseFromMap>((event, emit) async {
      await event.dialogContext.pushNamed(LocationPickFromMapScreen.name).then((location) {
        if (location != null) {
          Navigator.pop(event.dialogContext, location);
        } else {
          showErrorToast(msg: 'Location not selected');
        }
      });
    });
  }

  get loading => emit(Loading());
  get error => emit(Error());
  get loaded => emit(Loaded());
}
